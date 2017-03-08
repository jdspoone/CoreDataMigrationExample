# CoreData Migration Example

Written by Jeff Spooner

- - -

**tldr;**

This project demonstrates **manual, i.e. not-lightweight** CoreData migration, written in Swift 3.

- - -

**Overview**

There are a lot of articles on the internet regarding lightweight CoreData migration, but not much when it comes to manual CoreData migration. This can make the prospect of using CoreData for a non-trivial app somewhat intimidating. In an attempt to remedy this, I've written an iOS app in Swift 3 which demonstrates manual CoreData migration in a straightforward way.

The app is a simple note app, and includes interfaces to view and modify any notes you create.

The project includes a mapping model implementing each of the following concepts:

* Adding an attribute to an entity
* Replacing an attribute with an entity, and managing it with a to-one relationship
* Changing a to-one relationship into a to-many relationship

Lightweight migration is not covered in this project because it's well documented elsewhere.

I found [hwaxxer's][hwaxxerGitHub] [BookMigration][BookMigrationRepistory] project useful during the writing of this.

[hwaxxerGitHub]: https://github.com/hwaxxer
[BookMigrationRepistory]: https://github.com/hwaxxer/BookMigration

- - -

**Instructions on testing**

* Clone the repository
* Checkout one of the earlier tags (v1.0, v1.1, or v1.2)
* Run the CoreDataMigration target, and create some test notes
* Checkout a later tag
* Run the CoreDataMigration target again

And you'll need to remove the data store if you're going from a later version to an earlier version.

- - -

**Things to bear in mind**

* Using `NSMappingModel.inferredMappingModel(forSourceModel sourceModel: NSManagedObjectModel, destinationModel: NSManagedObjectModel)` during an iterative migration process probably won't work very well, as you need to provide a destination model to the call. Unless you're doing some fancy parsing of the managed object models in your app bundle, the only destination model you'll have on hand is the final destination model, and your migration will cease to be *iterative*. Bottom line is if you're doing manual migration, create a mapping model for every migration even if it's for something trivial like adding an attribute to an entity.
* Make sure you don't modify your managed object models **at all** after you create a mapping model between them. If you do, the mapping model will cease to apply, and you'll need to recreate it. 
* When specifying a custom entity migration policy in a mapping model, remember the following:
  - You need to prefix the policy name with the module name. In this example, policies are prefixed with "CoreDataMigration."
  - Store the source version (or some other identifier) in the mapping model's user info dictionary if you're using a that custom policy for multiple migrations. For example, NoteToNotePolicy is used in both v1.1-to-v1.2.xcmappingmodel and v1.2-to-v1.3.xcmappingmodel, so I specify the source version in each mapping model's user info dictionary.
* Ensure that entity migrations which depend on other entity migrations being complete occur after them. In this example Note migration happens after Image migration. 
* While you can set relationships during `createDestinationInstances(...)`, you need to make sure that you're not trying to associate a managedObject from the source context to the destination instance. For example, if you're writing a policy to create a to-one relationship from an attribute, you can set that relationship in `createDestinationInstances(...)`. However, if you later want to change that to-one relationship to be to-many instead, you'll have to do it in `createRelationships(...)`.
