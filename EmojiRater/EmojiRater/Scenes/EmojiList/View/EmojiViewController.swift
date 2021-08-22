import UIKit

protocol EmojiViewControllerProtocol: AnyObject {
    
}

final class EmojiViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(EmojiViewCell.self, forCellWithReuseIdentifier: "EmojiViewCell")
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var ratingOverlayView: RatingOverlayView = {
        let view = RatingOverlayView(frame: view.bounds)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var previewInteraction: UIPreviewInteraction = {
        let view = UIPreviewInteraction(view: collectionView)
        view.delegate = self
        return view
    }()
    
    private let presenter: EmojiPresenterProtocol
    private let loadingQueue = OperationQueue()
    private var loadingOperations: [IndexPath: DataLoadOperation] = [:]
        
    init(presenter: EmojiPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiViewController: CodeView {
    func buildViewHierarchy() {
        [collectionView, ratingOverlayView].forEach(view.addSubview)
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        ratingOverlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            ratingOverlayView.leftAnchor.constraint(equalTo: view.leftAnchor),
            ratingOverlayView.rightAnchor.constraint(equalTo: view.rightAnchor),
            ratingOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            ratingOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupAdditionalConfiguration() {
        collectionView.backgroundColor = .white
    }
}

extension EmojiViewController: EmojiViewControllerProtocol {}

extension EmojiViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfEmoji
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiViewCell", for: indexPath)
        
        if let cell = cell as? EmojiViewCell {
            cell.updateAppearanceFor(.none, animated: false)
        }
        return cell
    }
}

extension EmojiViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 48) / 2
        return CGSize(width: size, height: size)
    }
}

extension EmojiViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? EmojiViewCell else { return }
        
        let updateCellClosure: (EmojiRating?) -> () = { [weak self] emojiRating in
            guard let self = self else {
                return
            }
            cell.updateAppearanceFor(emojiRating, animated: true)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        if let dataLoader = loadingOperations[indexPath] {
            if let emojiRating = dataLoader.emojiRating {
                cell.updateAppearanceFor(emojiRating, animated: false)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if let dataLoader = presenter.loadEmojiRating(at: indexPath.item) {
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
}

extension EmojiViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] {
                continue
            }
            if let dataLoader = presenter.loadEmojiRating(at: indexPath.item) {
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}

extension EmojiViewController: UIPreviewInteractionDelegate {
    func previewInteractionShouldBegin(_ previewInteraction: UIPreviewInteraction) -> Bool {
        if let indexPath = collectionView.indexPathForItem(at: previewInteraction.location(in: collectionView)),
           let cell = collectionView.cellForItem(at: indexPath) {
            ratingOverlayView.beginPreview(forView: cell)
            collectionView.isScrollEnabled = false
            return true
        } else {
            return false
        }
    }
    
    func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        ratingOverlayView.endInteraction()
        collectionView.isScrollEnabled = true
    }
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction,
                            didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        ratingOverlayView.updateAppearance(forPreviewProgress: transitionProgress)
    }
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction,
                            didUpdateCommitTransition transitionProgress: CGFloat, ended: Bool) {
        let hitPoint = previewInteraction.location(in: ratingOverlayView)
        if ended {
            let updatedRating = ratingOverlayView.completeCommit(at: hitPoint)
            if let indexPath = collectionView.indexPathForItem(at: previewInteraction.location(in: collectionView)),
               let cell = collectionView.cellForItem(at: indexPath) as? EmojiViewCell,
               let oldEmojiRating = cell.emojiRating {
                let newEmojiRating = EmojiRating(emoji: oldEmojiRating.emoji, rating: updatedRating)
                presenter.update(emojiRating: newEmojiRating)
                cell.updateAppearanceFor(newEmojiRating)
                collectionView.isScrollEnabled = true
            }
        } else {
            ratingOverlayView.updateAppearance(forCommitProgress: transitionProgress, touchLocation: hitPoint)
        }
    }
}
