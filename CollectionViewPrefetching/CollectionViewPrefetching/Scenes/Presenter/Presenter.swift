import Foundation

protocol PresenterProtocol: AnyObject {
    var view: ViewControllerProtocol? { get set }
    func fetchModels()
}

final class Presenter: PresenterProtocol {
    weak var view: ViewControllerProtocol?
    
    func fetchModels(){
        let models = (1...1000).map { _ in
            return Model()
        }
        view?.show(models: models)
    }
}
