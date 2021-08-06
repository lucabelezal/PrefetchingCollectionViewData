import UIKit

protocol Identifiable: NSObject {
     var identifier: UUID { get }
}

final class Model: NSObject, Identifiable {
    var identifier = UUID()
    private(set) var color: UIColor
    private(set) var message: String
    
    init(message: String, color: UIColor = .red) {
        self.message = message
        self.color = color
    }
}

final class DisplayData<Model: Identifiable> {
    private(set) var model: Model
    
    init(model: Model) {
        self.model = model
    }
}
