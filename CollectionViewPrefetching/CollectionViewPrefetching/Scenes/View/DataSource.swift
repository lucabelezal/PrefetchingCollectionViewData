import UIKit

protocol AsyncFetcherType: AnyObject {
    associatedtype Model: Identifiable
    associatedtype Cell

    func fetchData(for model: Model, with cell: Cell)
    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<Model>?
    func fetchAsync(for model: Model)
    func cancelFetch(for identifier: UUID)
}

final class CustomAsyncFetcher: AsyncFetcherType {
    typealias Model = CustomModel
    typealias Cell = CustomCollectionViewCell

    private var models: [CustomModel] = []
    private let asyncFetcher: AsyncFetcher<Model>

    init(asyncFetcher: AsyncFetcher<Model> = AsyncFetcher<Model>()) {
        self.asyncFetcher = asyncFetcher
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

    func fetchAsync(for model: Model) {
        asyncFetcher.fetchAsync(for: model)
    }

    func cancelFetch(for identifier: UUID) {
        asyncFetcher.cancelFetch(for: identifier)
    }
}

// protocol DataSourceDelegate : class {
//    func dataSourceDidReloadData<P: DataSourceProtocol>(dataSource: P)
// }
// protocol DataSourceProtocol {
//    typealias ItemType
//    weak var delegate: DataSourceDelegate? { get set }
//    func itemAtIndexPath(indexPath: NSIndexPath) -> ItemType?
//    func dataSourceForSectionAtIndex(sectionIndex: Int) -> Self
// }

// protocol DataSourceDelegate: AnyObject {
//    associatedtype Model: Identifiable
//    associatedtype Cell: UICollectionViewCell
//
//    func fetchData(for model: Model, with cell: Cell)
//    func checkIfHasAlreadyFetchedData(for model: Model) -> DisplayData<Model>?
//    func fetchAsync(for indexPaths: [IndexPath])
//    func cancelFetch(for indexPaths: [IndexPath])
// }

final class CollectionViewDataSource<Model>: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    typealias CellConfigurator = ((Model, UICollectionViewCell) -> Void)?

    // weak var delegate: DataSourceDelegate?

    private let models: [Model]
    private let reuseIdentifier: String
    private let cellConfigurator: CellConfigurator

    init(
        models: [Model],
        reuseIdentifier: String,
        cellConfigurator: CellConfigurator
    ) {
        self.models = models
        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }

//    private func clearCell(cell: Cell) {
//        cell.configure(with: nil)
//    }

    // MARK: - UICollectionViewDataSource -

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Cell else {
//            fatalError("Expected `\(Cell.self)` type for reuseIdentifier \(Cell.reuseIdentifier). Check the configuration.")
//        }

//        let model = models[indexPath.row]
//        let identifier = model.identifier
//        cell.representedIdentifier = identifier

//        if let fetchedData = delegate?.checkIfHasAlreadyFetchedData(for: model) {
//            cell.configure(with: fetchedData)
//        } else {
//            clearCell(cell: cell)
//            delegate?.fetchData(for: model, with: cell)
//        }

        let model = models[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )

        cellConfigurator?(model, cell)

        return cell
    }

    // MARK: - UICollectionViewDataSourcePrefetching -

    func collectionView(_: UICollectionView, prefetchItemsAt _: [IndexPath]) {
        // delegate?.fetchAsync(for: indexPaths)
    }

    func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt _: [IndexPath]) {
        // delegate?.cancelFetch(for: indexPaths)
    }
}

// TableViewDataSource
// CollectionViewDataSource

extension CollectionViewDataSource where Model == CustomModel {
    static func make(for messages: [CustomModel], reuseIdentifier: String = "message") -> CollectionViewDataSource {
        return CollectionViewDataSource(
            models: messages,
            reuseIdentifier: reuseIdentifier
        ) { model, cell in
            guard let cell = cell as? CustomCollectionViewCell else { return }
            cell.representedIdentifier = model.identifier

//            if let fetchedData = delegate?.checkIfHasAlreadyFetchedData(for: model) {
//                cell.configure(with: fetchedData)
//            } else {
//                cell.configure(with: nil)
//                delegate?.fetchData(for: model, with: cell)
//            }
        }
    }
}
