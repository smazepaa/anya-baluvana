import UIKit
import SnapKit

final class ProductGridCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        return view
    }()

    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .right
        return label
    }()

    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .left
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add +", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.isEnabled = false
        return button
    }()

    public static let identifier = "ProductGridCell"

    private var product: Product?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        stockLabel.text = nil
        addButton.isEnabled = false
        addButton.backgroundColor = .systemGray
        product = nil
    }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(productImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(stockLabel)
        containerView.addSubview(addButton)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        productImageView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(8)
            $0.centerX.equalTo(containerView)
            $0.width.height.equalTo(110)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(8)
            $0.leading.equalTo(containerView.snp.leading).offset(12)
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(8)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-12)
        }

        stockLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(containerView.snp.leading).offset(12)
        }

        addButton.snp.makeConstraints {
            $0.top.equalTo(stockLabel.snp.bottom).offset(10)
            $0.centerX.equalTo(containerView)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }

    func setupCell(with product: Product, productImage: UIImage, onAdd: @escaping (Product) -> Void) {
        self.product = product
        self.onAdd = onAdd

        productImageView.image = productImage
        nameLabel.text = product.name
        priceLabel.text = String(format: "$%.2f", product.price)
        stockLabel.text = product.stockLevel > 0 ? "In stock" : "Out of stock"
        stockLabel.textColor = product.stockLevel > 0 ? .darkGray : .systemRed

        addButton.isEnabled = product.stockLevel > 0
        addButton.backgroundColor = product.stockLevel > 0 ? .systemPink : .systemGray
    }

    private var onAdd: ((Product) -> Void)?

    @objc private func didTapAddButton() {
        guard let product = product else { return }
        onAdd?(product)
    }

    func reloadStockLevel(stockLevel: Int) {
        stockLabel.text = stockLevel > 0 ? "In stock" : "Out of stock"
        addButton.isEnabled = stockLevel > 0
        addButton.backgroundColor = stockLevel > 0 ? .systemPink : .systemGray
    }
}
