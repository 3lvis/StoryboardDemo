import UIKit
import DATAStack
import DATASource

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var detailViewController: DetailViewController? = nil
    weak var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest(entityName: "Event")
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]

        let object = DATASource(tableView: self.tableView!, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack!.mainContext) { cell, item, indexPath in
            cell.textLabel!.text = item.valueForKey("timeStamp")!.description
        }

        object.delegate = self

        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject))

        self.tableView.dataSource = self.dataSource

        if let split = self.splitViewController {
            self.detailViewController = (split.viewControllers.first as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed

        super.viewWillAppear(animated)
    }

    func insertNewObject() {
        self.dataStack?.performBackgroundTask { backgroundContext in
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: backgroundContext)
            newManagedObject.setValue(NSDate(), forKey: "timeStamp")

            do {
                try backgroundContext.save()
            } catch {
                abort()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.dataSource.object(indexPath: indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

extension MasterViewController: DATASourceDelegate {
    func dataSource(dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func dataSource(dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.dataStack?.performBackgroundTask { backgroundContext in
            if editingStyle == .Delete {
                let mainThreadObject = dataSource.object(indexPath: indexPath)!
                do {
                    let backgroundThreadObject = try backgroundContext.existingObjectWithID(mainThreadObject.objectID)
                    backgroundContext.deleteObject(backgroundThreadObject)
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
