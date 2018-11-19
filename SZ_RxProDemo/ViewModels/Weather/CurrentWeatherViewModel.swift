//
//  CurrentWeatherViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

struct CurrentWeatherViewModel {
    
    var weather: WeatherData
    
    var temperature: String {
        
        let value = weather.currently.temperature
        
        switch UserDefaults.temperatureMode() {
            
        case .fahrenheit:
            
            return String(format: "%.1f °F", value)
            
        case .celsius:
            
            return String(format: "%.1f °C", value.toCelcius())
        }
    }
    
    var weatherIcon: UIImage {
        
        return UIImage.weatherIcon(of: weather.currently.icon)!
    }
    
    var humidity: String {
        
        return String(format: "%.1f %%", weather.currently.humidity * 100)
    }
    
    var summary: String {
        
        return weather.currently.summary
    }
    
    var date: String {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = UserDefaults.dateMode().format
        
        return formatter.string(from: weather.currently.time)
    }
    
    static let empty = CurrentWeatherViewModel(weather: WeatherData.empty)
    
    var isEmpty: Bool {
        
        return self.weather == WeatherData.empty
    }
    
    static let invalid = CurrentWeatherViewModel(weather: .invalid)
    
    var isInvalid: Bool {
        
        return self.weather == WeatherData.invalid
    }
}
