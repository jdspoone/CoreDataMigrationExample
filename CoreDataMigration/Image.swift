/*

  Written by Jeff Spooner

*/

import UIKit
import CoreData


@objc(Image)
class Image: NSManagedObject
  {

    @NSManaged var index: Int16
    @NSManaged var imageData: Data?

    var image: UIImage?
      {
        get { return imageData != nil ? UIImage(data: imageData!) : nil }
        set { imageData = newValue != nil ? UIImageJPEGRepresentation(newValue!, 1.0) : nil }
      }


    convenience init(index: Int16, imageData: Data?, context: NSManagedObjectContext)
      {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Image", in: context)!

        self.init(entity: entityDescription, insertInto: context)

        self.index = index
        self.imageData = imageData
      }

  }
