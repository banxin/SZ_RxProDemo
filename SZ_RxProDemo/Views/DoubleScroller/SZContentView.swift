//
//  SZContentView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2019/1/3.
//  Copyright © 2019 SZ. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

private let kSZContentViewCellReuseIdentifier = "kSZContentViewCellReuseIdentifier"

/// ContentView
class SZContentView: UIView {
    
    /// 展示数据
    private var showArray = BehaviorRelay<[String]>(value: ["test1",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2",
                                                            "test2"])
    
    fileprivate let superScrollerSubject = PublishSubject<Bool>()
    
    var superScroller: Observable<Bool> {
        
        return self.superScrollerSubject.asObserver()
    }
    
    /// rx资源回收bag
    let bag: DisposeBag = DisposeBag()

    // tableview
    var tableView = UITableView().then {
        
        $0.backgroundColor = UIColor.colorWithHex(hexString: "f8f8f8")
        $0.tableFooterView = UIView()
        $0.dataSource      = nil
        $0.delegate        = nil
        $0.register(UITableViewCell.self, forCellReuseIdentifier: kSZContentViewCellReuseIdentifier)
    }
    
    // 内容是否可以滚动
    var canContentScroll = false

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
//        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension SZContentView {
    
    /// 设置UI
    private func setupUI() {
        
        tableView.dataSource = self
        tableView.delegate   = self
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (maker) in
            
            maker.edges.equalToSuperview()
        }
    }
}

// MARK: - private method
extension SZContentView {
    
    private func rxBind() {
        
        // 将数据源数据绑定到tableView上
        showArray.bind(to: tableView.rx.items(cellIdentifier: kSZContentViewCellReuseIdentifier)) { (_, demoName, originCell) in
            
            originCell.selectionStyle  = .none
            originCell.accessoryType   = .disclosureIndicator
            originCell.textLabel?.text = demoName
            
        }.disposed(by: bag)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SZContentView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kSZContentViewCellReuseIdentifier, for: indexPath)
        
        cell.selectionStyle  = .none
        cell.accessoryType   = .disclosureIndicator
        cell.textLabel?.text = "Test - \(indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
}

// MARK: - UIScrollViewDelegate
extension SZContentView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("scrollView.contentOffset.y --> \(scrollView.contentOffset.y)")
        
        if !canContentScroll {

            // 这里通过固定contentOffset，来实现不滚动
            scrollView.contentOffset = CGPoint.zero

        } else if scrollView.contentOffset.y <= 0 {

            canContentScroll = false
            // 通知容器可以开始滚动
            superScrollerSubject.onNext(true)
        }

        scrollView.showsVerticalScrollIndicator = canContentScroll
    }
}
