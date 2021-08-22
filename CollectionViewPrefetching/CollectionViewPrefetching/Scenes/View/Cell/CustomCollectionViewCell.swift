import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()

    static let reuseIdentifier = "CustomCollectionViewCell"
    var representedIdentifier: UUID?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
    }

    func configure(with data: DisplayData<CustomModel>?) {
        backgroundColor = data?.model.color
        titleLabel.text = data?.model.message
    }
}
