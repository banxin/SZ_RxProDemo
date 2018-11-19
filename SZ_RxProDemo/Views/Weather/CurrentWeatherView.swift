//
//  CurrentWeatherView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

protocol CurrentWeatherViewDelegate: class {
    
    func locationButtonPressed()
    func settingsButtonPressed()
}

/// 当前天气view (254 height)
class CurrentWeatherView: UIView {
    
    /// 加载中 activity
    private var activityIndicatorView = UIActivityIndicatorView()
    /// 加载失败 label
    private var loadingFailedLabel = UILabel(title: "", fontSize: 17, color: UIColor.darkText)
    /// 重试 label
    private var retryBtn = UILabel(title: "重试", fontSize: 15, color: UIColor.blue)
    /// 天气 Container
    private lazy var weatherContainerView: UIView = UIView()
    /// 位置图片
    private lazy var locationImage: UIImageView = UIImageView(image: UIImage(named: "LocationBtn"))
    /// 设置图片
    private lazy var settingsImage: UIImageView = UIImageView(image: UIImage(named: "Setting"))
    /// 位置name
    private lazy var locationLabel: UILabel = UILabel(title: "Beijing", fontSize: 26, color: UIColor.darkText)
    /// 温度
    private lazy var temperatureLabel: UILabel = UILabel(title: "33.5 ℃", fontSize: 28, color: UIColor.darkText)
    /// 天气图标
    private lazy var weatherIcon: UIImageView = UIImageView(image: UIImage(named: "clear-day"))
    /// 湿度
    private lazy var humidityLabel: UILabel = UILabel(title: "63 %", fontSize: 28, color: UIColor.darkText)
    /// 天气文字
    private lazy var summaryLabel: UILabel = UILabel(title: "Clear", fontSize: 16, color: UIColor.darkText)
    /// 日期
    private lazy var dateLabel: UILabel = UILabel(title: "Mon, 25 September", fontSize: 16, color: UIColor.colorWithHex(hexString: "EE4D37"))
    
    weak var delegate: CurrentWeatherViewDelegate?
    
    private var bag = DisposeBag()
    
    /*
     BehaviorRelay我们需要在创建的时候，给这个事件序列创建一个初始值，
     因此，我们传递了之前添加的表示“空View Model”概念的empty
     */
    var weatherVM: BehaviorRelay<CurrentWeatherViewModel>   = BehaviorRelay(value: CurrentWeatherViewModel.empty)
    var locationVM: BehaviorRelay<CurrentLocationViewModel> = BehaviorRelay(value: CurrentLocationViewModel.empty)
    
    fileprivate let reloadSubject = PublishSubject<Void>()
    
    var reload: Observable<Void> {
        
        return self.reloadSubject.asObserver()
    }
    
