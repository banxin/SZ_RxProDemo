//
//  DoubleScrollerView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2019/1/2.
//  Copyright © 2019年 SZ. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Then

private let kDoubleScrollerCellReuseIdentifier = "kDoubleScrollerCellReuseIdentifier"

/// 两个 scroller 滚动 view
class DoubleScrollerView: UIView {
    
    /// rx资源回收bag
//    private let bag: DisposeBag = DisposeBag()
    
    /// 容器是否可以滚动
    private var canScroll: Bool = true
    
    /// 内容是否可以滚动
    private var canContentScroll: Bool = false

    // 品牌view 100
    private var brandView: UIView = UIView().then {
        
        $0.backgroundColor = UIColor.blue
    }
    
    // 排序view 40
    private var sortView: UIView = UIView().then {
        
        $0.backgroundColor = UIColor.green
    }
    
    // 筛选view 40
    private var filterView: UIView = UIView().then {
        
        $0.backgroundColor = UIColor.purple
    }
    
    // 滚动view
    private var scrollerView = EventPermeableScrollerView().then {
        
//        $0.backgroundColor      = UIColor.colorWithHex(hexString: "f1f2f3")
        $0.backgroundColor      = UIColor.colorWithHex(hexString: "ff0000")
        $0.alwaysBounceVertical = true
//        $0.contentSize          = CGSize(width: UIScreen.main.sz_screenWidth,
//                                         height: UIScreen.main.sz_screenHeight - UIScreen.main.sz_navHeight)
    }
    
    // tableview
    private var tableView = EventPermeableTableView().then {
        
        $0.backgroundColor = UIColor.colorWithHex(hexString: "f8f8f8")
        $0.tableFooterView = UIView()
        $0.register(UITableViewCell.self, forCellReuseIdentifier: kDoubleScrollerCellReuseIdentifier)
//        $0.contentInset    = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
    }
    
    private var sz_nestView = SZNestTableView()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI(frame: frame)
//        rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension DoubleScrollerView {
    
    /// 设置UI
    private func setupUI(frame: CGRect) {
        
        backgroundColor = UIColor.white
        
        sz_nestView = SZNestTableView()
        
        addSubview(sz_nestView)
        
        sz_nestView.snp.makeConstraints { (maker) in

            maker.edges.equalToSuperview()
        }
        
//        scrollerView.delegate = self
//        addSubview(scrollerView)
//
//        scrollerView.addSubview(brandView)
//        scrollerView.addSubview(sortView)
//        scrollerView.addSubview(filterView)
//
//        tableView.permeableViews = [scrollerView]
//        tableView.delegate   = self
//        tableView.dataSource = self
//
////        scrollerView.permeableViews = [tableView]
//
//        scrollerView.addSubview(tableView)
//
//        layoutViews()
    }
    
    private func layoutViews() {
        
        scrollerView.snp.makeConstraints { (maker) in
            
            maker.edges.equalToSuperview()
        }
        
        brandView.snp.makeConstraints { (maker) in
            
            maker.left.top.equalToSuperview()
            maker.width.equalTo(UIScreen.main.sz_screenWidth)
            maker.height.equalTo(168)
        }
        
        sortView.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(self.brandView.snp.bottom)
            maker.left.equalToSuperview()
            maker.width.equalTo(UIScreen.main.sz_screenWidth)
            maker.height.equalTo(40)
        }
        
        filterView.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(self.sortView.snp.bottom)
            maker.left.equalToSuperview()
            maker.width.equalTo(UIScreen.main.sz_screenWidth)
            maker.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(self.filterView.snp.bottom)
            maker.left.equalToSuperview()
            maker.width.equalTo(UIScreen.main.sz_screenWidth)
            maker.height.equalTo(UIScreen.main.sz_screenHeight - UIScreen.main.sz_navHeight - 248)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension DoubleScrollerView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kDoubleScrollerCellReuseIdentifier, for: indexPath)
        
        cell.selectionStyle  = .none
        cell.accessoryType   = .disclosureIndicator
        cell.textLabel?.text = "Test - \(indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
}

// MARK: - UIScrollerViewDelegate
extension DoubleScrollerView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 当为自身滚动的时候
        if let v = scrollView as? EventPermeableScrollerView,
            v.isKind(of: EventPermeableScrollerView.self) {
            
            let contentOffet: CGFloat = UIScreen.main.sz_navHeight
            
            if !canScroll {
                
                // 这里通过固定contentOffset的值，来实现不滚动
                scrollView.contentOffset = CGPoint(x: 0, y: contentOffet)
                
            } else if scrollView.contentOffset.y >= contentOffet {
                
                scrollView.contentOffset = CGPoint(x: 0, y: contentOffet)
                
                setupScrollerStatue(statue: false)
                
//                canScroll = false
                canContentScroll = true
            }
            
            scrollView.showsVerticalScrollIndicator = canScroll
            
        } else {
            
            if !canContentScroll {
                
                // 这里通过固定contentOffset，来实现不滚动
                scrollView.contentOffset = CGPoint.zero
                
            } else if scrollView.contentOffset.y <= 0 {
                
                canContentScroll = false
                // 通知容器可以开始滚动
                setupScrollerStatue(statue: true)
//                canScroll = true
            }
            
            scrollView.showsVerticalScrollIndicator = canContentScroll
        }
    }
}

// MARK: - private method
extension DoubleScrollerView {
    
    private func rxBind() {
        
        //        // 将数据源数据绑定到tableView上
        //        showArray.bind(to: tableView.rx.items(cellIdentifier: kDoubleScrollerCellReuseIdentifier)) { (_, demoName, originCell) in
        //
        //            originCell.selectionStyle  = .none
        //            originCell.accessoryType   = .disclosureIndicator
        //            originCell.textLabel?.text = demoName
        //
        //        }.disposed(by: bag)
    }
    
    private func setupScrollerStatue(statue: Bool) {
        
        if canScroll == statue { return }
        
        canScroll = statue
        
        contentScroller()
    }
    
    private func contentScroller() {
        
        // 当容器开始可以滚动时，将所有内容设置回到顶部
        tableView.contentOffset = CGPoint.zero
    }
}

