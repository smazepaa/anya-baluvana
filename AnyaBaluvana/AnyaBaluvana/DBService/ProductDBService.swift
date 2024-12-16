import Foundation

class ProductDBService {
    private let filePath = Bundle.main.path(forResource: "Products", ofType: "csv") ?? ""

    func loadProducts() -> [Product] {
        var products: [Product] = []

        guard FileManager.default.fileExists(atPath: filePath),
              let fileContents = try? String(contentsOfFile: filePath) else {
            print("No existing products file found or unable to read.")
            return products
        }

        let lines = fileContents.components(separatedBy: "\n").dropFirst()
        for line in lines where !line.isEmpty {
            let components = line.components(separatedBy: ",")
            if components.count == 5,
               let id = UUID(uuidString: components[0]),
               let price = Double(components[3]),
               let stockLevel = Int(components[4]) {
                let name = components[1].removingSurroundingQuotes()
                let description = components[2].removingSurroundingQuotes()

                let product = Product(
                    id: id,
                    name: name,
                    description: description,
                    price: price,
                    stockLevel: stockLevel)
                products.append(product)
            } else {
                print("Warning: Skipping invalid line in CSV: \(line)")
            }
        }
        return products
    }

    func saveProducts(_ products: [Product]) {
        var csvContent = "ID,Name,Description,Price,Stock Level\n"
        for product in products {
            csvContent += "\(product.id.uuidString),\"\(product.name)\",\"\(product.description)\",\(product.price),\(product.stockLevel)\n"
        }
        try? csvContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
}

extension String {
    func removingSurroundingQuotes() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
