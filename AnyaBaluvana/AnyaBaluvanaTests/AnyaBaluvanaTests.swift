//
//  AnyaBaluvanaTests.swift
//  AnyaBaluvanaTests
//
//  Created by Yarrochka on 15.12.2024.
//

import XCTest
@testable import AnyaBaluvana
import Combine
import MapKit

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
        let expectation = XCTestExpectation(description: "Add product")
        
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.store.getAllProducts().count, 1)
            XCTAssertEqual(self.store.getProduct(productId: product.id)?.name, "Test Product")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStoreLowStockProducts() {
        let expectation = XCTestExpectation(description: "Low stock products")
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lowStockProducts = self.store.lowStockProducts(threshold: 3)
            XCTAssertEqual(lowStockProducts.count, 1)
            XCTAssertEqual(lowStockProducts.first?.name, "Low Stock Product")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStoreRemoveProduct() {
        let expectation = XCTestExpectation(description: "Remove product")
        
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.store.getAllProducts().count, 1)
            
            self.store.removeProduct(productId: product.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertEqual(self.store.getAllProducts().count, 0)
                XCTAssertNil(self.store.getProduct(productId: product.id))
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStoreUpdateProduct() {
        let expectation = XCTestExpectation(description: "Update product")
        
        let productId = UUID()
        let product = Product(
            id: productId,
            name: "Original Product",
            description: "Original Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let updatedProduct = Product(
                id: productId,
                name: "Updated Product",
                description: "Updated Description",
                price: 149.99,
                stockLevel: 15
            )
            
            self.store.updateProduct(product: updatedProduct)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let retrievedProduct = self.store.getProduct(productId: productId)
                XCTAssertEqual(retrievedProduct?.name, "Updated Product")
                XCTAssertEqual(retrievedProduct?.description, "Updated Description")
                XCTAssertEqual(retrievedProduct?.price, 149.99)
                XCTAssertEqual(retrievedProduct?.stockLevel, 15)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStoreAddToOrder() {
        let expectation = XCTestExpectation(description: "Add to order")
        
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.store.addToOrder(productId: product.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let orderItems = self.store.getOrderItems()
                let quantities = self.store.getOrderQuantities()
                
                XCTAssertEqual(orderItems.count, 1)
                XCTAssertEqual(quantities[product.id], 1)
                XCTAssertEqual(self.store.getProduct(productId: product.id)?.stockLevel, 9)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStoreGetCurrentOrder() {
        let expectation = XCTestExpectation(description: "Get current order")
        
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.store.addToOrder(productId: product.id)
            self.store.addToOrder(productId: product.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let currentOrder = self.store.getCurrentOrder()
                XCTAssertEqual(currentOrder.count, 1)
                XCTAssertEqual(currentOrder.first?.quantity, 2)
                XCTAssertEqual(currentOrder.first?.product.name, "Test Product")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStoreUpdateOrderQuantity() {
        let expectation = XCTestExpectation(description: "Update order quantity")
        
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.store.addToOrder(productId: product.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.store.updateOrderQuantity(productId: product.id, quantity: 3)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(self.store.getOrderQuantities()[product.id], 3)
                    
                    self.store.updateOrderQuantity(productId: product.id, quantity: 0)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        XCTAssertNil(self.store.getOrderQuantities()[product.id])
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testStoreRemoveFromOrder() {
        let expectation = XCTestExpectation(description: "Remove from order")
        
        let product = Product(
            id: UUID(),
            name: "Test Product",
            description: "Test Description",
            price: 99.99,
            stockLevel: 10
        )
        
        store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.store.addToOrder(productId: product.id)
            self.store.addToOrder(productId: product.id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.store.removeFromOrder(productId: product.id)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertNil(self.store.getOrderQuantities()[product.id])
                    XCTAssertEqual(self.store.getProduct(productId: product.id)?.stockLevel, 10)
                    XCTAssertTrue(self.store.getCurrentOrder().isEmpty)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - ViewModel Tests
    
    func testViewModelAddNewProduct() {
        let expectation = XCTestExpectation(description: "Add new product")
        
        viewModel.addNewProduct(
            name: "New Product",
            description: "New Description",
            price: 49.99,
            stockLevel: 5
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let products = self.viewModel.store.getAllProducts()
            XCTAssertEqual(products.count, 1)
            XCTAssertEqual(products.first?.name, "New Product")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewModelUpdateProduct() {
        let expectation = XCTestExpectation(description: "Update product")
        
        let product = Product(
            id: UUID(),
            name: "Original Name",
            description: "Original Description",
            price: 99.99,
            stockLevel: 10
        )
        
        viewModel.store.addProduct(product: product)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.updateProductInformation(
                id: product.id,
                name: "Updated Name",
                description: "Updated Description",
                price: 149.99,
                stockLevel: 15
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let updatedProduct = self.viewModel.store.getProduct(productId: product.id)
                XCTAssertEqual(updatedProduct?.name, "Updated Name")
                XCTAssertEqual(updatedProduct?.description, "Updated Description")
                XCTAssertEqual(updatedProduct?.price, 149.99)
                XCTAssertEqual(updatedProduct?.stockLevel, 15)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewModelAddToOrderWithInsufficientStock() {
            let expectation = XCTestExpectation(description: "Add to order with insufficient stock")
            
            let product = Product(
                id: UUID(),
                name: "Test Product",
                description: "Test Description",
                price: 99.99,
                stockLevel: 1
            )
            
            viewModel.store.addProduct(product: product)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let order = Order()
                let success = self.viewModel.addProductToOrder(order: order, productID: product.id, quantity: 2)
                
                XCTAssertFalse(success)
                XCTAssertTrue(order.products.isEmpty)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
        
        func testViewModelUpdateOrder() {
            let expectation = XCTestExpectation(description: "Update order")
            
            let product = Product(
                id: UUID(),
                name: "Test Product",
                description: "Test Description",
                price: 99.99,
                stockLevel: 10
            )
            
            viewModel.store.addProduct(product: product)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.store.addToOrder(productId: product.id)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.viewModel.store.updateOrder(productId: product.id, newQuantity: 3)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let currentOrder = self.viewModel.store.getCurrentOrder()
                        XCTAssertEqual(currentOrder.first?.quantity, 3)
                        XCTAssertEqual(self.viewModel.store.getProduct(productId: product.id)?.stockLevel, 7)
                        expectation.fulfill()
                    }
                }
            }
            
            wait(for: [expectation], timeout: 1.5)
        }
        
        func testViewModelRemoveFromOrder() {
            let expectation = XCTestExpectation(description: "Remove from order")
            
            let product = Product(
                id: UUID(),
                name: "Test Product",
                description: "Test Description",
                price: 99.99,
                stockLevel: 10
            )
            
            viewModel.store.addProduct(product: product)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.store.addToOrder(productId: product.id)
                self.viewModel.store.addToOrder(productId: product.id)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let currentOrderBefore = self.viewModel.store.getCurrentOrder()
                    XCTAssertEqual(currentOrderBefore.first?.quantity, 2)
                    
                    self.viewModel.store.removeFromOrder(productId: product.id)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let currentOrderAfter = self.viewModel.store.getCurrentOrder()
                        XCTAssertTrue(currentOrderAfter.isEmpty)
                        XCTAssertEqual(self.viewModel.store.getProduct(productId: product.id)?.stockLevel, 10)
                        expectation.fulfill()
                    }
                }
            }
            
            wait(for: [expectation], timeout: 1.5)
        }
        
        func testViewModelGetLowStockProducts() {
            let expectation = XCTestExpectation(description: "Get low stock products")
            
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
            
            viewModel.store.addProduct(product: product1)
            viewModel.store.addProduct(product: product2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let lowStockProducts = self.viewModel.store.lowStockProducts(threshold: 3)
                XCTAssertEqual(lowStockProducts.count, 1)
                XCTAssertEqual(lowStockProducts.first?.name, "Low Stock Product")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
        
        func testViewModelGetAllProducts() {
            let expectation = XCTestExpectation(description: "Get all products")
            
            let product1 = Product(
                id: UUID(),
                name: "Product 1",
                description: "Description 1",
                price: 99.99,
                stockLevel: 10
            )
            
            let product2 = Product(
                id: UUID(),
                name: "Product 2",
                description: "Description 2",
                price: 149.99,
                stockLevel: 5
            )
            
            viewModel.store.addProduct(product: product1)
            viewModel.store.addProduct(product: product2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let allProducts = self.viewModel.store.getAllProducts()
                XCTAssertEqual(allProducts.count, 2)
                XCTAssertTrue(allProducts.contains { $0.name == "Product 1" })
                XCTAssertTrue(allProducts.contains { $0.name == "Product 2" })
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
        
        func testViewModelMultipleOperations() {
            let expectation = XCTestExpectation(description: "Multiple operations")
            
            let product = Product(
                id: UUID(),
                name: "Test Product",
                description: "Test Description",
                price: 99.99,
                stockLevel: 10
            )
            
            viewModel.store.addProduct(product: product)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.store.addToOrder(productId: product.id)
                self.viewModel.store.addToOrder(productId: product.id)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let orderBefore = self.viewModel.store.getCurrentOrder()
                    XCTAssertEqual(orderBefore.first?.quantity, 2)
                    XCTAssertEqual(self.viewModel.store.getProduct(productId: product.id)?.stockLevel, 8)
                    
                    self.viewModel.store.updateOrder(productId: product.id, newQuantity: 5)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let orderAfter = self.viewModel.store.getCurrentOrder()
                        XCTAssertEqual(orderAfter.first?.quantity, 5)
                        XCTAssertEqual(self.viewModel.store.getProduct(productId: product.id)?.stockLevel, 5)
                        
                        expectation.fulfill()
                    }
                }
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
