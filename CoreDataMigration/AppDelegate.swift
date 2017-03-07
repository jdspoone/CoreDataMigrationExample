/*
  
  Written by Jeff Spooner

*/

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
  {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
      {
        // Set the main window
        window = UIWindow(frame: UIScreen.main.bounds)

        // Create a core data controller and get the managed object context
        let coreDataController = CoreDataController()
        let managedObjectContext = coreDataController.getManagedObjectContext()

        // Create a navigation controller and set a list view controller as the it's root view controller
        let navigationController = UINavigationController(rootViewController: ListViewController(context: managedObjectContext))
        navigationController.navigationBar.isTranslucent = false

        // Set the root view controller of the window to be the navigation controller
        self.window!.rootViewController = navigationController

        // Make the window key and visible
        window!.makeKeyAndVisible()

        // Return success
        return true
      }

  }

