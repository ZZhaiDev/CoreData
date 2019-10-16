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

