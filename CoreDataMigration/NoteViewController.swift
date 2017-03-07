/*

  Written by Jeff Spooner

*/

import UIKit
import CoreData


class NoteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate
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

        // Create the done button
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.done(_:)))
      }


    override func viewDidLoad()
      {
        super.viewDidLoad()

        // Initialize the text field and text view's text
        titleTextField.text = note.title
        bodyTextView.text = note.body
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

  }
