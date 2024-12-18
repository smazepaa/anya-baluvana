import UIKit
import SnapKit

final class OrderItemCell: UITableViewCell {
    static let identifier = "OrderItemCell"

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()

    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.autorepeat = false
        return stepper
    }()

    private var onQuantityChanged: ((Int) -> Void)?

    func configure(with product: Product, quantity: Int, onQuantityChanged: @escaping (Int) -> Void) {
        quantityLabel.text = "\(quantity) ×"
        productNameLabel.text = product.name.uppercased()
        let totalPrice = product.price * Double(quantity)
        priceLabel.text = "\(String(format: "%.2f", totalPrice)) $"

        stepper.value = Double(quantity)
        self.onQuantityChanged = onQuantityChanged
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func stepperValueChanged() {
        let newQuantity = Int(stepper.value)
        onQuantityChanged?(newQuantity)
    }

    private func setupLayout() {
        contentView.addSubview(quantityLabel)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(stepper)

        quantityLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        productNameLabel.snp.makeConstraints {
            $0.leading.equalTo(quantityLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        stepper.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }

        priceLabel.snp.makeConstraints {
            $0.trailing.equalTo(stepper.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
        }
    }
}
