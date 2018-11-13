//
//  WeekWeatherDayViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

struct WeekWeatherDayViewModel {
    
    let weatherData: ForecastData
    
    private let dateFormatter = DateFormatter()
    
    var week: String {
        
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: weatherData.time)
    }
    
    var date: String {
        
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter.string(from: weatherData.time)
    }
    
    var temperature: String {
        
        let min = format(temperature: weatherData.temperatureLow)
        let max = format(temperature: weatherData.temperatureHigh)
        
        return "\(min) - \(max)"
    }
    
    var weatherIcon: UIImage? {
        
        return UIImage.weatherIcon(of: weatherData.icon)
    }
    
    var humidity: String {
        
        return String(format: "%.f %%", weatherData.humidity * 100)
    }
    
    /// Helpers
    private func format(temperature: Double) -> String {
        
        switch UserDefaults.temperatureMode() {
            
        case .celsius:
            
            return String(format: "%.0f °C", temperature.toCelcius())
            
        case .fahrenheit:
            
            return String(format: "%.0f °F", temperature)
        }
    }
}

extension WeekWeatherDayViewModel: WeekWeatherDayRepresentable {}


