import Foundation

final class AsyncFetcherOperation<Model: Identifiable>: Operation {
    private(set) var fetchedData: DisplayData<Model>?
    private(set) var model: Model
    
    init(model: Model) {
        self.model = model
    }

    override func main() {
        // Wait for a second to mimic a slow operation.
        Thread.sleep(until: Date().addingTimeInterval(1))
        guard !isCancelled else { return }
        fetchedData = DisplayData(model: model)
    }
}
