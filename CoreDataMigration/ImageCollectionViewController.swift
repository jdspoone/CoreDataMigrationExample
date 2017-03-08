/*

  Written by Jeff Spooner

  This class is responsible for viewing and editing the images associated with a particular Note.

*/

import UIKit
import CoreData


class ImageCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
  {

    var managedObjectContext: NSManagedObjectContext

    var note: Note
    var sortedImages: [Image]
      { return note.images.sorted(by: { $0.index < $1.index }) }

    var selectedIndices = Set<Int>()
      {
        // Enable key-value observation
        willSet { willChangeValue(forKey: "selectedImage") }
        didSet { didChangeValue(forKey: "selectedImage") }
      }

    let completion: (Image?) -> Void

    var toolbar: UIToolbar!

    var addButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    var endEditingButton: UIBarButtonItem!

    var reuseIdentifier: String
      { return "ImageCollectionViewCell" }


    init(note: Note, context: NSManagedObjectContext, completion: @escaping (Image?) -> Void)
      {
        self.note = note
        self.managedObjectContext = context
        self.completion = completion

        // Configure the flow layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        super.init(collectionViewLayout: layout)
      }


    // MARK: - UIViewController

    required init?(coder aDecoder: NSCoder)
      {
        fatalError("init(coder:) has not been implemented")
      }


    override func loadView()
      {
        super.loadView()

        // Configure the various buttons
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImage(_:)))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteSelected(_:)))
        deleteButton.isEnabled = false

        // Configure the toolbar
        toolbar = UIToolbar(frame: .zero)
        toolbar.setItems([flexibleSpace, addButton, flexibleSpace, deleteButton, flexibleSpace], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        // Configure the layout bindings for the toolbar
        toolbar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        toolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolbar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
      }


    override func viewDidLoad()
      {
        super.viewDidLoad()

        // Configure the collection view
        collectionView!.backgroundColor = .white
        collectionView!.allowsSelection = true
        collectionView!.allowsSelection = true
        collectionView!.allowsMultipleSelection = true

        // Register our custom cell with the collection view
        collectionView!.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
      }


    override func viewWillDisappear(_ animated: Bool)
      {
        super.viewWillDisappear(animated)

        // If the presentedViewController is nil and we're moving from the parentView
        if presentedViewController == nil && isMovingFromParentViewController {

          // Attempt to save the managedObjectContext
          do { try managedObjectContext.save() }
          catch let e { fatalError("failed to save: \(e)") }

          // Execute the completion callback
          completion(sortedImages.first)
        }
      }


    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
      {
        // Add the selected item's index to the set of selected indices
        selectedIndices.insert(indexPath.row)

        // Enable the delete button if there's at least 1 item selected
        deleteButton.isEnabled = selectedIndices.count > 0
      }


    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
      {
        // Remove the selected item's index from the list of selected images
        selectedIndices.remove(indexPath.row)

        // Enable the delete button if there's at least 1 item selected
        deleteButton.isEnabled = selectedIndices.count > 0
      }


    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int
      {
        return 1
      }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
      {
        return note.images.count
      }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
      {
        // Dequeue a cell from the collection view
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell

        // Set the image view
        cell.imageView.image = sortedImages[indexPath.row].image

        return cell
      }


    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
      {
        // Get the original version of the selected image
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        // Create a new Image instance, and add it to the set of recipes
        let newImage = Image(index: Int16(note.images.count), imageData: nil, context: managedObjectContext)
        newImage.image = selectedImage
        note.images.insert(newImage)

        // Reload the collection view
        collectionView?.reloadData()

        // Dismiss the picker
        dismiss(animated: true, completion: nil)
      }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
      {
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
      }


    // MARK: - Actions

    func addImage(_ sender: AnyObject?)
      {
        // Configure a number of alert actions
        var actions = [UIAlertAction]()

        // Always configure a cancel action
        actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Configure a camera button if a camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
          actions.append(UIAlertAction(title: "Camera", style: .default, handler:
              { (action: UIAlertAction) in
                // Present a UIImagePickerController for the photo library
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
              }))
        }

        // Configure a photo library button if a photo library is available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
          actions.append(UIAlertAction(title: "Photo Library", style: .default, handler:
            { (action: UIAlertAction) in
              // Present a UIImagePickerController for the camera
              let imagePickerController = UIImagePickerController()
              imagePickerController.sourceType = .photoLibrary
              imagePickerController.delegate = self
              self.present(imagePickerController, animated: true, completion: nil)
            }))
        }

        // Configure and present an alert controller
        let alertController = UIAlertController(title: "Image Selection", message: "Choose the image source you'd like to use", preferredStyle: .alert)
        for action in actions {
          alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
      }


    func deleteSelected(_ sender: AnyObject?)
      {
        // Sanity check
        assert(selectedIndices.count > 0, "unexpected state - no items to delete")

        // Perform a batch update on the collection view
        collectionView!.performBatchUpdates(
            {
              // Build an array of collection view index paths to remove
              let selectedIndexPaths = self.selectedIndices.map
                  { (index: Int) -> IndexPath in
                    return IndexPath(row: index, section: 0)
                  }

              // Build a set of the selected images, and remove them from the primary set
              let selectedImages = self.selectedIndices.map
                  { (index: Int) -> Image in
                    return self.sortedImages[index]
                  }
              self.note.images.subtract(selectedImages)

              // Delete the items at those index paths
              self.collectionView!.deleteItems(at: selectedIndexPaths)

              // Clear the set of selected image indices
              self.selectedIndices.removeAll()
            },
        completion:
            { (complete: Bool) in
              // Iterate over the remaining images
              for (index, image) in self.sortedImages.enumerated() {
                // Update the image index if necessary
                if image.index != Int16(index) {
                  image.index = Int16(index)
                }
              }
            })
      }


    // MARK: - ImageCollectionViewCell

    class ImageCollectionViewCell: UICollectionViewCell
      {

        var imageView: UIImageView!

        override var isSelected: Bool
          {
            didSet {
              // Indicate selection status by changing the border color of the image view
              imageView.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.lightGray.cgColor
            }
          }


        override init(frame: CGRect)
          {
            // Call super's implementation
            super.init(frame: frame)

            // Configure the image view
            imageView = UIImageView(frame: .zero)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 5.0
            imageView.layer.borderWidth = 1.0
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(imageView)

            // Configure the layout bindings for the image view
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
          }

        // MARK: - UIView

        required init?(coder aDecoder: NSCoder)
          {
            fatalError("init(coder:) has not been implemented")
          }

      }

  }
