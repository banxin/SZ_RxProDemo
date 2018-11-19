//
//  Date.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/19.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation

extension Date {
    
    static func from(string: String) -> Date {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-mm-dd"
        dateFormatter.timeZone   = TimeZone(abbreviation: "GMT+8:00")
        
        return dateFormatter.date(from: string)!
    }
}
