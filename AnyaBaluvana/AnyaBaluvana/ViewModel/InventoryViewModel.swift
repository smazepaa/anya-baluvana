import Foundation
import Combine

class InventoryViewModel {
    @Published private(set) var store: Store
    @Published var isLoading: Bool = false
    @Published private var orders: [UUID: Order] = [:]
    @Published var sortedProducts: [Product] = []
    @Published var currentOrder: [(product: Product, quantity: Int)] = []
    
    private var cancellables = Set<AnyCancellable>()

    private let productService = ProductDBService()
    private let orderService = OrderDBService()

    init() {
        self.store = Store()
        loadOrders()
        bindCurrentOrder()
    }
    
    private func bindCurrentOrder() {
        store.$currentOrder
            .map { currentOrder in
                currentOrder.compactMap { id, quantity in
                    guard let product = self.store.getProduct(productId: id) else { return nil }
                    return (product: product, quantity: quantity)
                }
            }
            .assign(to: &$currentOrder)
    }

    func fetchProducts() {
        isLoading = true

        DispatchQueue.global().async {
            let products = self.productService.loadProducts()

            DispatchQueue.main.async {
                for product in products {
                    self.store.addProduct(product: product)
                }
                self.sortedProducts = products
                self.isLoading = false
            }
        }
    }

    private func loadOrders() {
        orders = orderService.loadOrders()
    }

    func addNewProduct(name: String, description: String, price: Double, stockLevel: Int) {
        let newProduct = Product(id: UUID(), name: name, description: description, price: price, stockLevel: stockLevel)
        store.addProduct(product: newProduct)
        productService.saveProducts(store.getAllProducts())
    }

    func removeProductByID(id: UUID) {
        store.removeProduct(productId: id)
        productService.saveProducts(store.getAllProducts())
    }

    func updateProductInformation(id: UUID, name: String?, description: String?, price: Double?, stockLevel: Int?) {
        guard let product = store.getProduct(productId: id) else { return }
        if let name = name { product.name = name }
        if let description = description { product.description = description }
        if let price = price { product.price = price }
        if let stockLevel = stockLevel { product.stockLevel = stockLevel }
        store.updateProduct(product: product)
        productService.saveProducts(store.getAllProducts())
    }

    func addToOrder(product: Product) {
        store.addToOrder(productId: product.id)
    }

    func createOrder(productIDs: [UUID]) {
        let newOrder = Order()
        newOrder.products = productIDs.compactMap { store.getProduct(productId: $0) }
        newOrder.totalPrice = newOrder.products.reduce(0) { $0 + $1.price }
        orders[newOrder.orderId] = newOrder
        orderService.saveOrders(Array(orders.values))
    }

    func addProductToOrder(order: Order, productID: UUID, quantity: Int) -> Bool {
        guard let product = store.getProduct(productId: productID) else { return false }
        guard product.stockLevel >= quantity else { return false }

        order.addProduct(product: product, quantity: quantity)
        return true
    }

    func finalizeOrder(order: Order) {
        for product in order.products {
            if let storedProduct = store.getProduct(productId: product.id) {
                storedProduct.updateStockLevel(newStockLevel: storedProduct.stockLevel - 1)
                store.updateProduct(product: storedProduct)
                productService.saveProducts(store.getAllProducts())
            }
        }
        orders.removeValue(forKey: order.orderId)
        orderService.saveOrders(Array(orders.values))
    }
    
    func updateOrderQuantity(for productId: UUID, newQuantity: Int) {
        guard let _ = store.getProduct(productId: productId) else { return }
        store.updateOrder(productId: productId, newQuantity: newQuantity)
        updateCurrentOrder()
    }

    func removeProductFromOrder(productId: UUID) {
        store.removeFromOrder(productId: productId)
        updateCurrentOrder()
    }

    private func updateCurrentOrder() {
        currentOrder = store.getCurrentOrder()
    }
    
    func getCurrentOrderTotal() -> Double {
        let total = currentOrder.reduce(0.0) { sum, item in
            sum + (item.product.price * Double(item.quantity))
        }
        return total
    }

    func clearCurrentOrder() {
        currentOrder = []
    }

    func sortProductsAlphabeticallyAsc() {
        sortedProducts = store.getAllProducts().sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func sortProductsAlphabeticallyDesc() {
        sortedProducts = store.getAllProducts().sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
        }
    }

    func sortProductsByPriceAsc() {
        sortedProducts = store.getAllProducts().sorted { $0.price < $1.price }
    }

    func sortProductsByPriceDesc() {
        sortedProducts = store.getAllProducts().sorted { $0.price > $1.price }
    }
}
