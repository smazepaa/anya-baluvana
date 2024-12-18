import UIKit
import Combine

final class OrderViewController: UIViewController {
    private let orderListView = OrderListView()
    private let footerView = OrderFooterView()
    private var viewModel: InventoryViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: InventoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Current Order"

        setupLayout()
        bindViewModel()
        
        footerView.onConfirmTapped = { [weak self] in self?.confirmOrder() }
        orderListView.onDeleteItem = { [weak self] productId in
            self?.viewModel.removeProductFromOrder(productId: productId)
        }
    }
    
    private func setupLayout() {
        view.addSubview(orderListView)
        view.addSubview(footerView)

        orderListView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(footerView.snp.top)
        }

        footerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(400)
        }
    }

    private func bindViewModel() {
        viewModel.$currentOrder
            .sink { [weak self] order in
                self?.orderListView.updateOrder(order)
                self?.updateFooterVisibility(order: order)
            }
            .store(in: &cancellables)
    }

    private func updateFooterVisibility(order: [(product: Product, quantity: Int)]) {
        footerView.isHidden = order.isEmpty
    }

    private func confirmOrder() {
        guard let address = footerView.addressTextField.text, !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Invalid Address", message: "Please enter or select a delivery address.")
            return
        }

        let total = viewModel.getCurrentOrderTotal()
        let message = """
        Total: \(String(format: "%.2f", total)) ₴
        Payment: \(footerView.paymentSegmentedControl.titleForSegment(at: footerView.paymentSegmentedControl.selectedSegmentIndex) ?? "")
        Address: \(address)
        """
        showAlert(title: "Order Confirmed", message: message)
        viewModel.clearCurrentOrder()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
