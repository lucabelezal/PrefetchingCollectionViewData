import UIKit

final class EmojiViewCell: UICollectionViewCell {
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 140, weight: .bold)
        label.textAlignment = .center
        label.text = "🐍"
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        label.textAlignment = .center
        label.text = "👍"
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        return indicator
    }()
        
    var emojiRating: EmojiRating?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        DispatchQueue.main.async {
            self.displayEmojiRating(.none)
        }
    }
    
    func updateAppearanceFor(_ emojiRating: EmojiRating?, animated: Bool = true) {
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: 0.5) {
                    self.displayEmojiRating(emojiRating)
                }
            } else {
                self.displayEmojiRating(emojiRating)
            }
        }
    }
    
    private func displayEmojiRating(_ emojiRating: EmojiRating?) {
        self.emojiRating = emojiRating
        if let emojiRating = emojiRating {
            emojiLabel.text = emojiRating.emoji
            ratingLabel.text = emojiRating.rating
            emojiLabel.alpha = 1
            ratingLabel.alpha = 1
            loadingIndicator.alpha = 0
            loadingIndicator.stopAnimating()
            backgroundColor = #colorLiteral(red: 0.9338415265, green: 0.9338632822, blue: 0.9338515401, alpha: 1)
            layer.cornerRadius = 10
        } else {
            emojiLabel.alpha = 0
            ratingLabel.alpha = 0
            loadingIndicator.alpha = 1
            loadingIndicator.startAnimating()
            backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            layer.cornerRadius = 10
        }
    }
}

extension EmojiViewCell: CodeView {
    func buildViewHierarchy() {
        [emojiLabel, ratingLabel, loadingIndicator].forEach(addSubview)
    }
    
    func setupConstraints() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.leftAnchor.constraint(equalTo: leftAnchor),
            emojiLabel.rightAnchor.constraint(equalTo: rightAnchor),
            emojiLabel.topAnchor.constraint(equalTo: topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ratingLabel.widthAnchor.constraint(equalToConstant: 60),
            ratingLabel.heightAnchor.constraint(equalToConstant: 54),
            ratingLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 8),
            ratingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 8),
            ratingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
