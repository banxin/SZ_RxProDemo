//
//  WeatherForecastView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/// 天气预报view
class WeatherForecastView: UIView {

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI
extension WeatherForecastView {
    
    private func setupUI() {
    
        backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        
        let l = UILabel(title: "天气预报暂未实现，敬请期待！", fontSize: 14, color: UIColor.colorWithHex(hexString: "ed3a4a"))
        
        l.textAlignment = .center
        
        addSubview(l)
        
        l.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
    }
}