    // ------------ 不再需要这些代码了 --------------
    //    var viewModel: Variable<CurrentWeatherViewModel>!
    //    {
    //        didSet {
    //            DispatchQueue.main.async { self.updateView() }
    //        }
    //    }
    // ------------ 不再需要这些代码了 --------------
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
        handleRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension CurrentWeatherView {
    
    /// 设置UI
    private func setupUI() {
        
        activityIndicatorView.style = .gray
        loadingFailedLabel.textAlignment = .center
        retryBtn.textAlignment = .center
        
        locationLabel.textAlignment    = .center
        temperatureLabel.textAlignment = .center
        humidityLabel.textAlignment    = .center
        summaryLabel.textAlignment     = .center
        dateLabel.textAlignment        = .center
        
        temperatureLabel.font = UIFont(name: "PingFangSC-Thin", size: 28)
        humidityLabel.font    = UIFont(name: "PingFangSC-Thin", size: 28)
        summaryLabel.font     = UIFont.italicSystemFont(ofSize: 16)
        dateLabel.font        = UIFont(name: "PingFangSC-Medium", size: 16)
        
        addSubview(loadingFailedLabel)
        addSubview(activityIndicatorView)
        addSubview(retryBtn)
        addSubview(weatherContainerView)
        
        weatherContainerView.addSubview(locationImage)
        weatherContainerView.addSubview(settingsImage)
        weatherContainerView.addSubview(locationLabel)
        weatherContainerView.addSubview(temperatureLabel)
        weatherContainerView.addSubview(weatherIcon)
        weatherContainerView.addSubview(humidityLabel)
        weatherContainerView.addSubview(summaryLabel)
        weatherContainerView.addSubview(dateLabel)
        
        layoutViews()
        
        weatherContainerView.isHidden = true
        loadingFailedLabel.isHidden = true
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        
        addTouchEvent()
    }
    
    private func layoutViews() {
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
        
        loadingFailedLabel.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
        
        retryBtn.snp.makeConstraints { (maker) in
            
            maker.centerX.equalToSuperview()
            maker.top.equalTo(self.loadingFailedLabel.snp.bottom).offset(15)
            maker.height.equalTo(30)
        }
        
        weatherContainerView.snp.makeConstraints { (maker) in
            
            maker.edges.equalToSuperview()
        }
        
        locationImage.snp.makeConstraints { (maker) in
            
            maker.left.top.equalTo(8)
            maker.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        settingsImage.snp.makeConstraints { (maker) in
            
            maker.right.equalTo(-8)
            maker.top.size.equalTo(self.locationImage)
        }
        
        weatherIcon.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
            maker.size.equalTo(CGSize(width: 128, height: 128))
        }
        
        locationLabel.snp.makeConstraints { (maker) in
            
            maker.left.equalTo(self.locationImage.snp.right)
            maker.right.equalTo(self.settingsImage.snp.left)
            maker.centerY.equalTo(self.locationImage)
        }
        
        temperatureLabel.snp.makeConstraints { (maker) in
            
            maker.left.equalTo(self.locationImage)
            maker.centerY.equalTo(self.weatherIcon)
            maker.right.equalTo(self.weatherIcon.snp.left)
        }
        
        humidityLabel.snp.makeConstraints { (maker) in
            
            maker.right.equalTo(self.settingsImage)
            maker.centerY.equalTo(self.weatherIcon)
            maker.left.equalTo(self.weatherIcon.snp.right)
        }
        
        summaryLabel.snp.makeConstraints { (maker) in
            
            maker.centerX.equalToSuperview()
            maker.top.equalTo(self.weatherIcon.snp.bottom).offset(8)
        }
        
        dateLabel.snp.makeConstraints { (maker) in
            
            maker.centerX.equalToSuperview()
            maker.top.equalTo(self.summaryLabel.snp.bottom).offset(8)
        }
    }
    
    /// 添加点击事件
    private func addTouchEvent() {
        
        locationImage.sz_addTouchEvent { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.touchedLocation()
        }
        
        settingsImage.sz_addTouchEvent { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.touchedSettings()
        }
        
        retryBtn.sz_addTouchEvent { [weak self] (_) in
            
            guard let `self` = self else { return }
            
            self.touchedRetry()
        }
    }
}

// MARK: - private method
extension CurrentWeatherView {
    
    private func touchedLocation() {
        
        delegate?.locationButtonPressed()
    }
    
    private func touchedSettings() {
        
        delegate?.settingsButtonPressed()
    }
    
    private func touchedRetry() {
        
        reloadSubject.onNext(())
    }
    
