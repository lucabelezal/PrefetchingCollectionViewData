import Foundation

protocol EmojiServiceProtocol {
    func fetch(completion: (() -> Result<[EmojiRating], Error>)?)
}

final class EmojiService: EmojiServiceProtocol {
    func fetch(completion: (() -> Result<[EmojiRating], Error>)?) {

    }
}
