//
//  TodoItemCell.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/10/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class TodoItemCell: UITableViewCell {
    
    var item = PublishRelay<TodoItem>()
    
    private let bag = DisposeBag()
    
    var markLabel: UILabel  = UILabel()
    var titleLabel: UILabel = UILabel()

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
extension TodoItemCell {
    
    private func setupUI() {
        
        accessoryType = .detailDisclosureButton
        
        markLabel.textColor = UIColor.blue
        markLabel.font = UIFont.systemFont(ofSize: 25)
        
        addSubview(markLabel)
        
        markLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
        }
        
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            
            make.left.equalTo(markLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - rx
extension TodoItemCell {
    
    private func handleRx() {
        
        item.subscribe(onNext: { [weak self] (item) in
            
            guard let `self` = self else { return }
            
            self.markLabel.text  = item.isFinished ? "✓" : ""
            self.titleLabel.text = item.name
        })
        .disposed(by: bag)
    }
}
