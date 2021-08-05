import Foundation

final class AsyncFetcherOperation: Operation {
    let identifier: UUID
    let message: String

    private(set) var fetchedData: DisplayData?

    init(identifier: UUID, message: String) {
        self.identifier = identifier
        self.message = message
    }

    override func main() {
        // Wait for a second to mimic a slow operation.
        Thread.sleep(until: Date().addingTimeInterval(1))
        guard !isCancelled else { return }
        fetchedData = DisplayData(message: message)
    }
}
