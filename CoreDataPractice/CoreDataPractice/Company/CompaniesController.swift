//
//  ViewController.swift
//  CoreData
//
//  Created by zijia on 10/10/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import UIKit
import CoreData


class CompaniesController: UITableViewController {
    
    var companies = [Company]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        companies = CoreDataManager.shared.fetchCompanies()
        setupUI()
    }
    
    @objc func handleAddCompany() {
        let createCompanyController = CreateCompanyController()
        createCompanyController.delegate = self
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func setupUI() {
        
        tableView.backgroundColor = UIColor.tealColor
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(CompanyCell.self, forCellReuseIdentifier: CompanyCell.identifier())
        
        navigationItem.title = "Companies"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(handleAddCompany))
    }
    
//    fileprivate func fetchCompanies() {
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
//        do {
//            let companies = try context.fetch(fetchRequest)
//            self.companies = companies
//            self.tableView.reloadData()
//        } catch let fetchErr {
//            print("Failed to fetch companies:", fetchErr)
//        }
//    }
    
    @objc fileprivate func handleReset() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        do {
            try context.execute(batchDeleteRequest)
            var indexPathsToRemove = [IndexPath]()
            for i in 0..<companies.count {
                indexPathsToRemove.append(IndexPath(row: i, section: 0))
            }
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
        } catch let err {
            print(err)
        }
    }
    
    
}




