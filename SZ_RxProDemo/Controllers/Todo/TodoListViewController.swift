//
//  TodoListViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/10/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

enum SaveTodoError: Error {
    
    case cannotSaveToLocalFile
    case iCloudIsNotEnabled
    case cannotReadLocalFile
    case cannotCreateFileOnCloud
}

/*
 对网络上一个rx项目由storyboard转为手动代码，并且加入了一些自己的功能，旨在学习rx的使用
 
 感谢：https://github.com/puretears/RxToDoDemo/
 */

/// VC 主体
class TodoListViewController: UIViewController {
    
    /// todo 表格
    private var tableView: UITableView?
    /// 清除 todo 按钮
    private var clearTodoBtn: UIButton?
    /// 上传 todo 按钮
    private var uploadTodoBtn: UIButton?
    /// 添加 todo 按钮
    private var addTodoBtn: UIBarButtonItem?
    
    /// rx资源回收bag
    private let bag: DisposeBag = DisposeBag()
    /// 展示数据
    private var todoItems = BehaviorRelay<[TodoItem]>(value: [])
    
    private var showItems: [TodoItem] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        reloadData()
    }
}

// MARK: - UI
extension TodoListViewController {
    
    /// 设置UI
    private func setupUI() {
        
        title = "TodoList"
        
        setupNavgation()
        setupTableView()
        setupBottomButtons()
    }
    
    /// 设置tableview
    private func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: UIScreen.main.sz_navHeight, width: UIScreen.main.sz_screenWidth, height: UIScreen.main.sz_screenHeight - UIScreen.main.sz_navHeight))
        
        tableView?.dataSource      = self
        tableView?.delegate        = self
        tableView?.contentInset    = UIEdgeInsets(top: 0, left: 0, bottom: 180, right: 0)
        tableView?.register(TodoItemCell.self, forCellReuseIdentifier: "TodoItemCellIndentifier")
        
        tableView?.estimatedRowHeight           = 0
        tableView?.estimatedSectionHeaderHeight = 0
        tableView?.estimatedSectionFooterHeight = 0
        
        view.addSubview(tableView!)
    }
    
    /// 设置导航栏
    private func setupNavgation() {
        
        addTodoBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        navigationItem.rightBarButtonItem = addTodoBtn
        
        addTodoBtn?.rx.tap
            .subscribe(onNext: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.addTodoItem()
            })
            .disposed(by: bag)
    }
    
    /// 设置底部按钮
    private func setupBottomButtons() {
        
        let bottomContent = UIView(frame: CGRect(x: 0, y: UIScreen.main.sz_screenHeight - 180, width: UIScreen.main.sz_screenWidth, height: 180))
        
        bottomContent.backgroundColor = UIColor.white
        
        view.addSubview(bottomContent)
        
        clearTodoBtn = UIButton()
        
        clearTodoBtn?.setImage(UIImage(named: "Delete"), for: .normal)
        
        bottomContent.addSubview(clearTodoBtn!)
        
        clearTodoBtn?.rx.tap
            .subscribe(onNext: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.clearTodoList()
            })
            .disposed(by: bag)
        
        clearTodoBtn?.snp.makeConstraints({ (make) in
            
            make.centerY.equalToSuperview().offset(-30)
            make.left.equalTo(32)
            make.size.equalTo(CGSize(width: 64, height: 64))
        })
        
        uploadTodoBtn = UIButton()
        
        uploadTodoBtn?.setImage(UIImage(named: "Sync"), for: .normal)
        
        bottomContent.addSubview(uploadTodoBtn!)
        
        uploadTodoBtn?.rx.tap
            .subscribe(onNext: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.syncToCloud()
            })
            .disposed(by: bag)
        
        uploadTodoBtn?.snp.makeConstraints({ (make) in
            
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.size.equalTo(CGSize(width: 64, height: 64))
        })
        
        let saveBtn = UIButton()
        
        saveBtn.setImage(UIImage(named: "Save"), for: .normal)
        
        bottomContent.addSubview(saveBtn)
        
        saveBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.saveTodoList()
            })
            .disposed(by: bag)
        
        saveBtn.snp.makeConstraints({ (make) in
            
            make.centerY.equalToSuperview().offset(-30)
            make.right.equalTo(-32)
            make.size.equalTo(CGSize(width: 64, height: 64))
        })
    }
}

