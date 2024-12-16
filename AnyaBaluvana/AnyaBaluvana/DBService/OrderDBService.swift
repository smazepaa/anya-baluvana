import Foundation

class OrderDBService {
    private let filePath = Bundle.main.path(forResource: "Orders", ofType: "csv") ?? ""
    private let productService = ProductDBService()

    func loadOrders() -> [UUID: Order] {
        var orders: [UUID: Order] = [:]

        guard FileManager.default.fileExists(atPath: filePath),
              let fileContents = try? String(contentsOfFile: filePath) else {
            print("No existing orders file found or unable to read.")
            return orders
        }

        let products = productService.loadProducts()

        let lines = fileContents.components(separatedBy: "\n").dropFirst()
        for line in lines where !line.isEmpty {
            let components = line.components(separatedBy: ",")
            if components.count == 3,
               let orderID = UUID(uuidString: components[0]),
               let totalPrice = Double(components[2]) {
                let productIDs = components[1].components(separatedBy: ";").compactMap { UUID(uuidString: $0) }

                let order = Order()
                order.orderId = orderID
                order.totalPrice = totalPrice
                order.products = productIDs.compactMap { id in products.first { $0.id == id } }
                orders[orderID] = order
            } else {
                print("Warning: Skipping invalid line in CSV: \(line)")
            }
        }
        return orders
    }

    func saveOrders(_ orders: [Order]) {
        var csvContent = "Order ID,Product IDs,Total Price\n"
        for order in orders {
            let productIDs = order.products.map { $0.id.uuidString }.joined(separator: ";")
            csvContent += "\(order.orderId.uuidString),\(productIDs),\(order.totalPrice)\n"
        }
        try? csvContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
}
