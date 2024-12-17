import Foundation
import UIKit

class User: Identifiable {
    let id: Int
    var name: String
    let avatar: UIImage?
    var deliveryAddress: String
    var orders: [Order] = []
    var phoneNumber: String?

    init(id: Int, name: String, avatar: UIImage?, deliveryAddress: String, phoneNumber: String?) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.deliveryAddress = deliveryAddress
        self.phoneNumber = phoneNumber
    }

    public func addOrder(_ order: Order) {
        orders.append(order)
    }
}
