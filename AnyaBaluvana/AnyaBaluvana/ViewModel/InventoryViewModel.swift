import Foundation
import Combine

class InventoryViewModel {
    @Published private(set) var store: Store
    @Published var isLoading: Bool = false
    @Published private var orders: [UUID: Order] = [:]
    
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
        let products = self.productService.loadProducts()
        for product in products {
            self.store.addProduct(product: product)
        }
        self.isLoading = false
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

}
