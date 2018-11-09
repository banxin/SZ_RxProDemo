//
//  WeatherData.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation

// 为了 JSON 和 model 自动转换，遵循 Codable 协议
struct WeatherData: Codable {
    
    // 纬度
    let latitude: Double
    // 经度
    let longitude: Double
    let currently: CurrentWeather
    
    struct CurrentWeather: Codable {
        
        let time: Date
        let summary: String
        let icon: String
        let temperature: Double
        let humidity: Double
    }
}
