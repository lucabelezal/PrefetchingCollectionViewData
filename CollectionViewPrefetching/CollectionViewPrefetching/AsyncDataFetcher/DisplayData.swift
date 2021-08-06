final class DisplayData<Model: Identifiable> {
    private(set) var model: Model
    
    init(model: Model) {
        self.model = model
    }
}
