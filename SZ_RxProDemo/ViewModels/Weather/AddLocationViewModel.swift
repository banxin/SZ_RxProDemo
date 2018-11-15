//
//  AddLocationViewModel.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/15.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation

import CoreLocation

class AddLocationViewModel {
    
    // 用户输入的内容
    var queryText: String = "" {
        
        didSet {
            geocode(address: queryText)
        }
    }
    
    private func geocode(address: String?) {
        
        guard let address = address, !address.isEmpty else {
            
            locations = []
            
            return
        }
        
        isQuerying = true
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            
            self?.processResponse(with: placemarks, error: error)
        }
    }
    
    private func processResponse(with placemarks: [CLPlacemark]?, error: Error?) {
        
        isQuerying = false
        
        var locs: [Location] = []
        
        if let error = error {
            
            print("Cannot handle Geocode Address! \(error)")
            
        } else if let placemarks = placemarks {
            
            locs = placemarks.compactMap {
                
                guard let name = $0.name else { return nil }
                
                guard let location = $0.location else { return nil }
                
                return Location(name: name,
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude)
            }
            
            self.locations = locs
        }
    }
    
    // 记录当前查询状态的两个属性
    // 是否在输入
    private var isQuerying = false {
        
        didSet {
            
            queryingStatusDidChange?(isQuerying)
        }
    }
    
    // 查询到的位置信息
    private var locations: [Location] = [] {
        
        didSet {
            
            locationsDidChange?(locations)
        }
    }
    
    // 查询用户输入的CLGeocoder(使用了lazy，因为只要用户不输入内容，我们是不需要这个对象的)
    private lazy var geocoder = CLGeocoder()
    
    var queryingStatusDidChange: ((Bool) -> Void)?
    var locationsDidChange: (([Location]) -> Void)?
    
    // 位置数量
    var numberOfLocations: Int { return locations.count }
    // 是否有查询结果
    var hasLocationsResult: Bool {
        
        return numberOfLocations > 0
    }
    
    // 点击了cell之后，通过delegate回传的具体位置信息
    func location(at index: Int) -> Location? {
        
        guard index < numberOfLocations else { return nil }
        
        return locations[index]
    }
    
    // AddLocationViewModel返回具体地址信息，任意一个遵从LocationRepresentable的类型都可以
    func locationViewModel(at index: Int) -> LocationRepresentable? {
        
        guard let location = location(at: index) else {
            
            return nil
        }
        
        return LocationsViewModel(location: location.location, locationText: location.name)
    }
}
