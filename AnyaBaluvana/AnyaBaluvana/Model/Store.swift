import Foundation
import Combine

class Store {
    private var products: [UUID: Product] = [:]
    @Published var currentOrder: [UUID: Int] = [:]

    func addProduct(product: Product) {
        products[product.id] = product
    }

    func removeProduct(productId: UUID) {
        products.removeValue(forKey: productId)
    }

    func updateProduct(product: Product) {
        products[product.id] = product
    }

    func getProduct(productId: UUID) -> Product? {
        return products[productId]
    }

    func getAllProducts() -> [Product] {
        return Array(products.values)
    }

    func lowStockProducts(threshold: Int = 3) -> [Product] {
        return products.values.filter { $0.stockLevel <= threshold }
    }

    func addToOrder(productId: UUID) {
        guard let product = products[productId], product.stockLevel > 0 else { return }
        currentOrder[productId, default: 0] += 1
        products[productId]?.stockLevel -= 1
    }

    func getOrderItems() -> [Product] {
        return currentOrder.compactMap { id, _ in products[id] }
    }

    func getOrderQuantities() -> [UUID: Int] {
        return currentOrder
    }
    
    func getOrders() -> [(product: Product, quantity: Int)] {
        return currentOrder.compactMap { (id, quantity) in
            if let product = products[id] {
                return (product, quantity)
            }
            return nil
        }
    }
    
    func getCurrentOrder() -> [(product: Product, quantity: Int)] {
        return currentOrder.compactMap { id, quantity in
            guard let product = products[id] else { return nil }
            return (product, quantity)
        }
    }
    
    func updateOrderQuantity(productId: UUID, quantity: Int) {
        if quantity == 0 {
            currentOrder.removeValue(forKey: productId)
        } else {
            currentOrder[productId] = quantity
        }
    }
    
    func updateOrder(productId: UUID, newQuantity: Int) {
        guard products[productId] != nil else { return }
        let currentQuantity = currentOrder[productId] ?? 0
        let delta = newQuantity - currentQuantity

        if delta > 0 {
            products[productId]?.stockLevel -= delta
        } else {
            products[productId]?.stockLevel += abs(delta)
        }

        currentOrder[productId] = newQuantity
    }

    func removeFromOrder(productId: UUID) {
        if let quantity = currentOrder[productId] {
            products[productId]?.stockLevel += quantity
        }
        currentOrder.removeValue(forKey: productId)
    }
}
