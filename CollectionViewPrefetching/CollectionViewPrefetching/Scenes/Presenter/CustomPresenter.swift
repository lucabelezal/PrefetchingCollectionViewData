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
    private var currentPage = 0
    private var isLoading = false

    init(asyncFetcher: CustomAsyncFetcher = CustomAsyncFetcher()) {
        self.asyncFetcher = asyncFetcher
    }

    func fetchData() {
        guard !isLoading else { return }

        isLoading = true
        currentPage += increment()

        // Wait half a second to simulate a slow Internet connection.
        Thread.sleep(until: Date().addingTimeInterval(0.5))
        let newModels = (1 ... currentPage).map { number in
            CustomModel(message: "\(number)")
        }

        models.append(contentsOf: newModels)
        view?.show(models: newModels)

        isLoading = false
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

    private func increment() -> Int {
        20
    }
}
