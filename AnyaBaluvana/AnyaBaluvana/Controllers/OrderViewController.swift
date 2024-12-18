import UIKit
import SnapKit
import Combine
import MapKit

final class OrderViewController: UIViewController {

    private let tableView = UITableView()
    private let footerView = UIView()
    private let totalAmountLabel = UILabel()
    private let paymentSegmentedControl = UISegmentedControl(items: ["Cash", "Card"])
    private let mapView = MKMapView()
    private let addressTextField = UITextField()
    private let swipeToConfirmLabel = UILabel()
    private let geocoder = CLGeocoder()
    private var viewModel: InventoryViewModel
    private var cancellables = Set<AnyCancellable>()
    private var currentOrder: [(product: Product, quantity: Int)] = []

    init(viewModel: InventoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Current Order"

        setupTableView()
        setupFooter()
        bindViewModel()
        
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(OrderItemCell.self, forCellReuseIdentifier: OrderItemCell.identifier)
        tableView.dataSource = self

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(350)
        }
        updateTableFooter()
    }
    
    private func updateTableFooter() {
        let footerView = UIView()
        totalAmountLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalAmountLabel.textAlignment = .right

        if currentOrder.isEmpty {
            totalAmountLabel.text = ""
            footerView.frame.size.height = 0
        } else {
            let totalAmount = calculateTotalAmount()
            totalAmountLabel.text = "Total: \(String(format: "%.2f", totalAmount)) $"
            footerView.frame.size.height = 50
        }

        footerView.addSubview(totalAmountLabel)
        totalAmountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        tableView.tableFooterView = footerView
    }

    private func createTotalLabel() -> UIView {
        let totalView = UIView()
        totalAmountLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalAmountLabel.textAlignment = .right
        totalAmountLabel.text = "Total: \(String(format: "%.2f", calculateTotalAmount())) ₴"
        totalView.addSubview(totalAmountLabel)
        
        totalAmountLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
        return totalView
    }

    private func setupFooter() {
        view.addSubview(footerView)
        footerView.backgroundColor = .white
        footerView.layer.borderColor = UIColor.lightGray.cgColor
        footerView.layer.borderWidth = 1

        footerView.addSubview(paymentSegmentedControl)
        footerView.addSubview(mapView)
        footerView.addSubview(addressTextField)
        footerView.addSubview(swipeToConfirmLabel)

        paymentSegmentedControl.selectedSegmentIndex = 0
        paymentSegmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(longPressGesture)

        mapView.layer.cornerRadius = 8
        mapView.delegate = self
        mapView.delegate = self

        mapView.snp.makeConstraints {
            $0.top.equalTo(paymentSegmentedControl.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(180)
        }

        addressTextField.placeholder = "Enter delivery address manually"
        addressTextField.borderStyle = .roundedRect
        addressTextField.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm Order", for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        confirmButton.backgroundColor = .systemPink
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmOrder), for: .touchUpInside)

        footerView.addSubview(confirmButton)

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(addressTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(16)
        }

        footerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(400)
        }
    }

    @objc private func confirmOrder() {
        guard !currentOrder.isEmpty else {
            showAlert(title: "Empty Order", message: "Your order is empty. Please add items before confirming.")
            return
        }

        guard let address = addressTextField.text, !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Invalid Address", message: "Please enter or select a delivery address.")
            return
        }

        let total = calculateTotalAmount()
        let paymentMethod = paymentSegmentedControl.selectedSegmentIndex == 0 ? "Cash" : "Card"

        let message = """
        Total: \(String(format: "%.2f", total)) ₴
        Payment: \(paymentMethod)
        Address: \(address)
        """

        showAlert(title: "Order Confirmed", message: "We will reach out to you in a minute!\n\n\(message)")

        currentOrder.removeAll()
        viewModel.clearCurrentOrder()
        tableView.reloadData()
        updateTableFooter()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func bindViewModel() {
        viewModel.$currentOrder
            .sink { [weak self] currentOrder in
                self?.currentOrder = currentOrder
                self?.tableView.reloadData()
                self?.updateTableFooter()
            }
            .store(in: &cancellables)
    }

    @objc private func handleMapTap(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

            mapView.removeAnnotations(mapView.annotations)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Selected Location"
            mapView.addAnnotation(annotation)

            reverseGeocode(coordinate: coordinate)
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self?.addressTextField.text = "Unable to find address"
                return
            }

            if let placemark = placemarks?.first {
                let street = placemark.thoroughfare ?? ""
                let number = placemark.subThoroughfare ?? ""
                let city = placemark.locality ?? ""
                let address = "\(street) \(number), \(city)"
                
                DispatchQueue.main.async {
                    self?.addressTextField.text = address
                }
            } else {
                DispatchQueue.main.async {
                    self?.addressTextField.text = "Address not found"
                }
            }
        }
    }

    private func calculateTotalAmount() -> Double {
        return currentOrder.reduce(0.0) { total, item in
            total + (item.product.price * Double(item.quantity))
        }
    }

}

extension OrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentOrder.isEmpty {
            tableView.setEmptyMessage("You don't have a current order.")
        } else {
            tableView.restore()
        }
        return currentOrder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderItemCell.identifier, for: indexPath) as? OrderItemCell else {
            return UITableViewCell()
        }
        let orderItem = currentOrder[indexPath.row]
        cell.configure(with: orderItem.product, quantity: orderItem.quantity) { [weak self] newQuantity in
            self?.viewModel.updateOrderQuantity(for: orderItem.product.id, newQuantity: newQuantity)
        }
        return cell
    }
}

extension OrderViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "DraggablePin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.isDraggable = true
            annotationView?.animatesDrop = true
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
