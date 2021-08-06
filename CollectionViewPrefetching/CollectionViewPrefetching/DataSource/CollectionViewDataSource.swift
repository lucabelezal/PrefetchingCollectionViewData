import UIKit

protocol CollectionViewDataSourceProtocol: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

final class CollectionViewDataSource<Model: Identifiable>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    weak var scrollDelegate: CollectionViewDataSourceProtocol?
    
    typealias CellConfigurator = ((UUID, DisplayData<Model>?, UICollectionViewCell) -> Void)?
    
    var fetchData: ((Model, UICollectionViewCell) -> Void)?
    var checkIfHasAlreadyFetchedData: ((UUID) -> DisplayData<Model>?)?
    var fetchAsync: (([IndexPath]) -> Void)?
    var cancelFetch: (([IndexPath]) -> Void)?
    
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
    
    // MARK: - UICollectionViewDelegate -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - UICollectionViewDataSource -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )
        
        let model = models[indexPath.row]
        
        if let fetchedDisplayData = checkIfHasAlreadyFetchedData?(model.identifier) {
            cellConfigurator?(model.identifier, fetchedDisplayData, cell)
        } else {
            cellConfigurator?(model.identifier, nil, cell)
            fetchData?(model, cell)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching -
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        fetchAsync?(indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelFetch?(indexPaths)
    }
}
