//
//  CurrentWeatherView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

protocol CurrentWeatherViewDelegate: class {
    
    func locationButtonPressed()
    func settingsButtonPressed()
}

/// 当前天气view (254 height)
class CurrentWeatherView: UIView {
    
    /// 加载中 activity
    private var activityIndicatorView = UIActivityIndicatorView()
    /// 加载失败 label
    private var loadingFailedLabel = UILabel(title: "", fontSize: 17, color: UIColor.darkText)
    /// 天气 Container
    private lazy var weatherContainerView: UIView = UIView()
    /// 位置图片
    private lazy var locationImage: UIImageView = UIImageView(image: UIImage(named: "LocationBtn"))
    /// 设置图片
    private lazy var settingsImage: UIImageView = UIImageView(image: UIImage(named: "Setting"))
    /// 位置name
    private lazy var locationLabel: UILabel = UILabel(title: "Beijing", fontSize: 26, color: UIColor.darkText)
    /// 温度
    private lazy var temperatureLabel: UILabel = UILabel(title: "33.5 ℃", fontSize: 28, color: UIColor.darkText)
    /// 天气图标
    private lazy var weatherIcon: UIImageView = UIImageView(image: UIImage(named: "clear-day"))
    /// 湿度
    private lazy var humidityLabel: UILabel = UILabel(title: "63 %", fontSize: 28, color: UIColor.darkText)
    /// 天气文字
    private lazy var summaryLabel: UILabel = UILabel(title: "Clear", fontSize: 16, color: UIColor.darkText)
    /// 日期
    private lazy var dateLabel: UILabel = UILabel(title: "Mon, 25 September", fontSize: 16, color: UIColor.colorWithHex(hexString: "EE4D37"))
    
    weak var delegate: CurrentWeatherViewDelegate?
    
    var now: WeatherData? {
        
        didSet {
            DispatchQueue.main.async { self.updateView() }
        }
    }
    
    var location: Location? {
        
        didSet {
            DispatchQueue.main.async { self.updateView() }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension CurrentWeatherView {
    
    /// 设置UI
    private func setupUI() {
        
        activityIndicatorView.style = .gray
        loadingFailedLabel.textAlignment = .center
        
        locationLabel.textAlignment    = .center
        temperatureLabel.textAlignment = .center
        humidityLabel.textAlignment    = .center
        summaryLabel.textAlignment     = .center
        dateLabel.textAlignment        = .center
        
        temperatureLabel.font = UIFont(name: "PingFangSC-Thin", size: 28)
        humidityLabel.font    = UIFont(name: "PingFangSC-Thin", size: 28)
        summaryLabel.font     = UIFont.italicSystemFont(ofSize: 16)
        dateLabel.font        = UIFont(name: "PingFangSC-Medium", size: 16)
        
        addSubview(loadingFailedLabel)
        addSubview(activityIndicatorView)
        addSubview(weatherContainerView)
        
        weatherContainerView.addSubview(locationImage)
        weatherContainerView.addSubview(settingsImage)
        weatherContainerView.addSubview(locationLabel)
        weatherContainerView.addSubview(temperatureLabel)
        weatherContainerView.addSubview(weatherIcon)
        weatherContainerView.addSubview(humidityLabel)
        weatherContainerView.addSubview(summaryLabel)
        weatherContainerView.addSubview(dateLabel)
        
        layoutViews()
        
        weatherContainerView.isHidden = true
        loadingFailedLabel.isHidden = true
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        
        addTouchEvent()
    }
    
    private func layoutViews() {
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
        
        loadingFailedLabel.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
        
        weatherContainerView.snp.makeConstraints { (maker) in
            
            maker.edges.equalToSuperview()
        }
        
        locationImage.snp.makeConstraints { (maker) in
            
            maker.left.top.equalTo(8)
            maker.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        settingsImage.snp.makeConstraints { (maker) in
            
            maker.right.equalTo(-8)
            maker.top.size.equalTo(self.locationImage)
        }
        
        weatherIcon.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
            maker.size.equalTo(CGSize(width: 128, height: 128))
        }
        
        locationLabel.snp.makeConstraints { (maker) in
            
            maker.left.equalTo(self.locationImage.snp.right)
            maker.right.equalTo(self.settingsImage.snp.left)
            maker.centerY.equalTo(self.locationImage)
        }
        
        temperatureLabel.snp.makeConstraints { (maker) in
            
            maker.left.equalTo(self.locationImage)
            maker.centerY.equalTo(self.weatherIcon)
            maker.right.equalTo(self.weatherIcon.snp.left)
        }
        
        humidityLabel.snp.makeConstraints { (maker) in
            
            maker.right.equalTo(self.settingsImage)
            maker.centerY.equalTo(self.weatherIcon)
            maker.left.equalTo(self.weatherIcon.snp.right)
        }
        
        summaryLabel.snp.makeConstraints { (maker) in
            
            maker.centerX.equalToSuperview()
            maker.top.equalTo(self.weatherIcon.snp.bottom).offset(8)
        }
        
        dateLabel.snp.makeConstraints { (maker) in
            
            maker.centerX.equalToSuperview()
            maker.top.equalTo(self.summaryLabel.snp.bottom).offset(8)
        }
    }
    
    /// 添加点击事件
    private func addTouchEvent() {
        
        locationImage.sz_addTouchEvent { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.touchedLocation()
        }
        
        settingsImage.sz_addTouchEvent { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.touchedSettings()
        }
    }
}

// MARK: - private method
extension CurrentWeatherView {
    
    private func touchedLocation() {
        
        delegate?.locationButtonPressed()
    }
    
    private func touchedSettings() {
        
        delegate?.settingsButtonPressed()
    }
    
    private func updateView() {
        
        activityIndicatorView.stopAnimating()
        
        if let now = now, let location = location {
            updateWeatherContainer(with: now, at: location)
        }
        else {
            loadingFailedLabel.isHidden = false
            loadingFailedLabel.text = "Fetch weather/location failed."
        }
    }
    
    private func updateWeatherContainer(with data: WeatherData, at location: Location) {
        
        weatherContainerView.isHidden = false
        
        // 1. Set location
        locationLabel.text = location.name
        
        // 2. Format and set temperature
        temperatureLabel.text = String(
            format: "%.1f °C",
            data.currently.temperature.toCelcius())
        
        // 3. Set weather icon
        weatherIcon.image = weatherIcon(
            of: data.currently.icon)
        
        // 4. Format and set humidity
        humidityLabel.text = String(
            format: "%.1f",
            data.currently.humidity)
        
        // 5. Set weather summary
        summaryLabel.text = data.currently.summary
        
        // 6. Format and set datetime
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMMM"
        dateLabel.text = formatter.string(
            from: data.currently.time)
    }
    
    private func weatherIcon(of name: String) -> UIImage? {
        
        switch name {
        case "clear-day":
            return UIImage(named: "clear-day")
        case "clear-night":
            return UIImage(named: "clear-night")
        case "rain":
            return UIImage(named: "rain")
        case "snow":
            return UIImage(named: "snow")
        case "sleet":
            return UIImage(named: "sleet")
        case "wind":
            return UIImage(named: "wind")
        case "cloudy":
            return UIImage(named: "cloudy")
        case "partly-cloudy-day":
            return UIImage(named: "partly-cloudy-day")
        case "partly-cloudy-night":
            return UIImage(named: "partly-cloudy-night")
        default:
            return UIImage(named: "clear-day")
        }
    }
}
