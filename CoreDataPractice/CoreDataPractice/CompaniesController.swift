//
//  ViewController.swift
//  CoreData
//
//  Created by zijia on 10/10/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import UIKit

private let cellId = "cellId"

class CompaniesController: UITableViewController, CreateCompanyControllerDelegate {
    
    func didAddCompany(company: Company) {
        companies.append(company)
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    var companies = [
        Company(name: "Apple", founded: Date()),
        Company(name: "Google", founded: Date()),
        Company(name: "Facebook", founded: Date()),
        Company(name: "Apple", founded: Date()),
        Company(name: "Google", founded: Date()),
        Company(name: "Facebook", founded: Date())
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.tealColor
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        setupNavigationStyle()
    }
    
    @objc func handleAddCompany() {
        let createCompanyController = CreateCompanyController()
        createCompanyController.delegate = self
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func setupNavigationStyle() {
        
        navigationItem.title = "Companies"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(handleAddCompany))
        
        
    }
}


// datasource
extension CompaniesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .tealColor
        
        let company = companies[indexPath.row]
        
        cell.textLabel?.text = company.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.lightBlue
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

