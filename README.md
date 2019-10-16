# CoreData

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
* Ex. of bad example
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

