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
    @NSManaged var imageData: Data?

    var image: UIImage?
      {
        get { return imageData != nil ? UIImage(data: imageData!) : nil }
        set { imageData = newValue != nil ? UIImageJPEGRepresentation(newValue!, 1.0) : nil }
      }


    convenience init(title: String, body: String, imageData: Data?, context: NSManagedObjectContext)
      {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: context)!

        self.init(entity: entityDescription, insertInto: context)

        self.title = title
        self.body = body
        self.imageData = imageData
      }

  }