// MARK: - IBAction
extension TodoListViewController {
    
    private func addTodoItem() {
        
        let detail = TodoDetailViewController()
        
        detail.title = "Add Todo"
        
        _ = detail.todo.subscribe(onNext: { [weak self] (newTodo) in
            
                guard let `self` = self else { return }
            
                self.showItems.append(newTodo)
        
                self.todoItems.accept(self.showItems)
            
            }, onDisposed: {
            
                print("Finish adding a new todo.")
            })
        
        navigationController?.present(UINavigationController(rootViewController: detail), animated: true, completion: nil)
    }
    
    private func clearTodoList() {
        
        showItems.removeAll()
        
        todoItems.accept(showItems)
    }
    
    /*
     上传到iCloud功能并不能用，只是展示一个异步的操作，如何使用rx
     */
    private func syncToCloud() {
        
        /*
         要特别强调的是：onCompleted对于自定义Observable非常重要，通常我们要在onNext之后，自动跟一个onCompleted，以确保Observable资源可以正确回收。
         */
        _ = syncTodoToCloud().subscribe(
            onNext: {
                
                self.flash(title: "Success",
                           message: "All todos are synced to: \($0)")
                
            }, onError: {
                
                self.flash(title: "Failed",
                           message: "Sync failed due to: \($0.localizedDescription)")
                
            }, onDisposed: {
                
                print("SyncOb disposed")
            })
    }
    
    private func saveTodoList() {
        
        /*
         对于这种单次的事件序列，我们可以在订阅之后不做任何事情。因为订阅的Observable对象，一定会结束，要不就是正常的onCompleted，要不就是异常的onError，无论是哪种情况，在订阅到之后，Observable都会结束，订阅也随之会自动取消，分配给Obserable的资源也就会被回收了。因此，直接把最后的addDisposableTo(bag)删除就好
         */
        _ = saveTodoItems().subscribe(onError: { [weak self] (error) in
            
                guard let `self` = self else { return }
            
                self.flash(title: "Failed",
                            message: error.localizedDescription)
            
            }, onCompleted: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.flash(title: "Success",
                            message: "All Todos are saved on your phone.")
                
            }, onDisposed: {
            
                print("SaveOb disposed")
            })
    }
}

// MARK: - data
extension TodoListViewController {
    
    private func saveTodoItems() -> Observable<Void> {
        
        let data = NSMutableData()
        
        // FIXME: - iOS12 对应 @山竹
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(todoItems.value, forKey: "TodoItems")
        archiver.finishEncoding()
        
        return Observable.create({ (observe) -> Disposable in
            
            let result = data.write(to: self.dataFilePath(), atomically: true)
            
            if !result {
                
                observe.onError(SaveTodoError.cannotSaveToLocalFile)
            }
            
            observe.onCompleted()
            
            return Disposables.create()
        })
    }
    
