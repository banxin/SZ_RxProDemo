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
        currentWeatherView.viewModel = CurrentWeatherViewModel()
        
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
        
        currentLocation = location
    }
}

// MARK: - WeatherListViewController
extension WeatherListViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            currentLocation = location
            manager.delegate = nil
            
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        dump(error)
    }
}

// MARK: - IBAciton
extension WeatherListViewController {
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        // Request user's location.
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
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            locationManager.requestLocation()
            
        } else {
            
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func fetchWeather() {
        
        guard let currentLocation = currentLocation else { return }
        
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        WeatherDataManager.shared.weatherDataAt(latitude: lat, longitude: lon, completion: {
            response, error in
            if let error = error {
                dump(error)
            }
            else if let response = response {
                
                // Nofity CurrentWeatherViewController
                self.currentWeatherView.viewModel?.weather = response
                self.weatherForecastView.viewModel = WeekWeatherViewModel(weatherData: response.daily.data)
            }
        })
    }
    
    private func fetchCity() {
        
        guard let currentLocation = currentLocation else { return }
        
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            if let error = error {
                dump(error)
            }
            else if let city = placemarks?.first?.locality {
                
                // Notify CurrentWeatherViewController
                let l = Location(
                    name: city,
                    latitude: currentLocation.coordinate.latitude,
                    longitude: currentLocation.coordinate.longitude)
                self.currentWeatherView.viewModel?.location = l
            }
        })
    }
    
    private func reloadUI() {
        
        currentWeatherView.updateView()
        weatherForecastView.updateView()
    }
}
