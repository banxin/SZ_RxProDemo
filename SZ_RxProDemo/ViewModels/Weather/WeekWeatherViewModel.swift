//
//  WeekWeatherViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/12.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

struct WeekWeatherViewModel {
    
    let weatherData: [ForecastData]
    
    private let dateFormatter = DateFormatter()
    
    var numberOfSections: Int {
        
        return 1
    }
    
    var numberOfDays: Int {
        
        return weatherData.count
    }
    
    func viewModel(for index: Int) -> WeekWeatherDayViewModel {
        
        return WeekWeatherDayViewModel(weatherData: weatherData[index])
    }
}
