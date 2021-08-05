import Foundation

final class AsyncFetcherOperation: Operation {
    let identifier: UUID

    private(set) var fetchedData: DisplayData?

    init(identifier: UUID) {
        self.identifier = identifier
    }

    override func main() {
        // Wait for a second to mimic a slow operation.
        Thread.sleep(until: Date().addingTimeInterval(1))
        guard !isCancelled else { return }
        fetchedData = DisplayData()
    }
}
