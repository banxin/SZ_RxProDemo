//
//  WeekWeatherTableViewCell.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

/// 天气预报 cell
class WeekWeatherTableViewCell: UITableViewCell {
    
    var item = PublishRelay<WeatherData>()
    
    private let bag = DisposeBag()
    
    /// 星期
    var week: UILabel = UILabel(title: "", fontSize: 20, color: UIColor.colorWithHex(hexString: "EE4D37"))
    /// 日期
    var date: UILabel = UILabel(title: "", fontSize: 14, color: UIColor.colorWithHex(hexString: "4A4A4A"))
    /// 温度
    var temperature: UILabel = UILabel(title: "", fontSize: 17, color: UIColor.colorWithHex(hexString: "4A4A4A"))
    /// 天气
    var weatherIcon: UIImageView = UIImageView()
    /// 湿度
    var humid: UILabel = UILabel(title: "", fontSize: 17, color: UIColor.colorWithHex(hexString: "4A4A4A"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension WeekWeatherTableViewCell {
    
    private func setupUI() {
    
        week.font = UIFont(name: "PingFangSC-Semibold", size: 20)
        date.font = UIFont(name: "PingFangSC-Semibold", size: 17)
        humid.textAlignment = .right
        
        addSubview(week)
        addSubview(date)
        addSubview(temperature)
        addSubview(weatherIcon)
        addSubview(humid)
        
        layoutViews()
    }
    
    private func layoutViews() {
        
        weatherIcon.snp.makeConstraints { (maker) in
            
            maker.left.top.equalTo(11)
            maker.right.equalTo(-15)
            maker.size.equalTo(CGSize(width: 58, height: 58))
        }
        
        week.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(8)
            maker.left.equalTo(15)
            maker.right.equalTo(self.weatherIcon.snp.left).offset(-8)
        }
        
        date.snp.makeConstraints { (maker) in
            
            maker.left.right.equalTo(self.week)
            maker.top.equalTo(self.week.snp.bottom).offset(8)
        }
        
        temperature.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(self.date.snp.bottom).offset(8)
            maker.left.equalTo(self.week)
            maker.right.equalTo(self.humid.snp.left)
        }
        
        humid.snp.makeConstraints { (maker) in
            
            maker.top.equalTo(self.date.snp.bottom).offset(8)
            maker.right.equalTo(self.weatherIcon)
            maker.left.equalTo(self.temperature.snp.right)
        }
    }
}

// MARK: - private method
extension WeekWeatherTableViewCell {
    
    
}
