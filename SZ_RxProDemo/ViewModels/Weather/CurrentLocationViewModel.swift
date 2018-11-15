//
//  CurrentLocationViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/15.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation

/// 当前位置 viewmodel
struct CurrentLocationViewModel {
    
    var location: Location
    
    static let empty = CurrentLocationViewModel(location: Location.empty)
    
    var city: String {
        
        return location.name
    }
    
    var isEmpty: Bool {
        
        return self.location == Location.empty
    }
}
