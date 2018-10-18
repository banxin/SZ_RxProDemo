//
//  TodoItem.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/10/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

/// model，遵从NSCoding的类，方便我们序列化成plist保存和加载
class TodoItem: NSObject, NSCoding {
    
    /// ToDo的标题
    var name: String = ""
    /// 是否完成
    var isFinished: Bool = false
    /// 图片名
    var pictureMemoFilename: String = ""
    
    // MARK: - init
    
    override init() { super.init() }
    
    init(name: String, isFinished: Bool, pictureMemoFilename: String) {
        
        self.name                = name
        self.isFinished          = isFinished
        self.pictureMemoFilename = pictureMemoFilename
    }
    
    // MARK: - public method
    
    func toggleFinished() {
        
        isFinished = !isFinished
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        
        name       = aDecoder.decodeObject(forKey: "name") as! String
        isFinished = aDecoder.decodeBool(forKey: "isFinished")
        
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(isFinished, forKey: "isFinished")
        aCoder.encode(pictureMemoFilename, forKey: "pictureMemoFilename")
    }
}
