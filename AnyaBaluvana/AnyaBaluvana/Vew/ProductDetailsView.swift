import UIKit
import SnapKit

final class ProductDetailsCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        return view
    }()

    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .right
        return label
    }()

    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .left
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add in order +", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.isEnabled = false
        return button
    }()

    public static let identifier = "ProductDetailsCell"

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
        descriptionLabel.text = nil
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
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(stockLabel)
        containerView.addSubview(addButton)
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        productImageView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(16)
            $0.centerX.equalTo(containerView)
            $0.width.height.equalTo(200)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(containerView).inset(16)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(containerView).inset(20)
        }

        stockLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.leading.equalTo(containerView.snp.leading).offset(20)
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(9)
            $0.trailing.equalTo(containerView).inset(20)
        }

        addButton.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(20)
            $0.centerX.equalTo(containerView)
            $0.width.equalTo(containerView.snp.width).multipliedBy(0.6)
            $0.height.equalTo(35)
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
        descriptionLabel.text = product.description
        priceLabel.text = String(format: "$%.2f", product.price)
        stockLabel.text = product.stockLevel > 0 ? "In stock (\(product.stockLevel))" : "Out of stock"
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
        stockLabel.text = stockLevel > 0 ? "In stock (\(stockLevel))" : "Out of stock"
        addButton.isEnabled = stockLevel > 0
        addButton.backgroundColor = stockLevel > 0 ? .systemPink : .systemGray
    }
}
