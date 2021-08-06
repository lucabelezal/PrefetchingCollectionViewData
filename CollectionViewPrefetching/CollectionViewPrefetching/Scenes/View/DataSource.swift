import UIKit

protocol DataSourceDelegate: AnyObject {
    func fetchData(for model: Model, with cell: Cell)
    func checkIfHasAlreadyFetchedData(for model: Model) -> DisplayData<Model>?
    func fetchAsync(for indexPaths: [IndexPath])
    func cancelFetch(for indexPaths: [IndexPath])
}

final class DataSource: NSObject {    
    weak var delegate: DataSourceDelegate?
    
    private let models: [Model]
    
    init(models: [Model]) {
        self.models = models
    }
    
    private func clearCell(cell: Cell) {
        cell.configure(with: nil)
    }
}

extension DataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Expected `\(Cell.self)` type for reuseIdentifier \(Cell.reuseIdentifier). Check the configuration.")
        }
        
        let model = models[indexPath.row]
        let identifier = model.identifier
        cell.representedIdentifier = identifier
        
        if let fetchedData = delegate?.checkIfHasAlreadyFetchedData(for: model) {
            cell.configure(with: fetchedData)
        } else {
            clearCell(cell: cell)
            delegate?.fetchData(for: model, with: cell)
        }
        
        return cell
    }
}

extension DataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        delegate?.fetchAsync(for: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        delegate?.cancelFetch(for: indexPaths)
    }
}