    private func handleRx() {
        
        /*
         1.当这两个View Models都真正有值之后，更新UI，使用 combineLatest
         2.筛选一下过滤的结果，要求它们的事件值都不为“空”，使用 filter
         3.确保订阅者在主线程上执行更新UI代码，使用 .observeOn(MainScheduler.instance)
         4.订阅到事件，更新UI
         */
        
//        // 1， rx bind 的形式
//        let viewModel = Observable.combineLatest(locationVM, weatherVM) {
//
//                return ($0, $1)
//            }
//            .filter {
//
//                let (location, weather) = $0
//                return !(location.isEmpty) && !(weather.isEmpty)
//            }
//            .share(replay: 1, scope: .whileConnected) // 使用了share(replay:scope:)，避免多次进行合并和筛选
//            .observeOn(MainScheduler.instance)
//
//        viewModel.map { _ in false }.bind(to: self.activityIndicatorView.rx.isAnimating).disposed(by: bag)
//        viewModel.map { _ in false }.bind(to: self.weatherContainerView.rx.isHidden).disposed(by: bag)
//
//        viewModel.map { $0.0.city }.bind(to: self.locationLabel.rx.text).disposed(by: bag)
//
//        viewModel.map { $0.1.temperature }.bind(to: self.temperatureLabel.rx.text).disposed(by: bag)
//        viewModel.map { $0.1.weatherIcon }.bind(to: self.weatherIcon.rx.image).disposed(by: bag)
//        viewModel.map { $0.1.humidity }.bind(to: self.humidityLabel.rx.text).disposed(by: bag)
//        viewModel.map { $0.1.summary }.bind(to: self.summaryLabel.rx.text).disposed(by: bag)
//        viewModel.map { $0.1.date }.bind(to: self.dateLabel.rx.text).disposed(by: bag)
        
//        // 2， drive 的形式
//        let viewModel = Observable.combineLatest(locationVM, weatherVM) {
//
//            return ($0, $1)
//            }
//            .filter {
//
//                let (location, weather) = $0
//                return !(location.isEmpty) && !(weather.isEmpty)
//            }
//            .share(replay: 1, scope: .whileConnected) // 使用了share(replay:scope:)，避免多次进行合并和筛选
//            .asDriver(onErrorJustReturn: (CurrentLocationViewModel.empty,
//                CurrentWeatherViewModel.empty))
//        /*
//         什么是Driver呢？简单来说，它就是一个定制过的Observable，拥有下面的特性：
//         • 确保在主线程中订阅，这样也就保证了事件发生后的订阅代码也一定会在主线程中执行；
//         • 不会发生.error事件，我们无需在“订阅”一个Driver的时候，想着处理错误事件的情况。正是由于这个约束，asDriver方法有一个onErrorJustReturn参数，要求我们指定发生错误的生成的事件。这里，我们返回了(CurrentLocationViewModel.empty, CurrentWeatherViewModel.empty)，于是，在任何情况，我们都可以用统一的代码来处理用户交互了；
//         */
//
//        viewModel.map { _ in false }.drive(self.activityIndicatorView.rx.isAnimating).disposed(by: bag)
//        viewModel.map { _ in false }.drive(self.weatherContainerView.rx.isHidden).disposed(by: bag)
//
//        viewModel.map { $0.0.city }.drive(self.locationLabel.rx.text).disposed(by: bag)
//
//        viewModel.map { $0.1.temperature }.drive(self.temperatureLabel.rx.text).disposed(by: bag)
//        viewModel.map { $0.1.weatherIcon }.drive(self.weatherIcon.rx.image).disposed(by: bag)
//        viewModel.map { $0.1.humidity }.drive(self.humidityLabel.rx.text).disposed(by: bag)
//        viewModel.map { $0.1.summary }.drive(self.summaryLabel.rx.text).disposed(by: bag)
//        viewModel.map { $0.1.date }.drive(self.dateLabel.rx.text).disposed(by: bag)
        
        // 3， drive 的形式(带上错误处理)
        let combined = Observable.combineLatest(locationVM, weatherVM) { ($0, $1) }
                        .share(replay: 1, scope: .whileConnected)
        
        let viewModel = combined.filter { self.shouldDisplayWeatherContainer(locationVM: $0.0, weatherVM: $0.1) }
            .asDriver(onErrorJustReturn: (.empty, .empty))
        
        viewModel.map { _ in false }.drive(self.activityIndicatorView.rx.isAnimating).disposed(by: bag)
        viewModel.map { _ in false }.drive(self.weatherContainerView.rx.isHidden).disposed(by: bag)
        
        viewModel.map { $0.0.city }.drive(self.locationLabel.rx.text).disposed(by: bag)
        
        viewModel.map { $0.1.temperature }.drive(self.temperatureLabel.rx.text).disposed(by: bag)
        viewModel.map { $0.1.weatherIcon }.drive(self.weatherIcon.rx.image).disposed(by: bag)
        viewModel.map { $0.1.humidity }.drive(self.humidityLabel.rx.text).disposed(by: bag)
        viewModel.map { $0.1.summary }.drive(self.summaryLabel.rx.text).disposed(by: bag)
        viewModel.map { $0.1.date }.drive(self.dateLabel.rx.text).disposed(by: bag)
        
        combined.map { self.shouldHideWeatherContainer(locationVM: $0.0, weatherVM: $0.1) }
            .asDriver(onErrorJustReturn: true)
            .drive(self.weatherContainerView.rx.isHidden)
            .disposed(by: bag)
        
        combined.map { self.shouldHideActivityIndicator(locationVM: $0.0, weatherVM: $0.1) }
            .asDriver(onErrorJustReturn: false)
            .drive(self.activityIndicatorView.rx.isHidden)
            .disposed(by: bag)
        
        combined.map { self.shouldAnimateActivityIndicator(locationVM: $0.0, weatherVM: $0.1) }
            .asDriver(onErrorJustReturn: true)
            .drive(self.activityIndicatorView.rx.isAnimating)
            .disposed(by: bag)
        
        let errorCond = combined.map { self.shouldDisplayErrorPrompt(locationVM: $0.0, weatherVM: $0.1) }
            .asDriver(onErrorJustReturn: true)
        
        errorCond.map { !$0 }.drive(self.retryBtn.rx.isHidden).disposed(by: bag)
        errorCond.map { !$0 }.drive(self.loadingFailedLabel.rx.isHidden).disposed(by: bag)
        errorCond.map { _ in return String.ok }.drive(self.loadingFailedLabel.rx.text).disposed(by: bag)
    }
    
