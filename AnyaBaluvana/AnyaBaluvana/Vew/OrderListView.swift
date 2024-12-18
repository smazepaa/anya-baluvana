import UIKit

final class OrderListView: UIView {
    private let tableView = UITableView()
    private var order: [(product: Product, quantity: Int)] = []

    var onDeleteItem: ((UUID) -> Void)?
    var onQuantityChanged: ((UUID, Int) -> Void)?

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .right
        label.text = "Total: 0.00 ₴"
        return label
    }()

    init() {
        super.init(frame: .zero)
        setupTableView()
        setupTableFooter()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupTableView() {
        addSubview(tableView)
        tableView.register(OrderItemCell.self, forCellReuseIdentifier: OrderItemCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupTableFooter() {
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.frame.size.height = 50

        footerView.addSubview(totalAmountLabel)
        totalAmountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        tableView.tableFooterView = footerView
    }

    func updateOrder(_ newOrder: [(product: Product, quantity: Int)]) {
        order = newOrder

        if order.isEmpty {
            setEmptyMessage("You don't have a current order.")
        } else {
            restore()
            updateTotalAmount()
        }

        tableView.reloadData()
    }

    private func updateTotalAmount() {
        let total = order.reduce(0.0) { result, item in
            result + (item.product.price * Double(item.quantity))
        }
        totalAmountLabel.text = "Total: \(String(format: "%.2f", total)) ₴"
    }

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 18, weight: .medium)
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
        tableView.tableFooterView = nil
    }

    func restore() {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
        setupTableFooter()
    }
}

extension OrderListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderItemCell.identifier, for: indexPath) as? OrderItemCell else {
            return UITableViewCell()
        }
        let orderItem = order[indexPath.row]
        cell.configure(with: orderItem.product, quantity: orderItem.quantity) { [weak self] newQuantity in
            self?.onQuantityChanged?(orderItem.product.id, newQuantity)
            self?.order[indexPath.row].quantity = newQuantity
            self?.updateTotalAmount()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let productId = order[indexPath.row].product.id
            onDeleteItem?(productId)

            order.remove(at: indexPath.row)
            updateTotalAmount()
            if order.isEmpty {
                setEmptyMessage("You don't have a current order.")
            } else {
                restore()
            }
            tableView.reloadData()
        }
    }
}
