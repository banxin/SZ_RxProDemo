//
//  SZNestTableView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2019/1/3.
//  Copyright © 2019 SZ. All rights reserved.
//

import UIKit

import Then

private let kSZNestTableViewCellReuseIdentifier = "kSZNestTableViewCellReuseIdentifier"

/// 多层滚动的 tableview
class SZNestTableView: UIView {
    
    /// 品牌
    var brandView: UIView = UIView().then {
        
        $0.backgroundColor = UIColor.blue
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.sz_screenWidth, height: 148)
    }
    /// 排序
    var sortView: UIView = UIView().then {
    
        $0.backgroundColor = UIColor.green
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.sz_screenWidth, height: 40)
    }
    /// 内容
    var contentView: SZContentView = SZContentView().then {
        
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.sz_screenWidth, height: UIScreen.main.sz_screenHeight - 148)
        $0.backgroundColor = UIColor.purple
    }
    /// 设置容器是否可以滚动
    var canScroll: Bool = true
    /// 允许手势传递的view列表
    var allowGestureEventPassViews: [UIScrollView] = []
    
    // tableview
    private var tableView = EventPermeableTableView().then {
        
        $0.backgroundColor = UIColor.colorWithHex(hexString: "f8f8f8")
        $0.tableFooterView = UIView()
        $0.register(UITableViewCell.self, forCellReuseIdentifier: kSZNestTableViewCellReuseIdentifier)
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI(frame: frame)
        initProperties()
        rxHandle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension SZNestTableView {
    
    private func setupUI(frame: CGRect) {
    
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView = brandView
        tableView.tableFooterView = UIView()
        
//        tableView.frame = frame
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (maker) in
            
            maker.edges.equalToSuperview()
        }
    }
}

// MARK: - public method
extension SZNestTableView {
    
    // 返回容器可以滑动的高度
    // 超过这个高度，canScroll会设置为NO，并且会调用delegate中的nestTableViewContentCanScroll:
    func heightForContainerCanScroll() -> CGFloat {
        
        if let _ = tableView.tableHeaderView {
            
            return 148
        }
        
        return 0
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SZNestTableView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kSZNestTableViewCellReuseIdentifier, for: indexPath)
        
        cell.contentView.addSubview(contentView)
        cell.selectionStyle  = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return contentView.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return sortView
    }
}

// MARK: - UIScrollViewDelegate
extension SZNestTableView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset = heightForContainerCanScroll()
        
        if !canScroll {
            
            // 这里通过固定contentOffset的值，来实现不滚动
            scrollView.contentOffset = CGPoint(x: 0, y: contentOffset)
            
        } else if scrollView.contentOffset.y >= contentOffset {
            
            scrollView.contentOffset = CGPoint(x: 0, y: contentOffset)
            canScroll = false
            
            // 通知delegate内容开始可以滚动
//            if (self.delegate && [self.delegate respondsToSelector:@selector(nestTableViewContentCanScroll:)]) {
//                [self.delegate nestTableViewContentCanScroll:self];
//            }
            contentView.canContentScroll = true
        }
        
        scrollView.showsVerticalScrollIndicator = canScroll
        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(nestTableViewDidScroll:)]) {
//            [self.delegate nestTableViewDidScroll:_tableView];
//        }
    }
}

// MARK: - private method
extension SZNestTableView {
    
    private func initProperties() {
        
        allowGestureEventPassViews = [contentView.tableView]
        tableView.permeableViews = allowGestureEventPassViews
    }
    
    private func resizeContentHeight() {
        
        let contentHeight = UIScreen.main.sz_screenHeight - 148
        
        contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.sz_screenWidth, height: contentHeight)
    }
    
    private func rxHandle() {
        
        contentView.superScroller.subscribe(onNext: { [weak self] (can) in
            
            guard let `self` = self else { return }
            
            if self.canScroll == can { return }
            
            self.canScroll = can
            
            // 当容器开始可以滚动时，将所有内容设置回到顶部
            self.contentView.tableView.contentOffset = CGPoint.zero
        })
        .disposed(by: contentView.bag)
    }
}
