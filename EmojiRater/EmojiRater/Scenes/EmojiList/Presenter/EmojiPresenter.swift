import Foundation

protocol EmojiPresenterProtocol {
    var numberOfEmoji: Int { get }
    func loadEmojiRating(at index: Int) -> DataLoadOperation?
    func update(emojiRating: EmojiRating)
}

let emoji = "🐍,👍,💄,🎏,🐠,🍔,🏩,🎈,🐷,👠,🐣,🐙,✈️,💅,⛑,👑,👛,🐝,🌂,🌻,🎼,🎧,🚧,📎,🍻".components(separatedBy: ",")

final class EmojiPresenter: EmojiPresenterProtocol {
    weak var view: EmojiViewControllerProtocol?
    
    private var emojiRatings = emoji.map { EmojiRating(emoji: $0, rating: "") }
    private let service: EmojiServiceProtocol
    
    init(service: EmojiServiceProtocol = EmojiService()) {
        self.service = service
    }
    
    var numberOfEmoji: Int {
      return emojiRatings.count
    }
    
    func loadEmojiRating(at index: Int) -> DataLoadOperation? {
      if (0..<emojiRatings.count).contains(index) {
        return DataLoadOperation(emojiRatings[index])
      }
      return .none
    }
    
    func update(emojiRating: EmojiRating) {
      if let index = emojiRatings.firstIndex(where: { $0.emoji == emojiRating.emoji }) {
        emojiRatings.replaceSubrange(index...index, with: [emojiRating])
      }
    }
}
