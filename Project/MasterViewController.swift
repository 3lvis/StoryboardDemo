import UIKit
import Sync
import DATASource

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var detailViewController: DetailViewController? = nil
    weak var dataStack: DataStack?

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]

        let object = DATASource(tableView: self.tableView!, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack!.mainContext) { cell, item, indexPath in
            let timeStamp = item.value(forKey: "timeStamp") as! Date
            cell.textLabel?.text = timeStamp.debugDescription
        }

        object.delegate = self

        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject))

        self.tableView.dataSource = self.dataSource
    }

    @objc func insertNewObject() {
        self.dataStack?.performBackgroundTask { backgroundContext in
            let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Event", into: backgroundContext)
            newManagedObject.setValue(Date(), forKey: "timeStamp")

            do {
                try backgroundContext.save()
            } catch {
                abort()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.dataSource.object(indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
            }
        }
    }
}

extension MasterViewController: DATASourceDelegate {
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        self.dataStack?.performBackgroundTask { backgroundContext in
            if editingStyle == .delete {
                let mainThreadObject = dataSource.object(indexPath)!
                do {
                    let backgroundThreadObject = try backgroundContext.existingObject(with: mainThreadObject.objectID)
                    backgroundContext.delete(backgroundThreadObject)
                    do {
                        try backgroundContext.save()
                    } catch {
                        abort()
                    }
                } catch {
                    abort()
                }
            }
        }
    }
}
