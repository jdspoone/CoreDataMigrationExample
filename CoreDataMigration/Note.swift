/*

  Written by Jeff Spooner

*/

import UIKit
import CoreData


@objc(Note)
class Note: NSManagedObject
  {

    @NSManaged var title: String
    @NSManaged var body: String
    @NSManaged var images: Set<Image>


    convenience init(title: String, body: String, images: Set<Image>, context: NSManagedObjectContext)
      {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context)!

        self.init(entity: entityDescription, insertInto: context)

        self.title = title
        self.body = body
        self.images = images
      }

  }
