//
//  UIViewController+Helper.swift
//  CoreDataPractice
//
//  Created by zijia on 10/11/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import UIKit
import CoreData

class IndentedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = rect.inset(by: insets)
        super.drawText(in: customRect)
    }
    
}

private let cellId = "cellId"

class EmployeesController: UITableViewController, CreateEmployeeControllerDelegate {
    
    func didAddEmployee(employee: Employee) {
        guard let section = employeeTypes.firstIndex(of: employee.type!) else { return }
        let row = allEmployees[section].count
        allEmployees[section].append(employee )
        tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .middle)
        
    }
    
    var employees = [Employee]()
    var company: Company?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEmployees()
        navigationItem.title = company?.name
        tableView.backgroundColor = UIColor.darkBlue
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        setupPlusButtonInNavBar(selector: #selector(handleAdd))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return employeeTypes.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.backgroundColor = UIColor.lightBlue
        label.text =  employeeTypes[section]
        label.textColor = .darkBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
//    var shortNameEmployee = [Employee]()
//    var longNameEmployee = [Employee]()
//    var reallyLongNameEmployee = [Employee]()
    var allEmployees = [[Employee]]()
    var employeeTypes = [
        EmployeeType.Excutive.rawValue,
        EmployeeType.SeniorManagement.rawValue,
        EmployeeType.Staff.rawValue
    ]
    
    fileprivate func fetchEmployees() {
        guard let companyEmployees = company?.employee?.allObjects as? [Employee] else { return }
//        self.employees = companyEmployees
        allEmployees = []
        employeeTypes.forEach { (employType) in
            allEmployees.append(companyEmployees.filter{ $0.type == employType })
        }
    }
    
    @objc private func handleAdd() {
        print("Trying to add an employee..")
        
        let createEmployeeController = CreateEmployeeController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        let navController = UINavigationController(rootViewController: createEmployeeController)
        present(navController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return employees.count
        return allEmployees[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        
        
//        let employee = employees[indexPath.row]
        let employee = allEmployees[indexPath.section][indexPath.row]
        cell.textLabel?.text = employee.name
//        if let taxId = employee.employeeInformation?.taxId {
//            cell.textLabel?.text = "\(employee.name ?? "")    \(taxId)"
//        }
        if let birthday = employee.employeeInformation?.birthday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            cell.textLabel?.text = "\(employee.name ?? "")            \(dateFormatter.string(from: birthday))"
        }
        cell.backgroundColor = UIColor.tealColor
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        return cell
    }
    
}







