import Foundation
import Combine


class Store {
    private var products: [UUID: Product] = [:]
    @Published var currentOrder: [UUID: Int] = [:]
    private let storeQueue = DispatchQueue(label: "com.store.queue")
    
    func addProduct(product: Product) {
        storeQueue.async {
            self.products[product.id] = product
        }
    }
    
    func removeProduct(productId: UUID) {
        storeQueue.async {
            self.products.removeValue(forKey: productId)
        }
    }
    
    func updateProduct(product: Product) {
        storeQueue.async {
            self.products[product.id] = product
        }
    }
    
    func getProduct(productId: UUID) -> Product? {
        return storeQueue.sync {
            return products[productId]
        }
    }
    
    func getAllProducts() -> [Product] {
        return storeQueue.sync {
            return Array(products.values)
        }
    }
    
    func lowStockProducts(threshold: Int = 3) -> [Product] {
        return storeQueue.sync {
            return products.values.filter { $0.stockLevel <= threshold }
        }
    }
    
    func addToOrder(productId: UUID) {
        storeQueue.async { [weak self] in
            guard let self = self,
                  let product = self.products[productId],
                  product.stockLevel > 0 else { return }
            
            self.products[productId]?.stockLevel -= 1
            
            DispatchQueue.main.async {
                self.currentOrder[productId, default: 0] += 1
            }
        }
    }
    
    func getOrderItems() -> [Product] {
        return storeQueue.sync {
            return currentOrder.compactMap { id, _ in products[id] }
        }
    }
    
    func getOrderQuantities() -> [UUID: Int] {
        return storeQueue.sync {
            return currentOrder
        }
    }
    
    func getOrders() -> [(product: Product, quantity: Int)] {
        return storeQueue.sync {
            return currentOrder.compactMap { (id, quantity) in
                if let product = products[id] {
                    return (product, quantity)
                }
                return nil
            }
        }
    }
    
    func getCurrentOrder() -> [(product: Product, quantity: Int)] {
        return storeQueue.sync {
            return currentOrder.compactMap { id, quantity in
                guard let product = products[id] else { return nil }
                return (product, quantity)
            }
        }
    }
    
    func updateOrderQuantity(productId: UUID, quantity: Int) {
        storeQueue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if quantity == 0 {
                    self.currentOrder.removeValue(forKey: productId)
                } else {
                    self.currentOrder[productId] = quantity
                }
            }
        }
    }
    
    func updateOrder(productId: UUID, newQuantity: Int) {
        storeQueue.async { [weak self] in
            guard let self = self,
                  let _ = self.products[productId] else { return }
            
            let currentQuantity = self.currentOrder[productId] ?? 0
            let delta = newQuantity - currentQuantity
            
            if delta > 0 {
                self.products[productId]?.stockLevel -= delta
            } else {
                self.products[productId]?.stockLevel += abs(delta)
            }
            
            DispatchQueue.main.async {
                self.currentOrder[productId] = newQuantity
            }
        }
    }
    
    func removeFromOrder(productId: UUID) {
        storeQueue.async { [weak self] in
            guard let self = self else { return }
            if let quantity = self.currentOrder[productId] {
                self.products[productId]?.stockLevel += quantity
            }
            
            DispatchQueue.main.async {
                self.currentOrder.removeValue(forKey: productId)
            }
        }
    }
}
