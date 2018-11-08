//
//  MainItem.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/8.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

/// 主页 model item
class MainItem: NSObject {

    /// demo的名称
    var demoName: String = ""
    /// demo VC名前缀
    var demoVCPrefix: String = ""
    
    // MARK: - init
    
    override private init() { super.init() }
    
    init(demoName: String, demoVCPrefix: String) {
        
        self.demoName     = demoName
        self.demoVCPrefix = demoVCPrefix
    }
}
