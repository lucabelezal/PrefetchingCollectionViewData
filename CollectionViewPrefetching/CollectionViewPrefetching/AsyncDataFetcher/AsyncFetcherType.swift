import Foundation

protocol AsyncFetcherType: AnyObject {
    associatedtype Model: Identifiable
    associatedtype Cell

    func fetchData(for model: Model, with cell: Cell)
    func checkIfHasAlreadyFetchedData(for identifier: UUID) -> DisplayData<Model>?
    func fetchAsync(for model: Model)
    func cancelFetch(for identifier: UUID)
}
