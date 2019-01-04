//
//  DoubleScrollerViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2019/1/2.
//  Copyright © 2019年 SZ. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import Then
import SnapKit

/// 双scroller滚动
class DoubleScrollerListViewController: UIViewController {
    
    private var listView: DoubleScrollerView = DoubleScrollerView(frame: CGRect(x: 0, y: UIScreen.main.sz_navHeight, width: UIScreen.main.sz_screenWidth, height: UIScreen.main.sz_screenHeight - UIScreen.main.sz_navHeight))

    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }
}

// MARK: - UI
extension DoubleScrollerListViewController {
    
    /// 设置UI
    private func setupUI() {

        automaticallyAdjustsScrollViewInsets = false
        title = "双Scroller滚动"
        
        listView.backgroundColor = UIColor.red
//        listView.frame = CGRect(x: 0, y: UIScreen.main.sz_navHeight, width: UIScreen.main.sz_screenWidth, height: UIScreen.main.sz_screenHeight - UIScreen.main.sz_navHeight)
        
        view.addSubview(listView)
        
//        layoutViews()
    }
    
    private func layoutViews() {
        
//        listView.snp.makeConstraints { (maker) in
//
//            maker.edges.equalToSuperview()
//        }
    }
}

// MARK: - private method
extension DoubleScrollerListViewController {
    
    
}
