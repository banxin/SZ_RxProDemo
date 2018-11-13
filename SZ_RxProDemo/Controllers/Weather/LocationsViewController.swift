//
//  LocationsViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

import CoreLocation

private let kLocationsTableViewCellReuseIdentifier = "kLocationsTableViewCellReuseIdentifier"

protocol LocationsViewControllerDelegate {
    
    func controller(_ controller: LocationsViewController, didSelectLocation location: CLLocation)
}

class LocationsViewController: UITableViewController {

    var currentLocation: CLLocation?
    
    var delegate: LocationsViewControllerDelegate?
    
    var favourites = UserDefaults.loadLocations()
    
    private var hasFavourites: Bool {
        
        return favourites.count > 0
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
}

extension LocationsViewController {
    
    private func setupUI() {
        
        title = "Locations"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTouched))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTouched))
        
        tableView.tableFooterView = UIView()
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: kLocationsTableViewCellReuseIdentifier)
    }
    
    @objc func addTouched() {
        
        let vc = AddLocationViewController()
        
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func doneTouched() {
        
        navigationController?.popViewController(animated: true)
    }
}

extension LocationsViewController {
    
    private enum Section: Int {
        
        case current
        case favourite
        
        var title: String {
            
            switch self {
                
            case .current:
                
                return "Current Location"
                
            case .favourite:
                
                return "Favourite Locations"
            }
        }
        
        static var count: Int {
            
            return Section.favourite.rawValue + 1
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            
            fatalError("Unexpected Section")
        }
        
        switch section {
        case .current:
            return 1
        case .favourite:
            return max(favourites.count, 1)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let section = Section(rawValue: section) else {
            
            fatalError("Unexpected Section")
        }
        
        return section.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            
            fatalError("Unexpected section")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kLocationsTableViewCellReuseIdentifier, for: indexPath) as? LocationTableViewCell else {
            
            fatalError("Unexpected table view cell")
        }
        
        var vm: LocationsViewModel?
        
        switch section {
            
        case .current:
            
            if let currentLocation = currentLocation {
                
                vm = LocationsViewModel(location: currentLocation, locationText: nil)
                
            } else {
                
                cell.title.text = "Current Location Unknown"
            }
            
        case .favourite:
            
            if favourites.count > 0 {
                
                let fav = favourites[indexPath.row]
                vm = LocationsViewModel(location: fav.location, locationText: fav.name)
                
            } else {
                
                cell.title.text = "No Favourites Yet..."
            }
        }
        
        if let vm = vm {
            
            cell.configure(with: vm)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unexpected Section") }
        
        switch section {
            
        case .current: return false
            
        case .favourite: return hasFavourites
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let location = favourites[indexPath.row]
        UserDefaults.removeLocation(location)
        
        favourites.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section) else {
            
            fatalError("Unexpected Section")
        }
        
        var location: CLLocation?
        
        switch (section) {
            
        case .current:
            
            if let currentLocation = currentLocation {
                
                location = currentLocation
            }
            
        case .favourite:
            
            if hasFavourites {
                
                location = favourites[indexPath.row].location
            }
        }
        
        if location != nil {
            
            delegate?.controller(self, didSelectLocation: location!)
            
            dismiss(animated: true)
        }
    }
}

extension LocationsViewController: AddLocationViewControllerDelegate {
    
    func controller(_ controller: AddLocationViewController, didAddLocation location: Location) {
        
        // Update User Defaults
        UserDefaults.addLocation(location)
        
        // Update Locations
        favourites.append(location)
        
        // Update Table View
        tableView.reloadData()
    }
}
