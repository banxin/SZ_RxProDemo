//
//  SettingsTemperatureViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

struct SettingsTemperatureViewModel {
    
    let temperatureMode: TemperatureMode
    
    var labelText: String {
        
        return temperatureMode == .celsius ? "Celsius" : "Fahrenhait"
    }
    
    var accessory: UITableViewCell.AccessoryType {
        
        if UserDefaults.temperatureMode() == temperatureMode {
            
            return .checkmark
            
        } else {
            
            return .none
        }
    }
}

extension SettingsTemperatureViewModel: SettingsRepresentable {}