    private func loadTodoItems() {
        
        let path = dataFilePath()
        
        // FIXME: - iOS12 对应 @山竹
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            
            showItems = unarchiver.decodeObject(forKey: "TodoItems") as! [TodoItem]
            
            todoItems.accept(showItems)
            
            unarchiver.finishDecoding()
        }
    }
    
    private func documentsDirectory() -> URL {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return path[0]
    }
    
    private func dataFilePath() -> URL {
        
        return documentsDirectory().appendingPathComponent("TodoList.plist")
    }
    
    private func reloadData() {
        
        loadTodoItems()
        
        todoItems.asObservable().subscribe(onNext: { [weak self] (todos) in
            
            guard let `self` = self else { return }
            
            self.updateUI(todos: todos)
        })
        .disposed(by: bag)
    }
    
    private func updateUI(todos: [TodoItem]) {
        
        /*
         再对UI进行一点约束，例如：

         顶部的标题应该显示当前todo的个数；
         清空列表后应该禁用删除按钮；
         清空列表后应该禁用上传按钮；
         限制最多只能存在4个未完成的todo，否则就禁用添加按钮；
         */

        title                    = todos.isEmpty ? "Todo" : "\(todos.count) Todos"
        clearTodoBtn?.isEnabled  = !todos.isEmpty
        uploadTodoBtn?.isEnabled = !todos.isEmpty
        addTodoBtn?.isEnabled    = todos.filter({ !$0.isFinished }).count < 5
        
        tableView?.reloadData()
    }
    
    /// 同步数据到iCloud
    ///
    /// - Returns: url
    private func syncTodoToCloud() -> Observable<URL> {
        
        return Observable.create({ (observer) -> Disposable in
            
            guard let cloudUrl = self.ubiquityURL("Documents/TodoList.plist") else {
                
                self.flash(title: "Failed",
                           message: "You should enabled iCloud in Settings first.")
                
                return Disposables.create()
            }
            
            guard let localData = NSData(contentsOf: self.dataFilePath()) else {
                self.flash(title: "Failed",
                           message: "Cannot read local file.")
                
                return Disposables.create()
            }
            
            let plist = PlistDocument(fileURL: cloudUrl, data: localData)
            
            plist.save(to: cloudUrl, for: .forOverwriting, completionHandler: {
                (success: Bool) -> Void in
                print(cloudUrl)
                
                if success {
                    observer.onNext(cloudUrl)
                    observer.onCompleted()
                } else {
                    observer.onError(SaveTodoError.cannotCreateFileOnCloud)
                }
            })
            
            return Disposables.create()
        })
    }
    
    
    func ubiquityURL(_ filename: String) -> URL? {
        let ubiquityURL =
            FileManager.default.url(forUbiquityContainerIdentifier: nil)
        
        if ubiquityURL != nil {
            return ubiquityURL!.appendingPathComponent("filename")
        }
        
        return nil
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return todoItems.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCellIndentifier", for: indexPath) as? TodoItemCell {

            let todo = todoItems.value[indexPath.row]

            cell.item.accept(todo)

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 45
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {

            let todo = todoItems.value[indexPath.row]

            todo.toggleFinished()

            cell.item.accept(todo)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let detail = TodoDetailViewController()
        
        detail.title    = "Edit todo"
        detail.todoItem = showItems[indexPath.row]
        
        _ = detail.todo.subscribe(onNext: { [weak self] (editTodo) in
            
            guard let `self` = self else { return }
            
            self.todoItems.accept(self.showItems)
            
            }, onDisposed: {
                
                print("Finish editing a todo.")
            })
        
        navigationController?.present(UINavigationController(rootViewController: detail), animated: true, completion: nil)
    }
}

/*
 以下为rx绑定的方式
 */
//// MARK: - UITableViewDelegate
//extension TodoListViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        if let cell = tableView.cellForRow(at: indexPath) as? TodoItemCell {
//
//            let todo = todoItems.value[indexPath.row]
//
//            todo.toggleFinished()
//
//            cell.item.accept(todo)
//        }
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}

//// MARK: - rx
//extension TodoListViewController {
//
//    private func rxBind() {
//
//        // 将数据源数据绑定到tableView上
//        todoItems.bind(to: tableView!.rx.items(cellIdentifier: "TodoItemCellIndentifier")) { _, todo, originCell in
//
//            if let cell = originCell as? TodoItemCell {
//
//                cell.item.accept(todo)
//            }
//
//        }.disposed(by: bag)
//
////        tableView?.rx.modelSelected(TodoItem.self).subscribe(onNext: { (todo) in
////
////        }).disposed(by: bag)
//    }
//}
