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
    @NSManaged var image: Image?


    convenience init(title: String, body: String, image: Image?, context: NSManagedObjectContext)
      {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context)!

        self.init(entity: entityDescription, insertInto: context)

        self.title = title
        self.body = body
        self.image = image
      }

  }
