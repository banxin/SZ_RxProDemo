//
//  SettingsDateViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

struct SettingsDateViewModel {
    
    let dateMode: DateMode
    
    var labelText: String {
        
        return dateMode == .text ? "Fri, 01 December" : "F, 12/01"
    }
    
    var accessory: UITableViewCell.AccessoryType {
        
        if UserDefaults.dateMode() == dateMode {
            
            return .checkmark
            
        } else {
            
            return .none
        }
    }
}

extension SettingsDateViewModel: SettingsRepresentable {}
