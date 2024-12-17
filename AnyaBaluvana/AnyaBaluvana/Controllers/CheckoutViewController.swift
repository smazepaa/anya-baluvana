import Foundation
import UIKit
import Combine
import CoreLocation

final class CheckoutViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var viewModel: InventoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var totalAmount: Double = 0.0
    private var paymentMethod: String = "Cash"
    private var address: String = ""
    private var selectedLocation: CLLocationCoordinate2D?
    
    init(viewModel: InventoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Checkout"
        
        setupTableView()
        calculateTotal()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(CheckoutCell.self, forCellReuseIdentifier: CheckoutCell.identifier)
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func calculateTotal() {
        totalAmount = viewModel.getCurrentOrderTotal()
    }
}

extension CheckoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutCell.identifier, for: indexPath) as? CheckoutCell else {
            return UITableViewCell()
        }
        
        cell.configure(
            totalAmount: totalAmount,
            onPaymentMethodChanged: { [weak self] method in
                self?.paymentMethod = method
                print("Payment Method: \(method)")
            },
            onAddressChanged: { [weak self] address in
                self?.address = address
                print("Address: \(address)")
            },
            onLocationSelected: { [weak self] coordinate in
                self?.selectedLocation = coordinate
                print("Location Selected: \(coordinate.latitude), \(coordinate.longitude)")
            }
        )
        
        return cell
    }
}
