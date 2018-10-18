//
//  TodoDetailViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/10/11.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

/// detail 主体类
class TodoDetailViewController: UIViewController {
    
    // 为了避免todoSubject意外从TodoDetailViewController外部接受onNext事件，我们把它定义成了fileprivate属性。
    // 对外，只提供了一个仅供订阅的Observable属性todo.
    fileprivate let todoSubject = PublishSubject<TodoItem>()
    
    var todo: Observable<TodoItem> {
        
        return self.todoSubject.asObserver()
    }
    
    // 添加一个保存Todo内容的属性
    var todoItem: TodoItem!
    
    fileprivate let images = BehaviorRelay<[UIImage]>(value: [])
    
    private var imagesAry: [UIImage] = []
    
    fileprivate var todoImage: UIImage?
    
    /// rx资源回收bag
    private let bag: DisposeBag = DisposeBag()
    
    private var doneBtn: UIBarButtonItem?
    
    private let nameTextField: UITextField = UITextField()
    private let finishSwitch: UISwitch = UISwitch()
    private let picTitle: UILabel = UILabel()
    private let picBtn: UIButton = UIButton()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        rxBind()
        checkTodoItem()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//        super.viewWillAppear(animated)
//
//        if todoItem.name != "" {
//
//            nameTextField.text = todoItem.name
//            finishSwitch.isOn  = todoItem.isFinished
//        }
//    }
    
    // MARK: - test source release
    deinit {
        
        print("detail -------> release")
    }
}

// MARK: - UI
extension TodoDetailViewController {
    
    /// 设置UI
    private func setupUI() {
        
        setupNavBtns()
        setupMainView()
        
        nameTextField.becomeFirstResponder()
    }
    
    /// 设置nav按钮
    private func setupNavBtns() {
        
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil)
        
        navigationItem.leftBarButtonItem = cancelBtn
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
        
        doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: nil)
        
        navigationItem.rightBarButtonItem = doneBtn
        
        doneBtn?.rx.tap
            .subscribe(onNext: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.done()
            })
            .disposed(by: bag)
    }
    
    /// 设置主视图
    private func setupMainView() {
        
        let scroller = UIScrollView(frame: CGRect(x: 0, y: UIScreen.main.sz_navHeight, width: UIScreen.main.sz_screenWidth, height: UIScreen.main.sz_screenHeight - UIScreen.main.sz_navHeight))
        
        scroller.backgroundColor = UIColor.colorWithHex(hexString: "f1f2f3")
        scroller.alwaysBounceVertical = true
        
        view.addSubview(scroller)
        
        let nameTitle: UILabel = UILabel()
        
        nameTitle.font = UIFont.systemFont(ofSize: 14)
        nameTitle.text = "TASK NAME"
        nameTitle.textColor = UIColor.lightGray
        
        scroller.addSubview(nameTitle)
        
        nameTitle.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.top.equalTo(30)
        }
        
        let nameContent: UIView = UIView()
        
        nameContent.backgroundColor = UIColor.white
        
        scroller.addSubview(nameContent)
        
        nameContent.snp.makeConstraints { (make) in
            
            make.top.equalTo(nameTitle.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(UIScreen.main.sz_screenWidth)
        }
        
        nameTextField.textColor       = UIColor.colorWithHex(hexString: "444444")
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.font            = UIFont.systemFont(ofSize: 16)
        nameTextField.placeholder     = "inpute task name"
        nameTextField.borderStyle     = .none
        
        nameContent.addSubview(nameTextField)
        
        nameTextField.snp.makeConstraints { (make) in
            
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: UIScreen.main.sz_screenWidth - 20, height: 20))
        }
        
        let statusTitle: UILabel = UILabel()
        
        statusTitle.font = UIFont.systemFont(ofSize: 14)
        statusTitle.text = "STATUS"
        statusTitle.textColor = UIColor.lightGray
        
        scroller.addSubview(statusTitle)
        
        statusTitle.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.top.equalTo(nameContent.snp.bottom).offset(30)
        }
        
        let finishContent: UIView = UIView()
        
        finishContent.backgroundColor = UIColor.white
        
        scroller.addSubview(finishContent)
        
        finishContent.snp.makeConstraints { (make) in
            
            make.top.equalTo(statusTitle.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(UIScreen.main.sz_screenWidth)
        }
        
        let finishTitle: UILabel = UILabel()
        
        finishTitle.font = UIFont.systemFont(ofSize: 17)
        finishTitle.text = "Finished"
        finishTitle.textColor = UIColor.colorWithHex(hexString: "444444")
        
        finishContent.addSubview(finishTitle)
        
        finishTitle.snp.makeConstraints { (make) in
            
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        finishSwitch.isOn = false
        
        finishContent.addSubview(finishSwitch)
        
        finishSwitch.snp.makeConstraints { (make) in
            
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
        
        picTitle.font = UIFont.systemFont(ofSize: 14)
        picTitle.text = "PICTURES MEMO"
        picTitle.textColor = UIColor.lightGray
        
        scroller.addSubview(picTitle)
        
        picTitle.snp.makeConstraints { (make) in
            
            make.left.equalTo(15)
            make.top.equalTo(finishContent.snp.bottom).offset(30)
        }
        
        let picContent: UIView = UIView()
        
        picContent.backgroundColor = UIColor.white
        
        scroller.addSubview(picContent)
        
        picContent.snp.makeConstraints { (make) in
            
            make.top.equalTo(self.picTitle.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.height.equalTo(180)
            make.width.equalTo(UIScreen.main.sz_screenWidth)
        }
        
        picBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        picBtn.setTitleColor(UIColor.colorWithHex(hexString: "6666FF"), for: .normal)
        picBtn.setTitle("Tap here to add your picture memos", for: .normal)
        
        picContent.addSubview(picBtn)
        
        picBtn.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - data handle
extension TodoDetailViewController {
    
    /// rx绑定
    private func rxBind() {
        
        // 对名称进行限制（空 或 字数超过100时，不允许点击完成）
        nameTextField.rx.text.orEmpty.subscribe(onNext: { [weak self] in
            
            self?.doneBtn?.isEnabled = !($0.isEmpty || $0.count > 100)
        })
        .disposed(by: bag)
        
        picBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            
            guard let `self` = self else { return }
            
            self.toPhotoPickVC()
        })
        .disposed(by: bag)
        
        images.asObservable().subscribe(onNext: { [weak self] (images) in
            
            guard let `self` = self else { return }
            
            guard !images.isEmpty else {
                
                self.resetMemoBtn()
                return
            }
            
            /// 1. Merge photos
            self.todoImage = UIImage.collage(images: images, in: CGSize(width: UIScreen.main.sz_screenWidth, height: 180))
            
            /// 2. Set the merged photo as the button background
            self.setMemoBtn(bkImage: self.todoImage ?? UIImage())
            
        }).disposed(by: bag)
    }
    
    private func checkTodoItem() {
        
        if let todoItem = todoItem {
            
            nameTextField.text = todoItem.name
            finishSwitch.isOn  = todoItem.isFinished
            
            if todoItem.pictureMemoFilename != "" {
                
                let url = getDocumentsDir().appendingPathComponent(todoItem.pictureMemoFilename)
                
                if let data = try? Data(contentsOf: url) {
                    
                    self.todoImage = UIImage(data: data)
                    
                    self.picBtn.setBackgroundImage(self.todoImage, for: .normal)
                    self.picBtn.setTitle("", for: .normal)
                }
            }
            
            // FIXME: - 图片暂时先不必传
//            doneBtn?.isEnabled = true
            
        } else {
            
            todoItem = TodoItem()
        }
    }
}

// MARK: - private method
extension TodoDetailViewController {
    
    /// 处理Done事件
    private func done() {
        
        todoItem.name       = nameTextField.text ?? ""
        todoItem.isFinished = finishSwitch.isOn
        todoItem.pictureMemoFilename = savePictureMemos()
        
        todoSubject.onNext(todoItem)
        
        dismiss(animated: true, completion: nil)
        
        // dismiss 之后，也不需要再做任何操作，释放资源
        todoSubject.onCompleted()
    }
    
    /// 去图片选择
    private func toPhotoPickVC() {
        
        let photoCollectionViewController = PhotoCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        imagesAry.removeAll()
        
        // 移除所有image
        images.accept(imagesAry)
        
        resetMemoBtn()
        
        // 有bug的方式，不过可以当做学习
        let selectedPhotos = photoCollectionViewController.selectedPhotos
        
        // scan 处理后 再 订阅
        _ = selectedPhotos.scan(into: self.imagesAry, accumulator: { (photos, newPhoto) in

            // FIXME: - 没看懂  @山竹
            if let index = photos.index(where: { UIImage.isEqual(lhs: newPhoto, rhs: $0) }) {
                
                photos.remove(at: index)
                
            } else {
                
                photos.append(newPhoto)
            }
        })
        .subscribe(onNext: { (photos) in

            self.imagesAry = photos
            self.images.accept(self.imagesAry)

        }, onDisposed: {

            print("Finished choose photo memos.")
        })
        .disposed(by: photoCollectionViewController.bag)
        
        selectedPhotos.ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                
                guard let `self` = self else { return }
                
                self.setMemoSectionHederText()
            })
            .disposed(by: photoCollectionViewController.bag)
        
        // 单纯订阅
//        _ = selectedPhotos.subscribe({ [weak self] (image) in
//            
//            guard let `self` = self else { return }
//            
//            if let i = image.element {
//                
//                self.imagesAry.append(i)
//                
//                self.images.accept(self.imagesAry)
//            }
//            
//        }).disposed(by: photoCollectionViewController.bag)
        
        navigationController?.pushViewController(photoCollectionViewController, animated: true)
    }
    
    fileprivate func getDocumentsDir() -> URL {
        
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    fileprivate func resetMemoBtn() {
        
        // Todo: Reset the add picture memo btn style
        picBtn.setImage(nil, for: .normal)
        picBtn.setTitle("Tap here to add your picture memos", for: .normal)
    }
    
    fileprivate func setMemoBtn(bkImage: UIImage) {
        
        // Todo: Set the background and title of add picture memo btn
        picBtn.setImage(bkImage, for: .normal)
        picBtn.setTitle("", for: .normal)
    }
    
    fileprivate func savePictureMemos() -> String {
        
        // Todo: Save the picture memos preview as a png
        // file and return its file name.
        
        if let todoCollage = self.todoImage,
            let data = todoCollage.pngData() {
            
            let path = getDocumentsDir()
            let filename = self.nameTextField.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)
            
            try? data.write(to: memoImageUrl)
            
            return filename
        }
        
        return self.todoItem.pictureMemoFilename
    }
    
    fileprivate func setMemoSectionHederText() {
        
        // Todo: Set section header to the number of
        // pictures selected.
        guard !images.value.isEmpty else { return }
        
        picTitle.text? = "\(images.value.count) MEMOS"
    }
}
