//
//  LocationsViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationsViewModel {
    
    let location: CLLocation?
    let locationText: String?
}

extension LocationsViewModel: LocationRepresentable {
    
    var labelText: String {
        
        if let locationText = locationText {
            
            return locationText
            
        } else if let location = location {
            
            return location.toString
        }
        
        return "Unknown position"
    }
}
