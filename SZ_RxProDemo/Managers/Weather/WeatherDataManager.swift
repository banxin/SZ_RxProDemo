//
//  WeatherDataManager.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

enum DataManagerError: Error {
    case failedRequest
    case invalidResponse
    case unknown
}

final class WeatherDataManager {
    internal let baseURL: URL
    internal let urlSession: URLSessionProtocol
    internal init(baseURL: URL, urlSession: URLSessionProtocol) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    static let shared = WeatherDataManager(baseURL: API.authenticatedURL, urlSession: URLSession.shared)
    
    typealias CompletionHandler = (WeatherData?, DataManagerError?) -> Void
    
    func weatherDataAt(latitude: Double, longitude: Double) -> Observable<WeatherData> {
        
        let url = baseURL.appendingPathComponent("\(latitude), \(longitude)")
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let MAX_ATTEMPTS = 3
        
        return (self.urlSession as! URLSession).rx.data(request: request).map({ (data) in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            
            return weatherData
        })
        //            .retry(3) // 重试3次
        //            .retry()  // 无脑重试
        .retryWhen { e in
            
            e.enumerated() // Observable<Error> -> Observable<(Int, Error)>
                .flatMap { (attempt, error) -> Observable<Int> in
                    
                    if (attempt >= MAX_ATTEMPTS) {
                        
                        print("------------- \(attempt + 1) attempt -------------")
                        
                        return Observable.error(error)
                        
                    } else {
                        
                        print("------------- \(attempt + 1) Retry --------------")
                        
                        // 每次只是希望使用这个计时器的第一个事件作为通知发起重试，因此，使用了take(1)只让它生成第一个事件就好了
                        return Observable<Int>.timer(Double(attempt + 1), scheduler: MainScheduler.instance).take(1)
                    }
            }
        }
        /*
        调试RxSwift代码时，很有用的operators：materialize和dematerialize。简单来说，materialize可以把一个Observable的所有事件：.next，.complete和.error都变成另一个Observable的.next事件。这样，我们只要观察这个转化过的Observable，就会知道之前的Observable从开始到结束的所有过程了。而dematerialize的作用则是把这个转化过的Observable变回原来的样子。因此，它们总是成对使用的
             
            关闭网络将打印：
            Materialize: error(Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline." 
        */
        .materialize().do(onNext: { print("Materialize: \($0)") }).dematerialize()
        // 错误处理
        .catchErrorJustReturn(WeatherData.invalid)
        // 另外一种捕获错误
//        .catchError({ (_) -> Observable<WeatherData> in
//
//             return Observable.just(.invalid)
//        })
        
        // ------------ 使用rx后不再需要这些代码了 --------------
        //        self.urlSession.dataTask(with: request, completionHandler: {
        //            (data, response, error) in
        //                self.didFinishGettingWeatherData(data: data, response: response, error: error, completion: completion)
        //        }).resume()
        // ------------ 使用rx后不再需要这些代码了 --------------
    }
    
    func didFinishGettingWeatherData(data: Data?, response: URLResponse?, error: Error?, completion: CompletionHandler) {
        if let _ = error {
            completion(nil, .failedRequest)
        }
        else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    completion(weatherData, nil)
                }
                catch {
                    completion(nil, .invalidResponse)
                }
            }
            else {
                completion(nil, .failedRequest)
            }
        }
        else {
            completion(nil, .unknown)
        }
    }
}
