/*

  Written by Jeff Spooner

  Custom migration policy for Image instances

*/

import CoreData


class ImageToImagePolicy: NSEntityMigrationPolicy
  {

    override func createDestinationInstances(forSource sourceInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws
      {
        // Get the user info dictionary
        let userInfo = mapping.userInfo!

        // Get the source version
        let sourceVersion = userInfo["sourceVersion"] as? String

        // If a source version was specified
        if let sourceVersion = sourceVersion {

          // Get the source attribute keys and values
          let sourceAttributeKeys = Array(sourceInstance.entity.attributesByName.keys)
          let sourceAttributeValues = sourceInstance.dictionaryWithValues(forKeys: sourceAttributeKeys)

          // Create the destination Note instance
          let destinationInstance = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)

          // Get the destination attribute keys
          let destinationAttributeKeys = Array(destinationInstance.entity.attributesByName.keys)

          // Set all those attributes of the destination instance which are the same as those of the source instance
          for key in destinationAttributeKeys {
            if let value = sourceAttributeValues[key] {
              destinationInstance.setValue(value, forKey: key)
            }
          }

          // Switch on the source version
          switch sourceVersion {

            // Migrating from v1.2 to v1.3
            case "v1.2":

              // Set the destination image's index to 0
              destinationInstance.setValue(0, forKey: "index")

            default:
              break
          }

          // Associate the data between the source and destination instances
          manager.associate(sourceInstance: sourceInstance, withDestinationInstance: destinationInstance, for: mapping)
        }
        // Otherwise, defer to super's implementation
        else {
          try super.createDestinationInstances(forSource: sourceInstance, in: mapping, manager: manager)
        }
      }

  }
