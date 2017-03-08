/*

  Written by Jeff Spooner

  This class is responsible for configuring the managed object context,
  the most important feature of which is CoreData migration.  

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


    var finalManagedObjectModel: NSManagedObjectModel
      { return NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "CoreDataMigration", withExtension: "momd")!)! }


    var managedObjectModelURLs: [URL]
      {
        // Initialize an empty array
        var urls = [URL]()

        // Get the path of the momd directory
        let momdURL = Bundle.main.url(forResource: "CoreDataMigration", withExtension: "momd")!

        do {
          // Get the names of the the files inside the momd directory
          let contents = try FileManager.default.contentsOfDirectory(atPath: momdURL.path)

          // Iterate over those file names
          for path in contents {

            // We're only interested in .mom files
            let suffixArray = Array(path.utf16.suffix(4))
            if String(utf16CodeUnits: suffixArray, count: suffixArray.count) == ".mom" {

              // Construct a URL from the given path, and add it to the array of URLs
              let url = URL(fileURLWithPath: path, relativeTo: momdURL)
              urls.append(url)
            }
          }
        }
        catch let e {
          fatalError("error: \(e)")
        }

        return urls
      }


    // MARK: -

    override init()
      {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        super.init()
      }


    func getDestinationModelAndMappingModel(for sourceModel: NSManagedObjectModel) -> (NSManagedObjectModel, NSMappingModel)?
      {
        // Iterate over the managed object model urls
        for url in managedObjectModelURLs {

          // Create a managed object model from the url
          let destinationModel = NSManagedObjectModel(contentsOf: url)!

          // Attempt to get a custom mapping model between the source and destination models
          // We're operating on the assumption that there is AT MOST 1 mapping model for any given source managed object model
          if let mappingModel = NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel) {

            // If we're successful, return the destination model
            return (destinationModel, mappingModel)
          }
        }

        return nil
      }


    func migrateIteratively() throws
      {
        do {
          // Get the persistent store's metadata
          var sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: dataStoreType, at: dataStoreURL, options: nil)

          // Determine if we need to migrate
          let compatible = finalManagedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)

          // If a migration is needed
          if compatible == false {

            // Repeat while a migration is needed
            repeat {

              // Get the source model
              let sourceModel = NSManagedObjectModel.mergedModel(from: [Bundle.main], forStoreMetadata: sourceMetadata)!

              // Attempt to get the destination model and mapping model
              let (destinationModel, mappingModel) = getDestinationModelAndMappingModel(for: sourceModel)!

              // Create a migration manager
              let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)

              // Ensure there is no file at the temporary data store url
              if FileManager.default.fileExists(atPath: temporaryDataStoreURL.path) {
                try FileManager.default.removeItem(at: temporaryDataStoreURL)
              }

              // Migrate the datastore
              try migrationManager.migrateStore(from: dataStoreURL, sourceType: NSSQLiteStoreType, options: nil, with: mappingModel, toDestinationURL: temporaryDataStoreURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)

              // Move the migrated datastore to from the temporary location to the primary location
              try FileManager.default.removeItem(at: dataStoreURL)
              try FileManager.default.moveItem(at: temporaryDataStoreURL, to: dataStoreURL)

              // Update the source metadata
              sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: dataStoreType, at: dataStoreURL, options: nil)
            }
            while finalManagedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata) == false

          }
        }
        // Throw any caught errors
        catch let e { throw e }
      }


    func getManagedObjectContext() -> NSManagedObjectContext
      {
        // If the managed object context's persistent store coordinator is nil
        if managedObjectContext.persistentStoreCoordinator == nil {

          // Create a persistent store coordinator
          let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: finalManagedObjectModel)

          do {
            // Conditionally clear the data store
            if ProcessInfo().arguments.contains("--clean") {
              if FileManager.default.fileExists(atPath: dataStoreURL.path) {
                try FileManager.default.removeItem(at: dataStoreURL)
              }
            }

            // If there is a file at the datastore path
            if FileManager.default.fileExists(atPath: dataStoreURL.path) {

              // Attempt iterative migration
              try migrateIteratively()
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
