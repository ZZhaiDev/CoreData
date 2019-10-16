//
//  CoreDataManager.swift
//  CoreDataPractice
//
//  Created by zijia on 10/10/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "CoreDataPracticeModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, err) in
            if let err = err {
                fatalError("loading of store fialed: \(err)")
            }
        })
        return container
    }()
    
    func fetchCompanies() -> [Company] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        do {
            let companies = try context.fetch(fetchRequest)
            return companies
        } catch let fetchErr {
            print("Failed to fetch companies:", fetchErr)
            return []
        }
    }
    
    func createEmployee(employeeName: String) -> (Employee?, Error?) {
        let context = persistentContainer.viewContext
        
        //create an employee
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
        
        employee.setValue(employeeName, forKey: "name")
        
        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
        employeeInformation.taxId = "456"
        employee.employeeInformation = employeeInformation
        
        do {
            try context.save()
            // save succeeds
            return (employee, nil)
        } catch let err {
            print("Failed to create employee:", err)
            return (nil, err)
        }
        
    }
    
}
