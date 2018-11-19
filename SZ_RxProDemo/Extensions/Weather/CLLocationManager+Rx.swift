//
//  CLLocationManager+Rx.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/19.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

/*
 这个不是很懂。。。 @山竹
 */

extension CLLocationManager: HasDelegate {
    
    public typealias Delegate = CLLocationManagerDelegate
}

class CLLocationManagerDelegateProxy:
    DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
    DelegateProxyType,
    CLLocationManagerDelegate {
    
    weak private(set) var locationManager: CLLocationManager?
    
    init(locationManager: ParentObject) {
        
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: CLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        
        self.register { CLLocationManagerDelegateProxy(locationManager: $0) }
    }
}

extension Reactive where Base: CLLocationManager {
    
    var delegate: CLLocationManagerDelegateProxy {
        
        return CLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        
        let sel = #selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))
        
        return delegate.methodInvoked(sel).map {
            
            parameters in parameters[1] as! [CLLocation]
        }
    }
}

