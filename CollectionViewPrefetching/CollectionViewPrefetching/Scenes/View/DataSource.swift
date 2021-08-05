import UIKit

final class DataSource: NSObject {
    private let asyncFetcher = AsyncFetcher()
    private let collectionView: UICollectionView
    private let models: [Model]
    
    init(collectionView: UICollectionView, models: [Model]) {
        self.collectionView = collectionView
        self.models = models
        super.init()
        registerCell()
    }
    
    private func registerCell() {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    private func fetchData(for identifier: UUID, with cell: Cell) {
        asyncFetcher.fetchAsync(identifier) { fetchedData in
            DispatchQueue.main.async {
                guard cell.representedIdentifier == identifier else { return }
                cell.configure(with: fetchedData)
            }
        }
    }
    
    private func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData? {
        asyncFetcher.fetchedData(for: identifier)
    }
    
    private func clearCell(cell: Cell) {
        cell.configure(with: nil)
    }
    
    private func fetchAsync(for indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            asyncFetcher.fetchAsync(model.identifier)
        }
    }
    
    private func cancelFetch(for indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            asyncFetcher.cancelFetch(model.identifier)
        }
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
        
        if let fetchedData = checkIfHasAlreadyFetchedData(for: identifier) {
            cell.configure(with: fetchedData)
        } else {
            clearCell(cell: cell)
            fetchData(for: identifier, with: cell)
        }
        
        return cell
    }
}

extension DataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        fetchAsync(for: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelFetch(for: indexPaths)
    }
}
