import UIKit
import CoreData

class DetailViewController: UIViewController {
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var detailItem: NSManagedObject? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.value(forKey: "timeStamp").debugDescription
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }
}

