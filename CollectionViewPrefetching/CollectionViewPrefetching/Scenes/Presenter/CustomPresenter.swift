import UIKit

protocol CustomPresenterProtocol: AnyObject {
    var view: CustomViewControllerProtocol? { get set }
    func fetchData()
    func fetchData(for model: CustomModel, with cell: UICollectionViewCell)
    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<CustomModel>? 
    func fetchAsync(for indexPaths: [IndexPath])
    func cancelFetch(for indexPaths: [IndexPath])
}

final class CustomPresenter: CustomPresenterProtocol {
    weak var view: CustomViewControllerProtocol?
    
    private let asyncFetcher: CustomAsyncFetcher
    private var models: [CustomModel] = []
    
    init(asyncFetcher: CustomAsyncFetcher = CustomAsyncFetcher()) {
        self.asyncFetcher = asyncFetcher
    }
    
    func fetchData(){
        let models = (1...1000).map { number in
            return CustomModel(message: "\(number)")
        }
        self.models.append(contentsOf: models)
        view?.show(models: models)
    }
    
    func fetchData(for model: CustomModel, with cell: UICollectionViewCell) {
        asyncFetcher.fetchData(for: model, with: cell)
    }

    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<CustomModel>? {
        asyncFetcher.checkIfHasAlreadyFetchedData(for: identifier)
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
            asyncFetcher.cancelFetch(for: model.identifier)
        }
    }
}
