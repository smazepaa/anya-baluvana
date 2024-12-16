//
//  AnyaBaluvanaTests.swift
//  AnyaBaluvanaTests
//
//  Created by Yarrochka on 15.12.2024.
//

import XCTest
@testable import AnyaBaluvana

class StoreSystemTests: XCTestCase {
    var viewModel: InventoryViewModel!
    var store: Store!
    
    override func setUp() {
        super.setUp()
        viewModel = InventoryViewModel()
        store = Store()
    }
    
    override func tearDown() {
        viewModel = nil
        store = nil
        super.tearDown()
    }
    
    
    func testProductInitialization() {
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        XCTAssertEqual(product.name, "Test Product")
        XCTAssertEqual(product.description, "Test Description")
        XCTAssertEqual(product.price, 99.99)
        XCTAssertEqual(product.stockLevel, 10)
    }
    
    func testProductUpdate() {
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        product.updateStockLevel(newStockLevel: 5)
        XCTAssertEqual(product.stockLevel, 5)
    }
    
    
    func testOrderInitialization() {
        let order = Order()
        
        XCTAssertNotNil(order.orderId)
        XCTAssertTrue(order.products.isEmpty)
        XCTAssertEqual(order.totalPrice, 0.0)
    }
    
    func testOrderAddProduct() {
        let order = Order()
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        order.addProduct(product: product, quantity: 2)
        
        XCTAssertEqual(order.products.count, 2)
        XCTAssertEqual(order.totalPrice, 199.98, accuracy: 0.01)
    }
    
    func testOrderRemoveProduct() {
        let order = Order()
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        order.addProduct(product: product, quantity: 2)
        order.removeProduct(productId: product.id)
        
        XCTAssertTrue(order.products.isEmpty)
        XCTAssertEqual(order.totalPrice, 0.0)
    }
    
    
    func testStoreAddProduct() {
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        XCTAssertEqual(store.getAllProducts().count, 1)
        XCTAssertEqual(store.getProduct(productId: product.id)?.name, "Test Product")
    }
    
    func testStoreLowStockProducts() {
        let product1 = Product(
            id: UUID(),
            name: "Low Stock Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 2
        )
        
        let product2 = Product(
            id: UUID(),
            name: "Normal Stock Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product1)
        store.addProduct(product: product2)
        
        let lowStockProducts = store.lowStockProducts(threshold: 3)
        XCTAssertEqual(lowStockProducts.count, 1)
        XCTAssertEqual(lowStockProducts.first?.name, "Low Stock Product")
    }
    
    
    func testViewModelAddNewProduct() {
        viewModel.addNewProduct(
            name: "New Product",
            description: "New Description",
            price: 49.99,
            stockLevel: 5
        )
        
        let products = viewModel.store.getAllProducts()
        XCTAssertEqual(products.count, 1)
        XCTAssertEqual(products.first?.name, "New Product")
    }
    
    func testViewModelUpdateProduct() {
        let product = Product(
            id: UUID(),
            name: "Original Name",
            description: "Original Description",
            price: 99.99,
            stockLevel: 10
        )
        
        viewModel.store.addProduct(product: product)
        viewModel.updateProductInformation(
            id: product.id,
            name: "Updated Name",
            description: "Updated Description",
            price: 149.99,
            stockLevel: 15
        )
        
        let updatedProduct = viewModel.store.getProduct(productId: product.id)
        XCTAssertEqual(updatedProduct?.name, "Updated Name")
        XCTAssertEqual(updatedProduct?.description, "Updated Description")
        XCTAssertEqual(updatedProduct?.price, 149.99)
        XCTAssertEqual(updatedProduct?.stockLevel, 15)
    }
    
    func testViewModelCreateAndFinalizeOrder() {
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        viewModel.store.addProduct(product: product)
        
        let order = Order()
        let success = viewModel.addProductToOrder(order: order, productID: product.id, quantity: 2)
        
        XCTAssertTrue(success)
        XCTAssertEqual(order.products.count, 2)
        
        viewModel.finalizeOrder(order: order)
        
        let updatedProduct = viewModel.store.getProduct(productId: product.id)
        XCTAssertEqual(updatedProduct?.stockLevel, 8)
    }
    
    func testViewModelAddToOrderWithInsufficientStock() {
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 1
        )
        
        viewModel.store.addProduct(product: product)
        
        let order = Order()
        let success = viewModel.addProductToOrder(order: order, productID: product.id, quantity: 2)
        
        XCTAssertFalse(success)
        XCTAssertTrue(order.products.isEmpty)
    }
}
