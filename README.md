# CoreData

### Thread Safe
`CoreDataManager.shared.persistentContainer.viewContext` is **NOT** thread safe, use `CoreDataManager.shared.persistentContainer.performBackgroundTask` to run coreData in background.
