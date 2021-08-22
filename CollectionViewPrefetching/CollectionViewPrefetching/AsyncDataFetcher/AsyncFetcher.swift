import Foundation

final class AsyncFetcher<Model: Identifiable> {
    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    private var completionHandlers = [UUID: [(DisplayData<Model>?) -> Void]]()
    private var cache = NSCache<NSUUID, DisplayData<Model>>()

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }

    func fetchAsync(for model: Model, completion: ((DisplayData<Model>?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[model.identifier, default: []]
                self.completionHandlers[model.identifier] = handlers + [completion]
            }
            self.fetchData(for: model)
        }
    }

    func fetchedData(for identifier: UUID) -> DisplayData<Model>? {
        return cache.object(forKey: identifier as NSUUID)
    }

    func cancelFetch(for identifier: UUID) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }
            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }

    private func fetchData(for model: Model) {
        guard operation(for: model.identifier) == nil else { return }

        if let data = fetchedData(for: model.identifier) {
            invokeCompletionHandlers(for: model.identifier, with: data)

        } else {
            let operation = AsyncFetcherOperation(model: model)
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
                self.cache.setObject(fetchedData, forKey: model.identifier as NSUUID)

                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: model.identifier, with: fetchedData)
                }
            }
            fetchQueue.addOperation(operation)
        }
    }

    private func operation(for identifier: UUID) -> AsyncFetcherOperation<Model>? {
        for case let fetchOperation as AsyncFetcherOperation<Model> in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.model.identifier == identifier
        {
            return fetchOperation
        }
        return nil
    }

    private func invokeCompletionHandlers(for identifier: UUID, with fetchedData: DisplayData<Model>) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}
