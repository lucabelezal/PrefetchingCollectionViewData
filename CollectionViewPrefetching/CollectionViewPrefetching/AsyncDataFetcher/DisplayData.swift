import UIKit

final class DisplayData: NSObject {
    var color: UIColor = .red
    var message: String
    
    init(message: String) {
        self.message = message
        super.init()
    }
}
