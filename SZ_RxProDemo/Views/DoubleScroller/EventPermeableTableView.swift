//
//  EventPermeableTableView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2019/1/2.
//  Copyright © 2019年 SZ. All rights reserved.
//

import UIKit

/// 事件可穿透的 table（能实现两个scroller同时滚动的核心类）
class EventPermeableTableView: UITableView {

    // 事件可穿透的view array
    var permeableViews: [UIScrollView] = []
    
    // MARK: - override
    
    override init(frame: CGRect, style: UITableView.Style) {
        
        super.init(frame: frame, style: style)
        
        initProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EventPermeableTableView: UIGestureRecognizerDelegate {
    
    // 返回true表示可以继续传递触摸事件，这样两个嵌套的scrollView才能同时滚动
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var view = otherGestureRecognizer.view
        
        if let superV = view?.superview,
            superV.isKind(of: UIWebView.self) {
            
            view = superV
        }
        
        if let v = view as? UIScrollView,
            permeableViews.count > 0,
            permeableViews.contains(v) {
            
            return true
        }
        
        return false
    }
}

// MARK: - private method
extension EventPermeableTableView {
    
    /// 初始化属性
    private func initProperty() {
        
        // 在某些情况下，contentView中的点击事件会被panGestureRecognizer拦截，导致不能响应，
        // 所以这里设置cancelsTouchesInView表示不拦截，避免异常情况
        panGestureRecognizer.cancelsTouchesInView = false
    }
}

// MARK: ---------------------------- 分割线 ----------------------------

/// 事件可穿透的 scroller（能实现两个scroller同时滚动的核心类）
class EventPermeableScrollerView: UIScrollView {
    
    // 事件可穿透的view array
    var permeableViews: [UIScrollView] = []
    
    // MARK: - override
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EventPermeableScrollerView: UIGestureRecognizerDelegate {
    
    // 返回YES表示可以继续传递触摸事件，这样两个嵌套的scrollView才能同时滚动
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var view = otherGestureRecognizer.view
        
        if let superV = view?.superview,
            superV.isKind(of: UIWebView.self) {
            
            view = superV
        }
        
        if let v = view as? UIScrollView,
            permeableViews.count > 0,
            permeableViews.contains(v) {
            
            return true
        }
        
        return false
    }
}

// MARK: - private method
extension EventPermeableScrollerView {
    
    /// 初始化属性
    private func initProperty() {
        
        // 在某些情况下，contentView中的点击事件会被panGestureRecognizer拦截，导致不能响应，
        // 所以这里设置cancelsTouchesInView表示不拦截，避免异常情况
        panGestureRecognizer.cancelsTouchesInView = false
    }
}
