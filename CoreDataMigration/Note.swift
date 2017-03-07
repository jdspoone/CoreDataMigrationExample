/*

  Written by Jeff Spooner

*/

import CoreData


@objc(Note)
class Note: NSManagedObject
  {

    @NSManaged var title: String
    @NSManaged var body: String


    convenience init(title: String, body: String, context: NSManagedObjectContext)
      {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context)!

        self.init(entity: entityDescription, insertInto: context)

        self.title = title
        self.body = body
      }

  }
