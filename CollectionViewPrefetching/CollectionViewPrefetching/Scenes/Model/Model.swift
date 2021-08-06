import UIKit

final class Model: NSObject, Identifiable {
    var identifier = UUID()
    private(set) var color: UIColor
    private(set) var message: String
    
    init(message: String, color: UIColor = .red) {
        self.message = message
        self.color = color
    }
}
