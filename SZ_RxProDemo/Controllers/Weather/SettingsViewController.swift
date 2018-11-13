//
//  SettingsViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/12.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

private let kSettingsTableViewCellReuseIdentifier = "kSettingsTableViewCellReuseIdentifier"

protocol SettingsViewControllerDelegate {
    
    func controllerDidChangeTimeMode()
    func controllerDidChangeTemperatureMode()
}

/// 设置页面
class SettingsViewController: UITableViewController {

    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }
    
    deinit {
        
        print("SettingsViewController release!")
    }
}

// MARK: - UI
extension SettingsViewController {
    
    private func setupUI() {
        
        title = "Settings"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTouched))
        
        tableView.tableFooterView = UIView()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: kSettingsTableViewCellReuseIdentifier)
    }
    
    @objc func doneTouched() {
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table view data source
extension SettingsViewController {
    
    private enum Section: Int {
        
        case date
        case temperature
        
        var numberOfRows: Int {
            
            return 2
        }
        
        static var count: Int {
            
            return Section.temperature.rawValue + 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            
            fatalError("Unexpected section index")
        }
        
        return section.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (section == 0){
            
            return "Date format"
        }
        
        return "Temperature unit"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kSettingsTableViewCellReuseIdentifier, for: indexPath) as? SettingsTableViewCell else {
            
            fatalError("Unexpected talbe view cell")
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            
            fatalError("Unexpected section index")
        }
        
        var vm: SettingsRepresentable?
        
        switch section {
            
        case .date:
            
            guard let dateMode = DateMode(rawValue: indexPath.row) else {
                
                fatalError("Invalide IndexPath")
            }
            
            vm = SettingsDateViewModel(dateMode: dateMode)
            
        case .temperature:
            
            guard let temperatureMode = TemperatureMode(rawValue: indexPath.row) else {
                
                fatalError("Invalid IndexPath")
            }
            
            vm = SettingsTemperatureViewModel(temperatureMode: temperatureMode)
        }
        
        if let vm = vm {
            
            cell.configure(with: vm)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section) else {
            
            fatalError("Unexpected section index")
        }
        
        switch section {
            
        case .date:
            
            let dateMode = UserDefaults.dateMode()
            
            guard indexPath.row != dateMode.rawValue else { return }
            
            if let newMode = DateMode(rawValue: indexPath.row) {
                
                UserDefaults.setDateMode(to: newMode)
            }
            
            delegate?.controllerDidChangeTimeMode()
            
        case .temperature:
            
            let temperatureMode = UserDefaults.temperatureMode()
            
            guard indexPath.row != temperatureMode.rawValue else { return }
            
            if let newMode = TemperatureMode(rawValue: indexPath.row) {
                
                UserDefaults.setTemperatureMode(to: newMode)
            }
            
            delegate?.controllerDidChangeTemperatureMode()
        }
        
        let sections = IndexSet(integer: indexPath.section)
        
        tableView.reloadSections(sections, with: .none)
    }
}

