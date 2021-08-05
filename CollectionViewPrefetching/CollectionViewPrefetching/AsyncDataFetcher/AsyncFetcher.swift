import Foundation

final class AsyncFetcher {
    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    private var completionHandlers = [UUID: [(DisplayData?) -> Void]]()
    private var cache = NSCache<NSUUID, DisplayData>()

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }

    func fetchAsync(_ identifier: UUID, completion: ((DisplayData?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[identifier, default: []]
                self.completionHandlers[identifier] = handlers + [completion]
            }
            self.fetchData(for: identifier)
        }
    }

    func fetchedData(for identifier: UUID) -> DisplayData? {
        return cache.object(forKey: identifier as NSUUID)
    }

    func cancelFetch(_ identifier: UUID) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }
            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }

    private func fetchData(for identifier: UUID) {
        guard operation(for: identifier) == nil else { return }
        
        if let data = fetchedData(for: identifier) {
            invokeCompletionHandlers(for: identifier, with: data)
            
        } else {
            let operation = AsyncFetcherOperation(identifier: identifier)
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
                self.cache.setObject(fetchedData, forKey: identifier as NSUUID)
                
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: identifier, with: fetchedData)
                }
            }
            fetchQueue.addOperation(operation)
        }
    }

    private func operation(for identifier: UUID) -> AsyncFetcherOperation? {
        for case let fetchOperation as AsyncFetcherOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
            return fetchOperation
        }
        return nil
    }

    private func invokeCompletionHandlers(for identifier: UUID, with fetchedData: DisplayData) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}
