import Foundation

protocol PresenterProtocol: AnyObject {
    func fetchModels() -> [Model]
}

final class Presenter: PresenterProtocol {
    
    weak var presenter: ViewControllerProtocol?
    
    func fetchModels() -> [Model] {
        let models = (1...1000).map { _ in
            return Model()
        }
        return models
    }
}
