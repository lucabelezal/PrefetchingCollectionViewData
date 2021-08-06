import UIKit

protocol CustomViewControllerProtocol: AnyObject {
    func show(models: [CustomModel])
}

final class CustomViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.reuseIdentifier)
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.layer.borderWidth = 2
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var presenter: CustomPresenterProtocol
    private var dataSource: CollectionViewDataSource<CustomModel>?
    
    init(presenter: CustomPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchData()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func setupView() {
        view.backgroundColor = .lightGray
        configureHierarchy()
        configureConstraints()
    }
    
    private func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension CustomViewController: CustomViewControllerProtocol {
    func show(models: [CustomModel]) {
        dataSource = .make(for: models, reuseIdentifier: CustomCollectionViewCell.reuseIdentifier)
        dataSource?.fetchData = presenter.fetchData
        dataSource?.checkIfHasAlreadyFetchedData = presenter.checkIfHasAlreadyFetchedData(for:)
        dataSource?.fetchAsync = presenter.fetchAsync(for:)
        dataSource?.cancelFetch = presenter.cancelFetch(for:)
        
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
    }
}
