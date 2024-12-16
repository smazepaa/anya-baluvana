import UIKit
import SnapKit

final class ProductDetailsViewController: UIViewController {

    private let product: Product
    private let productImage: UIImage
    private let onAdd: (Product) -> Void
    private let store: Store

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()

    private let detailsCell = ProductDetailsCell()

    init(product: Product, productImage: UIImage, store: Store, onAdd: @escaping (Product) -> Void) {
        self.product = product
        self.productImage = productImage
        self.store = store
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = product.name

        setupView()
        configureCell()
    }

    private func setupView() {
        view.addSubview(containerView)
        containerView.addSubview(detailsCell)

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.85)
            $0.height.equalTo(418)
        }

        detailsCell.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }

    private func configureCell() {
        detailsCell.setupCell(with: product, productImage: productImage) { [weak self] addedProduct in
            self?.handleProductAdded(addedProduct)
        }
    }

    private func handleProductAdded(_ product: Product) {
        store.addToOrder(productId: product.id)
        print("Product \(product.name) added to the order. Remaining stock: \(store.getProduct(productId: product.id)?.stockLevel ?? 0)")
        detailsCell.reloadStockLevel(stockLevel: product.stockLevel)
    }
}
