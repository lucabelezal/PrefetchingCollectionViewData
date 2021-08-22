import Foundation

final class DataLoadOperation: Operation {
  var emojiRating: EmojiRating?
  var loadingCompleteHandler: ((EmojiRating) ->Void)?
  
  private let _emojiRating: EmojiRating
  
  init(_ emojiRating: EmojiRating) {
    _emojiRating = emojiRating
  }
  
  override func main() {
    if isCancelled { return }
    
    let randomDelayTime = Int.random(in: 500..<2000)
    usleep(useconds_t(randomDelayTime * 1000))
    
    if isCancelled { return }
    emojiRating = _emojiRating
    
    if let loadingCompleteHandler = loadingCompleteHandler {
      DispatchQueue.main.async {
        loadingCompleteHandler(self._emojiRating)
      }
    }
  }
}
