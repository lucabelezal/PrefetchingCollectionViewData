import UIKit

protocol ViewControllerProtocol: AnyObject {
    func show(models: [CustomModel])
}

final class CustomViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.layer.borderWidth = 2
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private var presenter: PresenterProtocol
    private var dataSource: DataSource<CustomModel>?

    init(presenter: PresenterProtocol) {
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
    required init?(coder _: NSCoder) {
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

extension CustomViewController: ViewControllerProtocol {
    func show(models: [CustomModel]) {
        dataSource = .make(for: models)
        // dataSource?.delegate = self
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
    }
}

// extension ViewController: DataSourceDelegate {
//    func fetchData(for model: CustomModel, with cell: Cell) {
//        presenter.fetchData(for: model, with: cell)
//    }
//
//    func checkIfHasAlreadyFetchedData(for model: CustomModel) -> DisplayData<CustomModel>? {
//        presenter.checkIfHasAlreadyFetchedData(for: model.identifier)
//    }
//
//    func fetchAsync(for indexPaths: [IndexPath]) {
//        presenter.fetchAsync(for: indexPaths)
//    }
//
//    func cancelFetch(for indexPaths: [IndexPath]) {
//        presenter.cancelFetch(for: indexPaths)
//    }
// }
