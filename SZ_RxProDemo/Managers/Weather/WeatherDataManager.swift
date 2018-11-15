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
        
        return (self.urlSession as! URLSession).rx.data(request: request).map({ (data) in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            
            return weatherData
        })
        
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
