//
//  OrderViewController.swift
//  AnyaBaluvana
//
//  Created by Sofiia Mazepa on 16.12.2024.
//

import UIKit
import SnapKit
import Combine

final class OrderViewController: UIViewController {

    private let tableView = UITableView()
    private var viewModel: InventoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var currentOrder: [(product: Product, quantity: Int)] = []

    // MARK: - Initializer
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
        title = "Current Order"

        setupTableView()
        bindViewModel()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(OrderItemCell.self, forCellReuseIdentifier: OrderItemCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = createFooterView()
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createFooterView() -> UIView {
        let footerView = UIView()
        let totalLabel = UILabel()

        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalLabel.textAlignment = .right
        totalLabel.text = "Total: \(calculateTotal()) ₴"

        footerView.addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        footerView.frame.size.height = 50
        return footerView
    }

    private func calculateTotal() -> String {
        let total = currentOrder.reduce(0.0) { sum, item in
            sum + (item.product.price * Double(item.quantity))
        }
        return String(format: "%.2f", total)
    }

    private func bindViewModel() {
        viewModel.$currentOrder
            .sink { [weak self] currentOrder in
                self?.currentOrder = currentOrder
                self?.tableView.reloadData()
                self?.tableView.tableFooterView = self?.createFooterView()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OrderViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOrder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OrderItemCell.identifier,
            for: indexPath
        ) as? OrderItemCell else {
            return UITableViewCell()
        }

        let orderItem = currentOrder[indexPath.row]
        cell.configure(with: orderItem.product, quantity: orderItem.quantity) { [weak self] newQuantity in
            self?.viewModel.updateOrderQuantity(for: orderItem.product.id, newQuantity: newQuantity)
        }
        return cell
    }

    // Swipe to delete functionality
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let orderItem = currentOrder[indexPath.row]
            viewModel.removeProductFromOrder(productId: orderItem.product.id)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
