//
//  AddLocationViewController.swift
//  SZ_RxProDemo
//
//  Created by 山竹 on 2018/11/13.
//  Copyright © 2018年 SZ. All rights reserved.
//

import UIKit

private let kAddLocationTableViewCellReuseIdentifier = "kAddLocationTableViewCellReuseIdentifier"

protocol AddLocationViewControllerDelegate {
    
    func controller(_ controller: AddLocationViewController, didAddLocation location: Location)
}

class AddLocationViewController: UITableViewController {

    private var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.sz_screenWidth, height: 44))
    
    var viewModel: AddLocationViewModel = AddLocationViewModel()
    var delegate: AddLocationViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Show Keyboard
        searchBar.becomeFirstResponder()
    }
    
    deinit {
        
        print("AddLocationViewController release!")
    }
}

// MARK: - UI
extension AddLocationViewController {
    
    private func setupUI() {
        
        title = "Add a location"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTouched))
        
        searchBar.placeholder = "Enter a city name"
        searchBar.delegate    = self
        
        tableView.tableHeaderView = searchBar
        tableView.tableFooterView = UIView()
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: kAddLocationTableViewCellReuseIdentifier)
        
        viewModel.locationsDidChange = { [unowned self] locations in
            
            self.tableView.reloadData()
        }
        
        viewModel.queryingStatusDidChange = { [unowned self] isQuerying in
            
            self.title = isQuerying ? "Searching..." : "Add a location"
        }
    }
    
    @objc func cancelTouched() {
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table view data source
extension AddLocationViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.numberOfLocations
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kAddLocationTableViewCellReuseIdentifier, for: indexPath)
            as? LocationTableViewCell else {
                
            fatalError("Unexpected table view cell")
        }
        
        if let viewModel = viewModel.locationViewModel(at: indexPath.row) {
            
            cell.configure(with: viewModel)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let location = viewModel.location(at: indexPath.row) else { return }
        
        delegate?.controller(self, didAddLocation: location)
        
        navigationController?.popViewController(animated: true)
    }
}

extension AddLocationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        viewModel.queryText = searchBar.text ?? ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        viewModel.queryText = searchBar.text ?? ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        viewModel.queryText = searchBar.text ?? ""
    }
}
