import UIKit
import DATAStack
import DATASource

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    weak var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.dataStack!.mainContext)
        request.entity = entity
        request.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        let object = DATASource(tableView: self.tableView!, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack!.mainContext) { cell, item, indexPath in
            cell.textLabel!.text = item.valueForKey("timeStamp")!.description
        }

        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    func insertNewObject(sender: AnyObject) {
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.dataStack!.mainContext)!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: self.dataStack!.mainContext)
             
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")

        do {
            try self.dataStack!.mainContext.save()
        } catch {
            abort()
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

//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            let context = self.fetchedResultsController.managedObjectContext
//            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
//                
//            do {
//                try context.save()
//            } catch {
//                abort()
//            }
//        }
    }
}

