import UIKit

extension UIScrollView {
    func hasReachedVerticalLimit() -> Bool {
        let usedOffset = contentOffset.y
        let availableOffset = contentSize.height - frame.height
        return usedOffset > availableOffset &&
            usedOffset >= 0 && availableOffset >= 0
    }

    func hasReachedHorizontalLimit() -> Bool {
        let usedOffset = contentOffset.x
        let availableOffset = contentSize.width - frame.width
        return usedOffset > availableOffset
    }

    func getCurrentPage() -> Int {
        let pageWidth = frame.width
        let contentOffSet = contentOffset.x
        return Int(round(contentOffSet / pageWidth))
    }
}
