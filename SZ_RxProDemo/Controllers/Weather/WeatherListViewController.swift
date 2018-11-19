//
//  WeatherListViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import CoreLocation

import RxSwift
import RxCocoa
import SnapKit

/// 天气列表
class WeatherListViewController: UIViewController {
    
    private var bag = DisposeBag()
    
    /// 当前天气view
    private var currentWeatherView: CurrentWeatherView = CurrentWeatherView()
    /// 天气预报view
    private var weatherForecastView: WeatherForecastView = WeatherForecastView()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 1000
        manager.desiredAccuracy = 1000
        
        return manager
    }()
    
    private var currentLocation: CLLocation? {
        
        didSet {
            fetchCity()
            fetchWeather()
        }
    }
    
    // MARK: - life cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        handleRx()
        setupActiveNotification()
        requestLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - UI
extension WeatherListViewController {
    
    private func setupUI() {
        
        view.backgroundColor = UIColor.white
        
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
        
        let vc = LocationsViewController()
        
        vc.currentLocation = currentLocation
        vc.delegate        = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func settingsButtonPressed() {
        
        let settingVC = SettingsViewController()
        
        settingVC.delegate = self
        
        navigationController?.pushViewController(settingVC, animated: true)
    }
}

extension WeatherListViewController: SettingsViewControllerDelegate {
    
    func controllerDidChangeTimeMode() {
        
        reloadUI()
    }
    
    func controllerDidChangeTemperatureMode() {
        
        reloadUI()
    }
}

extension WeatherListViewController: LocationsViewControllerDelegate {
    
    func controller(_ controller: LocationsViewController, didSelectLocation location: CLLocation) {
        
        self.currentWeatherView.weatherVM.accept(.empty)
        self.currentWeatherView.locationVM.accept(.empty)
        
        currentLocation = location
    }
}

/*
 rx扩展使用 后，则不需要代理了
 */
//// MARK: - CLLocationManagerDelegate
//extension WeatherListViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        if let location = locations.first {
//            currentLocation = location
//            manager.delegate = nil
//
//            manager.stopUpdatingLocation()
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//        if status == .authorizedWhenInUse {
//            manager.requestLocation()
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//
//        dump(error)
//    }
//}

// MARK: - IBAciton
extension WeatherListViewController {
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        
        requestLocation()
    }
}

// MARK: - private method
extension WeatherListViewController {
    
    private func setupActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(notification:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    private func requestLocation() {
        
        // rx扩展使用
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            locationManager.rx.didUpdateLocations.take(1).subscribe(onNext: { [weak self] (location) in
                
                guard let `self` = self else { return }
                
                self.currentLocation = location.first
                
            })
            .disposed(by: bag)
            
        } else {
            
            locationManager.requestWhenInUseAuthorization()
        }
        
        // 没有使用rx扩展时，使用的是代理的形式
//        locationManager.delegate = self
//
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//
//            locationManager.requestLocation()
//
//        } else {
//
//            locationManager.requestWhenInUseAuthorization()
//        }
    }
    
    private func fetchWeather() {
        
        guard let currentLocation = currentLocation else { return }
        
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        // rx bind 的形式绑定数据
        // self 没有强引用 WeatherDataManager，所以这不会有循环引用
        let weather = WeatherDataManager.shared
            .weatherDataAt(latitude: lat, longitude: lon)
            .share(replay: 1, scope: .whileConnected)
            .observeOn(MainScheduler.instance)
        
        weather.map { CurrentWeatherViewModel(weather: $0) }
            .bind(to: self.currentWeatherView.weatherVM)
            .disposed(by: bag)
        
        weather.map { WeekWeatherViewModel(weatherData: $0.daily.data) }
            .subscribe(onNext: {
                self.weatherForecastView.viewModel = $0
            })
            .disposed(by: bag)
    }
    
    private func fetchCity() {
        
        guard let currentLocation = currentLocation else { return }
        
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: { placemarks, error in
            
            if let error = error {
                
                dump(error)
              
                self.currentWeatherView.locationVM.accept(.invalid)
                
            } else if let city = placemarks?.first?.locality {
                
                let location = Location(name: city,
                    latitude: currentLocation.coordinate.latitude,
                    longitude: currentLocation.coordinate.longitude)
                
                self.currentWeatherView.locationVM.accept(CurrentLocationViewModel(location: location))
            }
        })
    }
    
    private func reloadUI() {
        
        currentWeatherView.updateView()
        weatherForecastView.updateView()
    }
    
    private func handleRx() {
        
        currentWeatherView.reload.subscribe(onNext: { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.currentWeatherView.weatherVM.accept(.empty)
            self.currentWeatherView.locationVM.accept(.empty)
            
            self.fetchCity()
            self.fetchWeather()
        })
        .disposed(by: bag)
    }
}
