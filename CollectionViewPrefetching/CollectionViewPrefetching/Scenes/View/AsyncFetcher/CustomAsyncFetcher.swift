import UIKit

final class CustomAsyncFetcher: AsyncFetcherType {
    typealias Model = CustomModel
    typealias Cell = UICollectionViewCell
    
    private var models: [CustomModel] = []
    private let asyncFetcher: AsyncFetcher<Model>
    
    init(asyncFetcher: AsyncFetcher<Model> = AsyncFetcher<Model>()) {
        self.asyncFetcher = asyncFetcher
    }
    
    func fetchData(for model: CustomModel, with cell: UICollectionViewCell) {
        asyncFetcher.fetchAsync(for: model) { fetchedData in
            DispatchQueue.main.async {
                guard
                    let cell = cell as? CustomCollectionViewCell,
                    cell.representedIdentifier == model.identifier else { return }
                
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
