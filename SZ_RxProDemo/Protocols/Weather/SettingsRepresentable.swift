//
//  SettingsRepresentable.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

protocol SettingsRepresentable {
    
    var labelText: String { get }
    
    var accessory: UITableViewCell.AccessoryType { get }
}


