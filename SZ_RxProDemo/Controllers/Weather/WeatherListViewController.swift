//
//  WeatherListViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

/// 天气列表
class WeatherListViewController: UIViewController {
    
    /// 当前天气view
    private var currentWeatherView: CurrentWeatherView = CurrentWeatherView()
    /// 天气预报view
    private var weatherForecastView: WeatherForecastView = WeatherForecastView()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - UI
extension WeatherListViewController {
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        currentWeatherView.delegate = self
        view.addSubview(currentWeatherView)
        view.addSubview(weatherForecastView)
        
        layoutViews()
    }
    
    private func layoutViews() {
    
        currentWeatherView.snp.makeConstraints { (maker) in
            
            if #available(iOS 11.0, *) {
                maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                maker.top.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
            maker.height.equalTo(254)
        }
        
        weatherForecastView.snp.makeConstraints { (maker) in
            
            maker.left.right.equalToSuperview()
            maker.top.equalTo(self.currentWeatherView.snp.bottom)
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }
    }
}

// MARK: - CurrentWeatherViewDelegate
extension WeatherListViewController: CurrentWeatherViewDelegate {
    
    func locationButtonPressed() {
        
        print("locationButtonPressed")
    }
    
    func settingsButtonPressed() {
        
        print("settingsButtonPressed")
    }
}

// MARK: - private method
extension WeatherListViewController {
    
    
}
