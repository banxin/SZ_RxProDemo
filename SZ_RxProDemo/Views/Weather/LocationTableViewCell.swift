//
//  LocationTableViewCell.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class LocationTableViewCell: UITableViewCell {
    
    var title: UILabel = UILabel(title: "", fontSize: 17, color: UIColor.darkText)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationTableViewCell {
    
    private func setupUI() {
        
        selectionStyle = .none
        
        addSubview(title)
        
        title.snp.makeConstraints { (maker) in
            
            maker.centerY.equalToSuperview()
            maker.left.equalTo(15)
        }
    }
}

extension LocationTableViewCell {
    
    func configure(with viewModel: LocationRepresentable) {
        
        title.text = viewModel.labelText
    }
}
