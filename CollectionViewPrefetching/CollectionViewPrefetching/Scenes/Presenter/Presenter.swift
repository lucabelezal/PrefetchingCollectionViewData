import Foundation

protocol CustomPresenterProtocol: AnyObject {
    var view: CustomViewControllerProtocol? { get set }
    func fetchData()
    func fetchData(for model: CustomModel, with cell: CustomCollectionViewCell)
    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<CustomModel>?
    func fetchAsync(for indexPaths: [IndexPath])
    func cancelFetch(for indexPaths: [IndexPath])
}

final class CustomPresenter: CustomPresenterProtocol {
    weak var view: CustomViewControllerProtocol?

    private let asyncFetcher: AsyncFetcher<CustomModel>
    private var models: [CustomModel] = []

    init(asyncFetcher: AsyncFetcher<CustomModel> = AsyncFetcher<CustomModel>()) {
        self.asyncFetcher = asyncFetcher
    }

    func fetchData() {
        let models = (1 ... 1000).map { number in
            CustomModel(message: "\(number)")
        }
        self.models.append(contentsOf: models)
        view?.show(models: models)
    }

    func fetchData(for model: CustomModel, with cell: CustomCollectionViewCell) {
        asyncFetcher.fetchAsync(for: model) { fetchedData in
            DispatchQueue.main.async {
                guard cell.representedIdentifier == model.identifier else { return }
                cell.configure(with: fetchedData)
            }
        }
    }

    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<CustomModel>? {
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
