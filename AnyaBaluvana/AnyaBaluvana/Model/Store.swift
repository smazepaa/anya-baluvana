import Foundation

class Store {
    private var products: [UUID: Product] = [:]
    private var currentOrder: [UUID: Int] = [:]

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
}