    private func shouldDisplayWeatherContainer(locationVM: CurrentLocationViewModel, weatherVM: CurrentWeatherViewModel) -> Bool {
        
        return !locationVM.isEmpty && !locationVM.isInvalid && !weatherVM.isEmpty && !weatherVM.isInvalid
    }
    
    func shouldHideWeatherContainer(locationVM: CurrentLocationViewModel, weatherVM: CurrentWeatherViewModel) -> Bool {
        
        return locationVM.isEmpty || locationVM.isInvalid || weatherVM.isEmpty || weatherVM.isInvalid
    }
    
    func shouldHideActivityIndicator(locationVM: CurrentLocationViewModel, weatherVM: CurrentWeatherViewModel) -> Bool {
        
        return (!locationVM.isEmpty && !weatherVM.isEmpty) || locationVM.isInvalid || weatherVM.isInvalid
    }
    
    func shouldAnimateActivityIndicator(locationVM: CurrentLocationViewModel, weatherVM: CurrentWeatherViewModel) -> Bool {
        
        return locationVM.isEmpty || weatherVM.isEmpty
    }
    
    func shouldDisplayErrorPrompt(locationVM: CurrentLocationViewModel, weatherVM: CurrentWeatherViewModel) -> Bool {
        
        return locationVM.isInvalid || weatherVM.isInvalid
    }
    
    func updateView() {
        
        weatherVM.accept(weatherVM.value)
        locationVM.accept(locationVM.value)
    }
}

fileprivate extension String {
    
    static let ok = NSLocalizedString("Whoops! Something is wrong...", comment: "")
}
