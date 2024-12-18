import UIKit
import SnapKit
import MapKit

final class OrderFooterView: UIView {
    let paymentSegmentedControl = UISegmentedControl(items: ["Cash", "Card"])
    let mapView = MKMapView()
    let addressTextField = UITextField()
    let confirmButton = UIButton(type: .system)

    var onConfirmTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = .white
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        
        paymentSegmentedControl.selectedSegmentIndex = 0
        addressTextField.placeholder = "Enter delivery address manually"
        addressTextField.borderStyle = .roundedRect
        
        confirmButton.setTitle("Confirm Order", for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        confirmButton.backgroundColor = .systemPink
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        addSubviews(paymentSegmentedControl, mapView, addressTextField, confirmButton)
        setupLayout()
    }

    private func setupLayout() {
        paymentSegmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        mapView.snp.makeConstraints {
            $0.top.equalTo(paymentSegmentedControl.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(180)
        }

        addressTextField.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(addressTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    @objc private func confirmTapped() {
        onConfirmTapped?()
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
