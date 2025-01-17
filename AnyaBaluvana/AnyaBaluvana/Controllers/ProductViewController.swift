import UIKit
import SnapKit
import Combine

final class ProductsViewController: UIViewController {

    private let loadingView: LoadingView
    private let viewModel: InventoryViewModel
    private let collectionView: UICollectionView
    private var cancellables = Set<AnyCancellable>()

    private let filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["A-Z", "Z-A", "Price ⬆️", "Price ⬇️"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .white
        control.selectedSegmentTintColor = .systemPink
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemPink], for: .normal)
        return control
    }()

    init(viewModel: InventoryViewModel) {
        self.loadingView = LoadingView()
        self.viewModel = viewModel
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 16, height: 222)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "AnyaBaluvana Store"

        setupView()
        setupViewModelPublishers()

        viewModel.fetchProducts()
    }

    private func setupView() {
        collectionView.register(ProductGridCell.self, forCellWithReuseIdentifier: ProductGridCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white

        view.addSubview(filterControl)
        view.addSubview(collectionView)
        view.addSubview(loadingView)

        filterControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(filterControl.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        loadingView.isHidden = true

        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    private func setupViewModelPublishers() {
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                self?.showLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$store
            .combineLatest(viewModel.$isLoading)
            .sink { [weak self] _, isLoading in
                guard !isLoading else { return }
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
        collectionView.isHidden = show

        if show {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
    }

    @objc private func filterChanged() {
        let selectedIndex = filterControl.selectedSegmentIndex

        switch selectedIndex {
        case 0:
            viewModel.sortProductsAlphabeticallyAsc()
        case 1:
            viewModel.sortProductsAlphabeticallyDesc()
        case 2:
            viewModel.sortProductsByPriceAsc()
        case 3:
            viewModel.sortProductsByPriceDesc()
        default:
            break
        }

        collectionView.reloadData()
    }

}

extension ProductsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.store.getAllProducts().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductGridCell.identifier,
            for: indexPath
        ) as? ProductGridCell else {
            return UICollectionViewCell()
        }

        let product = viewModel.sortedProducts[indexPath.row]
        let imageName = product.name
        let image = UIImage(named: "\(imageName)") ?? UIImage(systemName: "photo")!

        cell.setupCell(with: product, productImage: image) { [weak self] addedProduct in
            print("Added product: \(addedProduct.name)")
            self?.handleProductAdded(product: addedProduct)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = viewModel.sortedProducts[indexPath.row]
        let imageName = selectedProduct.name
        let image = UIImage(named: "\(imageName)") ?? UIImage(systemName: "photo")!

        let detailsVC = ProductDetailsViewController(
            product: selectedProduct,
            productImage: image,
            store: viewModel.store
        ) { [weak self] addedProduct in
            self?.handleProductAdded(product: addedProduct)
        }
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    private func handleProductAdded(product: Product) {
        let store = viewModel.store
        store.addToOrder(productId: product.id)

        if let index = viewModel.sortedProducts.firstIndex(where: { $0.id == product.id }) {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.reloadItems(at: [indexPath])
        }

        print("Product \(product.name) added to the order. Remaining stock: \(product.stockLevel)")
    }
}
