//
//  Service.swift
//  CoreDataPractice
//
//  Created by zijia on 10/16/19.
//  Copyright © 2019 zijia. All rights reserved.
//

import UIKit
import CoreData 

struct JSONCompany: Decodable {
    
    let name: String
    let founded: String
    var employees: [JSONEmployee]?
    
}

struct JSONEmployee: Decodable {
    let name: String
    let type: String
    let birthday: String
}

struct Service {
    static let shared = Service()
    
    let urlString = "https://api.letsbuildthatapp.com/intermediate_training/companies"
    
    func downloadCompaniesFromServer() {
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if let err = err {
                print("Failed to download companies:", err)
                return
            }
            
            guard let data = data else { return }
            do {
                let jsonCompanies = try JSONDecoder().decode([JSONCompany].self, from: data)
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                
                jsonCompanies.forEach({ (jsonCompany) in
                    let company = Company(context: privateContext)
                    company.name = jsonCompany.name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let foundedDate = dateFormatter.date(from: jsonCompany.founded)
                    company.founded = foundedDate
                    
                    jsonCompany.employees?.forEach({ (jsonEmployee) in
                        let employee = Employee(context: privateContext)
                        employee.name = jsonEmployee.name
                        employee.type = jsonEmployee.type
                        
                        let employeeInformation = EmployeeInformation(context: privateContext)
                        let birthdayDate = dateFormatter.date(from: jsonEmployee.birthday)
                        
                        employeeInformation.birthday = birthdayDate
                        employee.employeeInformation = employeeInformation
                        employee.company = company
                    })
                    
                    do {
                        try privateContext.save()
                        try privateContext.parent?.save()
                        
                    } catch let saveErr {
                        print("Failed to save companies:", saveErr)
                    }
                    
                })
                
            } catch let jsonDecodeErr {
                print("Failed to decode:", jsonDecodeErr)
            }
            
            }.resume()
    }
}
