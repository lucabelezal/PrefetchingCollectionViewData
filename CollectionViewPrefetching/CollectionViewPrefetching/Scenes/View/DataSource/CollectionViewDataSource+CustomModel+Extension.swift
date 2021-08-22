import Foundation

extension CollectionViewDataSource where Model == CustomModel {
    static func make(for models: [CustomModel], reuseIdentifier: String) -> CollectionViewDataSource {
        return CollectionViewDataSource(
            models: models,
            reuseIdentifier: reuseIdentifier
        ) { identifier, displayData, cell in

            guard let cell = cell as? CustomCollectionViewCell else { return }
            cell.representedIdentifier = identifier
            cell.configure(with: displayData)
        }
    }
}
