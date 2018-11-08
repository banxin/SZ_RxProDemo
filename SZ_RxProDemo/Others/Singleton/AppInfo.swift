//
//  AppInfo.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/8.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation

private let kIsLoginedKey = "kIsLoginedKey"

public class AppInfo {
    
    public static let shared: AppInfo = {
        
        return AppInfo()
    }()
    
    var isLogined: Bool {
        
        return fetchUserLoginStatus()
    }
}

// MARK: - public method
extension AppInfo {
    
    func setUserLogined() {
        
        UserDefaults.standard.setValue(true, forKey: kIsLoginedKey)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - private method
extension AppInfo {
    
    private func fetchUserLoginStatus() -> Bool {
        
        if let loginStatus = UserDefaults.standard.object(forKey: kIsLoginedKey) as? Bool {
            
            return loginStatus
        }
        
        return false
    }
}
