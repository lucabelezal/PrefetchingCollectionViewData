//import Foundation
//
//let emoji = "🐍,👍,💄,🎏,🐠,🍔,🏩,🎈,🐷,👠,🐣,🐙,✈️,💅,⛑,👑,👛,🐝,🌂,🌻,🎼,🎧,🚧,📎,🍻".components(separatedBy: ",")
//
//class DataStore {
//  private var emojiRatings = emoji.map { EmojiRating(emoji: $0, rating: "") }
//  
//  public var numberOfEmoji: Int {
//    return emojiRatings.count
//  }
//  
//  public func loadEmojiRating(at index: Int) -> DataLoadOperation? {
//    if (0..<emojiRatings.count).contains(index) {
//      return DataLoadOperation(emojiRatings[index])
//    }
//    return .none
//  }
//  
//  public func update(emojiRating: EmojiRating) {
//    if let index = emojiRatings.firstIndex(where: { $0.emoji == emojiRating.emoji }) {
//      emojiRatings.replaceSubrange(index...index, with: [emojiRating])
//    }
//  }
//}
