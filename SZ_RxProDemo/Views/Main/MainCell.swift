//
//  MainCell.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/8.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

/// 主页 cell
class MainCell: UITableViewCell {

    var item = PublishRelay<MainItem>()
    
    private let bag = DisposeBag()
    
    var nameLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        handleRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension MainCell {
    
    private func setupUI() {
        
        accessoryType = .detailDisclosureButton
        
        nameLabel.textColor = UIColor.darkText
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - rx
extension MainCell {
    
    private func handleRx() {
        
        item.subscribe(onNext: { [weak self] (item) in
            
            guard let `self` = self else { return }
            
            self.nameLabel.text  = item.demoName
            
        }).disposed(by: bag)
    }
}

