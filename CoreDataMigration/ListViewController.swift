/*

  Written by Jeff Spooner

*/

import UIKit
import CoreData


class ListViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate
  {

    var managedObjectContext: NSManagedObjectContext

    var fetchRequest: NSFetchRequest<Note>!
    var fetchedResultsController: NSFetchedResultsController<Note>!

    var noteTableView: UITableView!
    let reuseIdentifier = "TableViewCell"

    var addButton: UIBarButtonItem!


    // MARK: - 

    init(context: NSManagedObjectContext)
      {
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
        let windowFrame = (UIApplication.shared.windows.first?.frame)!
        let navigationBarFrame = navigationController!.navigationBar.frame

        let width = windowFrame.width
        let height = windowFrame.height - (navigationBarFrame.origin.y + navigationBarFrame.height)

        // Configure the root view
        view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.backgroundColor = UIColor.white
        view.isOpaque = true

        // Configure the recipe table view
        noteTableView = UITableView(frame: CGRect.zero, style: .plain)
        noteTableView.cellLayoutMarginsFollowReadableWidth = false
        noteTableView.bounces = false
        noteTableView.rowHeight = 50
        noteTableView.dataSource = self
        noteTableView.delegate = self
        noteTableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        noteTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noteTableView)

        // Configure the layout bindings for the note table view
        noteTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noteTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        noteTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        noteTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // Create the various buttons
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addNote(_:)))
      }


    override func viewDidLoad()
      {
        super.viewDidLoad()

        // Configure our initial fetch request
        fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        // Configure the fetched results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        // Attempt to fetch all the notes
        do { try fetchedResultsController.performFetch() }
        catch let e { fatalError("error: \(e)") }

        // Configure the navigation item
        navigationItem.title = "Notes"
        navigationItem.setRightBarButton(addButton, animated: false)
      }


    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
      {
        // Begin the animation block
        noteTableView.beginUpdates()
      }


    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
      {
        // Switch on the type of change
        switch type {

          case .insert:
            // Add a new row to the table view
            noteTableView.insertRows(at: [newIndexPath!], with: .automatic)

          case .update:
            // Reload the row at the given index path
            noteTableView.reloadRows(at: [indexPath!], with: .automatic)

          case .delete:
            // Remove the row at the given index path
            noteTableView.deleteRows(at: [indexPath!], with: .automatic)

          case .move:
            // Reload all of the rows between the given index paths
            var rows: [IndexPath] = []
            for row in indexPath!.row ... newIndexPath!.row {
              rows.append(IndexPath(row: row, section: 0))
            }
            noteTableView.reloadRows(at: rows, with: .fade)
        }
      }


    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
      {
        // End the animation block
        noteTableView.endUpdates()
      }


    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int
      {
        return 1
      }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
      {
        return fetchedResultsController.fetchedObjects!.count
      }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
      {
        // Dequeue a cell from the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell's text label
        let note = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = note.title
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 18)

        return cell
      }


    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
      {
        // Deselect the given row
        noteTableView.deselectRow(at: indexPath, animated: true)

        // Get the selected note
        let note = fetchedResultsController.object(at: indexPath)

        // Create amd show a note view controller for the selected note
        let noteViewController = NoteViewController(note: note, editing: true, context: managedObjectContext)
        show(noteViewController, sender: self)
      }


    // MARK: - Actions

    func addNote(_ sender: AnyObject?)
      {
        // Create a new note
        let note = Note(title: "", body: "", context: managedObjectContext)

        // Create and show a note view controller for the new note
        let noteViewController = NoteViewController(note: note, editing: true, context: managedObjectContext)
        show(noteViewController, sender: self)
      }

  }
