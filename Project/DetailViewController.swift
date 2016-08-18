import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("timeStamp")!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
}

