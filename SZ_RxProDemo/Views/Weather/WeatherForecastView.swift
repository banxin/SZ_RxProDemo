//
//  WeatherForecastView.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/9.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

private let kWeekWeatherTableViewCellIndentifier = "kWeekWeatherTableViewCellIndentifier"

/// 天气预报view
class WeatherForecastView: UIView {
    
    var viewModel: WeekWeatherViewModel? {
        
        didSet {
            
            DispatchQueue.main.async { self.updateView() }
        }
    }
    
    /// 加载中 activity
    private var activityIndicatorView = UIActivityIndicatorView()
    /// 加载失败 label
    private var loadingFailedLabel = UILabel(title: "", fontSize: 17, color: UIColor.darkText)
    /// 表格view
    private var tableView: UITableView?
    
    /// rx资源回收bag
    private let bag: DisposeBag = DisposeBag()
    
    /// 展示数据
    private var weekWeatherItems = BehaviorRelay<[WeatherData]>(value: [])

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension WeatherForecastView {
    
    private func setupUI() {
        
        activityIndicatorView.style = .gray
        loadingFailedLabel.textAlignment = .center
        
        addSubview(loadingFailedLabel)
        addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
        
        loadingFailedLabel.snp.makeConstraints { (maker) in
            
            maker.center.equalToSuperview()
        }
        
        setupTableView()
//        rxBind()
        
        tableView?.isHidden         = true
        loadingFailedLabel.isHidden = true
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
    }
    
    /// 设置tableview
    private func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), style: .plain)
        
        tableView?.register(WeekWeatherTableViewCell.self, forCellReuseIdentifier: kWeekWeatherTableViewCellIndentifier)
        
        tableView?.dataSource = self
        tableView?.delegate   = self
        
        tableView?.estimatedRowHeight           = 0
        tableView?.estimatedSectionHeaderHeight = 0
        tableView?.estimatedSectionFooterHeight = 0
        
        addSubview(tableView!)
        
        tableView!.snp.makeConstraints { (maker) in
            
            maker.edges.equalToSuperview()
        }
    }
    
    private func rxBind() {
        
        // 将数据源数据绑定到tableView上
        weekWeatherItems.bind(to: tableView!.rx.items(cellIdentifier: kWeekWeatherTableViewCellIndentifier)) { _, wetherItem, originCell in
            
            if let cell = originCell as? WeekWeatherTableViewCell {
                
                cell.item.accept(wetherItem)
            }
            
        }.disposed(by: bag)
        
//        tableView?.rx.modelSelected(weekWeatherItems.self).subscribe(onNext: { (wetherItem) in
//
//        }).disposed(by: bag)
    }
}

extension WeatherForecastView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let viewModel = viewModel else { return 0 }
        
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let viewModel = viewModel else { return 0 }
        
        return viewModel.numberOfDays
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 104
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: kWeekWeatherTableViewCellIndentifier, for: indexPath) as? WeekWeatherTableViewCell {
//
//            if let vm = viewModel {
//
//                cell.week.text = vm.week(for: indexPath.row)
//                cell.date.text = vm.date(for: indexPath.row)
//                cell.temperature.text = vm.temperature(for: indexPath.row)
//                cell.weatherIcon.image = vm.weatherIcon(for: indexPath.row)
//                cell.humid.text = vm.humidity(for: indexPath.row)
//            }
//
//            return cell
//        }
//
//        return UITableViewCell()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kWeekWeatherTableViewCellIndentifier, for: indexPath) as? WeekWeatherTableViewCell

        guard let row = cell else {

            fatalError("Unexpected table view cell.")
        }

        if let vm = viewModel {

            row.week.text = vm.week(for: indexPath.row)
            row.date.text = vm.date(for: indexPath.row)
            row.temperature.text = vm.temperature(for: indexPath.row)
            row.weatherIcon.image = vm.weatherIcon(for: indexPath.row)
            row.humid.text = vm.humidity(for: indexPath.row)
        }

        return row
    }
}

// MARK: - private method
extension WeatherForecastView {
    
    private func updateView() {
        
        activityIndicatorView.stopAnimating()
        
        if let _ = viewModel {
            
            tableView?.isHidden         = false
            loadingFailedLabel.isHidden = true
            tableView?.reloadData()
            
        } else {
            
            tableView?.isHidden         = true
            loadingFailedLabel.isHidden = false
            loadingFailedLabel.text = "Load Location/Weather failed!"
        }
    }
}
