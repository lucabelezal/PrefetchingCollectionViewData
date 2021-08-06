import Foundation

protocol PresenterProtocol: AnyObject {
    var view: ViewControllerProtocol? { get set }
    func fetchData()
    func fetchData(for model: Model, with cell: Cell)
    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<Model>?
    func fetchAsync(for indexPaths: [IndexPath])
    func cancelFetch(for indexPaths: [IndexPath])
}

final class Presenter: PresenterProtocol {
    weak var view: ViewControllerProtocol?
    
    private let asyncFetcher: AsyncFetcher
    private var models: [Model] = []
    
    init(asyncFetcher: AsyncFetcher = AsyncFetcher()) {
        self.asyncFetcher = asyncFetcher
    }
    
    func fetchData(){
        let models = (1...1000).map { number in
            return Model(message: "\(number)")
        }
        self.models.append(contentsOf: models)
        view?.show(models: models)
    }
    
    func fetchData(for model: Model, with cell: Cell) {
        asyncFetcher.fetchAsync(for: model) { fetchedData in
            DispatchQueue.main.async {
                guard cell.representedIdentifier == model.identifier else { return }
                cell.configure(with: fetchedData)
            }
        }
    }
    
    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<Model>? {
        asyncFetcher.fetchedData(for: identifier)
    }
        
    func fetchAsync(for indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            asyncFetcher.fetchAsync(for: model)
        }
    }
    
    func cancelFetch(for indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            asyncFetcher.cancelFetch(model.identifier)
        }
    }
}
