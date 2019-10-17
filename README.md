# CoreData
## Purpose
* Practicing of CRUD, Thread Safe Operation, NSFetchedResultsController, JSon to Core Data, and Migration.

### Thread Safe
* `CoreDataManager.shared.persistentContainer.viewContext` is **NOT** thread safe, 
* use`CoreDataManager.shared.persistentContainer.performBackgroundTask` to run coreData in background.
* Ex.
```swift
    CoreDataManager.shared.persistentContainer.performBackgroundTask({ (backgroundContext) in
            
            (0...20000).forEach { (value) in
                print(value)
                let company = Company(context: backgroundContext)
                company.name = String(value)
            }
            
            do {
                try backgroundContext.save()
            } catch let err {
                print("Failed to save:", err)
            }
            
        })
```

### Update UI after Save

<p float="left">
  <img width="139" height="301" src="https://github.com/zijiazhai/CoreData/blob/master/githubImages/Snip20191016_1.png">
</p>

* After saved coreData in background thread, updating UI in main thread will not take effect. Because every time we make changes in background thread(backgroundContext), the main thread(viewContext) does not aware that changes.
* We can use viewContext.reset(), but its not a good idea because reset will forget all of the objects you have fetch before.
* Ex. of **bad example**
```swift
        @objc private func doUpdates() {
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            do {
                let companies = try backgroundContext.fetch(request)
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    company.name = "C: \(company.name ?? "")"
                })
                do {
                    try backgroundContext.save()
                    // let's try to update the UI after a save
                    DispatchQueue.main.async {
                        ****************reset(): Bad performance but works(Update UI Successfully)****************
                        // reset will forget all of the objects you've fetch before
                        CoreDataManager.shared.persistentContainer.viewContext.reset()
                        // you don't want to refetch everything if you're just simply update one or two companies
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        // is there a way to just merge the changes that you made onto the main view context?
                        self.tableView.reloadData()
                    }
                } catch let saveErr {
                    print("Failed to save on background:", saveErr)
                }
            } catch let err {
                print("Failed to fetch companies on background:", err)
            }
        }
    }
```

<p float="left">
  <img width="139" height="301" src="https://github.com/zijiazhai/CoreData/blob/master/githubImages/Snip20191016_2.png">
</p>

* Nested Parent Child Context Relationship
* Ex. of **Good Example**
```swift
        @objc private func doNestedUpdates() {
        DispatchQueue.global(qos: .background).async {
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            request.fetchLimit = 1
            do {
                let companies = try privateContext.fetch(request)
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    company.name = "D: \(company.name ?? "")"
                })
                do {
                    try privateContext.save()
                    DispatchQueue.main.async {
                        do {
                           let context = CoreDataManager.shared.persistentContainer.viewContext
                            if context.hasChanges {
                               try context.save()
                            }
                            self.tableView.reloadData()
                        } catch let finalSaveErr {
                            print("Failed to save main context:", finalSaveErr)
                        }
                    }
                } catch let saveErr {
                    print("Failed to save on private context:", saveErr)
                }
            } catch let fetchErr {
                print("Failed to fetch on private context:", fetchErr)
            }
        }
    }
```

### NSFetchedResultsController
* **NSFetchedResultsController** A controller that you use to manage the results of a Core Data fetch request and display data to the user.

```swift
    lazy var fetchedResultsController: NSFetchedResultsController<Company> = { [weak self] in
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch let err {
            print(err)
        }
        return frc
    }()
    
    @objc fileprivate func handleAdd() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let company = Company(context: context)
        company.name = "BMW"
        try? context.save()
    }
    
    @objc fileprivate func handleDelete() {
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS %@", "B")
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let companysWithB = try? context.fetch(request)
        companysWithB?.forEach({ (company) in
            context.delete(company)
        })
        try? context.save()
    }
```
* DataSource, Delegate
```swift
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.text = fetchedResultsController.sectionIndexTitles[section]
        label.backgroundColor = UIColor.lightBlue
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    
    let cellId = "cellId"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyCell
        let company = fetchedResultsController.object(at: indexPath)
        cell.company = company
        return cell
    }
```

### JSon to Core Data
* Retreived Json data from sever in background thread, convert to Core Data using `let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)`
```swift
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

```

