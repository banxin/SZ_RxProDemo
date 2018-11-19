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
    
    var city: String {
        
        return location.name
    }
    
    static let empty = CurrentLocationViewModel(location: Location.empty)
    
    var isEmpty: Bool {
        
        return self.location == Location.empty
    }
    
    static let invalid = CurrentLocationViewModel(location: .invalid)
    
    var isInvalid: Bool {
        
        return self.location == Location.invalid
    }
}
