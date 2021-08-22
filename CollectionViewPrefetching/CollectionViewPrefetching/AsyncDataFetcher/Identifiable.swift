import Foundation

protocol Identifiable: NSObject {
    var identifier: UUID { get }
}
