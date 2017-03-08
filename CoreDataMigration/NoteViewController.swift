/*

  Written by Jeff Spooner

*/

import UIKit
import CoreData


class NoteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
  {

    var managedObjectContext: NSManagedObjectContext
    var note: Note

    var activeSubview: UIView?
      {
        didSet {
          if let _  = activeSubview {
            navigationItem.setRightBarButton(doneButton, animated: true)
            navigationItem.hidesBackButton = true
          }
          else {
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.hidesBackButton = false
          }
        }
      }

    var titleTextField: UITextField!
    var bodyTextView: UITextView!
    var imageView: UIImageView!
    var noImageLabel: UILabel!

    var doneButton: UIBarButtonItem!


    // MARK: - 

    init(note: Note, editing: Bool, context: NSManagedObjectContext)
      {
        self.note = note
        self.managedObjectContext = context

        super.init(nibName: nil, bundle: nil)
      }


    // MARK: - UIViewController

    required init?(coder aDecoder: NSCoder)
      {
        fatalError("init(coder:) has not been implemented")
      }


    override func loadView()
      {
        let window = UIApplication.shared.windows.first!
        let navigationBar = (window.rootViewController! as! UINavigationController).navigationBar

        let offset = navigationBar.frame.origin.y + navigationBar.frame.height

        let width = window.frame.width
        let height = window.frame.height - offset

        // Create the root view
        view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.backgroundColor = UIColor.white
        view.isOpaque = true

        // Create the title text field
        titleTextField = UITextField(frame: CGRect.zero)
        titleTextField.font = UIFont(name: "Helvetica", size: 18)
        titleTextField.placeholder = "Title"
        titleTextField.textAlignment = .center
        titleTextField.returnKeyType = .done
        titleTextField.borderStyle = .roundedRect
        titleTextField.isUserInteractionEnabled = true
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.delegate = self
        view.addSubview(titleTextField)

        // Create the body text view
        bodyTextView = UITextView(frame: .zero)
        bodyTextView.font = UIFont(name: "Helvetica", size: 16)
        bodyTextView.layer.cornerRadius = 5.0
        bodyTextView.layer.borderWidth = 0.5
        bodyTextView.layer.borderColor = UIColor.lightGray.cgColor
        bodyTextView.isEditable = true
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.delegate = self
        view.addSubview(bodyTextView)

        // Configure the image view
        imageView = UIImageView(frame: .zero)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5.0
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectImage(_:))))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // Configure the no image label
        noImageLabel = UILabel(frame: .zero)
        noImageLabel.text = "No photo selected"
        noImageLabel.textAlignment = .center
        noImageLabel.font = UIFont(name: "Helvetica", size: 24)
        noImageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noImageLabel)

        // Configure the layout bindings for the title text field
        titleTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        titleTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        titleTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        titleTextField.heightAnchor.constraint(equalToConstant: 30.0).isActive = true

        // Configure the layout bindings for the body text view
        bodyTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8.0).isActive = true
        bodyTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        bodyTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        bodyTextView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true

        // Configure the layout bindings for the image view
        imageView.widthAnchor.constraint(equalToConstant: 320.0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 320.0).isActive = true
        imageView.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 8.0).isActive = true

        // Configure the layout bindings for the no image label
        noImageLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        noImageLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        noImageLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        noImageLabel.heightAnchor.constraint(equalToConstant: 40.0).isActive = true

        // Create the done button
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.done(_:)))
      }


    override func viewDidLoad()
      {
        super.viewDidLoad()

        // Initialize the text field and text view's text
        titleTextField.text = note.title
        bodyTextView.text = note.body

        // Initialize the image view's image
        imageView.image = note.image?.image ?? UIImage(named: "defaultImage")
        noImageLabel.isHidden = note.image != nil
      }


    override func viewWillDisappear(_ animated: Bool)
      {
        super.viewWillDisappear(animated)

        // If we're moving from the parent view controller
        if isMovingFromParentViewController {

          // Attempt to save the managed object context
          do { try managedObjectContext.save() }
          catch let e { fatalError("failed to save: \(e)") }
        }

      }


    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
      {
        // Set the active subview
        activeSubview = textField
        return true
      }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool
      {
        // Have the text field resign as first
        textField.resignFirstResponder()
        return true
      }


    func textFieldDidEndEditing(_ textField: UITextField)
      {
        // Set the active subview to nil
        if activeSubview === textField {
          activeSubview = nil
        }

        // Update the note's title
        note.title = textField.text ?? ""
      }


    // MARK: - UITextViewDelegate

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
      {
        // Set the active subview
        activeSubview = textView
        return true
      }


    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
      {
        // Have the text view resign as first responder
        textView.resignFirstResponder()
        return true
      }


    func textViewDidEndEditing(_ textView: UITextView)
      {
        // Set the active subview to nil
        if activeSubview === textView {
          activeSubview = nil
        }

        // Update the note's body
        note.body = textView.text
      }


    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
      {
        // Get the original version of the selected image
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        // If there is an existing image associated with the note, delete it from the managed object context
        if let currentImage = note.image {
          managedObjectContext.delete(currentImage)
        }

        // Create a new image object from the selected image, and associate it with the note
        let newImage = Image(imageData: nil, context: managedObjectContext)
        newImage.image = selectedImage
        note.image = newImage

        // Update the image view's image
        imageView.image = selectedImage

        // Hide the no image label
        noImageLabel.isHidden = true

        // Dismiss the picker
        dismiss(animated: true, completion: nil)
      }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
      {
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
      }


    // MARK: - Actions

    func done(_ sender: AnyObject?)
      {
        // If the active subview is non-nil
        if let subview = activeSubview {

          // If the activeSubview is a textField
          if let textField = subview as? UITextField {
            // Ask it's delegate if we can return, and then have it resign as the first responder
            if textField.delegate!.textFieldShouldReturn!(textField) {
             textField.resignFirstResponder()
            }
          }
          // Otherwise, if the activeSubview is a textView
          else if let textView = subview as? UITextView {
            // Ask it's delegate if we can end editing, and then have it resign as the first responder
            if textView.delegate!.textViewShouldEndEditing!(textView) {
              textView.resignFirstResponder()
            }
          }
          // Otherwise it's some non-text view, so have it resign as first responder
          else {
            subview.resignFirstResponder()
          }
        }

        // Attempt to save the managed object context
        do { try managedObjectContext.save() }
        catch let e { fatalError("failed to save: \(e)") }
      }


    func selectImage(_ sender: AnyObject?)
      {
        // Ensure the active subview resigns as first responder
        activeSubview?.resignFirstResponder()

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

  }
