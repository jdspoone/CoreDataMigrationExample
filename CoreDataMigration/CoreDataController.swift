/*

  Written by Jeff Spooner

*/

import CoreData


class CoreDataController: NSObject
  {

    private let managedObjectContext: NSManagedObjectContext


    var documentsDirectory: URL
      { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! }


    var dataStoreType: String
      { return NSSQLiteStoreType }

    var dataStoreURL: URL
      { return documentsDirectory.appendingPathComponent("CoreDataMigration.sqlite") }

    var temporaryDataStoreURL: URL
      { return documentsDirectory.appendingPathComponent("TemporaryCoreDataMigration.sqlite") }


    var managedObjectModel: NSManagedObjectModel
      { return NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "CoreDataMigration", withExtension: "momd")!)! }


    // MARK: -

    override init()
      {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        super.init()
      }


    func getManagedObjectContext() -> NSManagedObjectContext
      {
        // If the managed object context's persistent store coordinator is nil
        if managedObjectContext.persistentStoreCoordinator == nil {

          // Create a persisteny store coordinator
          let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

          do {
            // Conditionally clear the data store
            if ProcessInfo().arguments.contains("--clean") {
              if FileManager.default.fileExists(atPath: dataStoreURL.path) {
                try FileManager.default.removeItem(at: dataStoreURL)
              }
            }

            // If there is a file at the datastore path
            if FileManager.default.fileExists(atPath: dataStoreURL.path) {

              // Get the persistent store's metadata
              let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: dataStoreType, at: dataStoreURL, options: nil)

              // Determine if we need to migrate
              let compatible = managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)

              // If a migration is needed
              if compatible == false {
                fatalError("unimplemented")
              }
            }

            // Attempt to add the persistent store
            try persistentStoreCoordinator.addPersistentStore(ofType: dataStoreType, configurationName: nil, at: dataStoreURL, options: nil)
          }
          catch let e {
            fatalError("error: \(e)")
          }

          // Attach the persistent store coordinator to the managed object context
          managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        }

        // Return the managed object context
        return managedObjectContext
      }

  }
