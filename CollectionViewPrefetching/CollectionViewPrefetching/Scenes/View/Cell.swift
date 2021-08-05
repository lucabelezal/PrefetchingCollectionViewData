import UIKit

final class Cell: UICollectionViewCell {
    static let reuseIdentifier = "Cell"

    var representedIdentifier: UUID?

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
    }

    func configure(with data: DisplayData?) {
        backgroundColor = data?.color
    }
}
