import Foundation
import Combine
import UIKit

final class UserViewModel: ObservableObject {
    
    @Published private(set) var user: User?
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let fileName = "User"

    init() {
        loadUserFromCSV()
    }

    private func loadUserFromCSV() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            guard let fileURL = Bundle.main.url(forResource: self.fileName, withExtension: "csv") else {
                print("CSV file not found.")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let csvData = try String(contentsOf: fileURL, encoding: .utf8)
                let parsedUser = self.parseCSVData(csvData: csvData)
                
                DispatchQueue.main.async {
                    self.user = parsedUser
                    self.isLoading = false
                }
            } catch {
                print("Error loading CSV file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    private func parseCSVData(csvData: String) -> User? {
        let lines = csvData.components(separatedBy: "\n")
        
        guard let line = lines.dropFirst().first else { return nil }
        let components = line.components(separatedBy: ",")
        
        guard components.count >= 5 else { return nil }
        
        let id = Int(components[0].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let name = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneNumber = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
        let deliveryAddress = components[3].trimmingCharacters(in: .whitespacesAndNewlines)
        let avatarName = components[4].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let avatar = UIImage(named: avatarName)
        return User(id: id, name: name, avatar: avatar, deliveryAddress: deliveryAddress, phoneNumber: phoneNumber)
    }

    func updateUser(name: String? = nil, phoneNumber: String? = nil, deliveryAddress: String? = nil) {
        guard let currentUser = user else { return }

        if let newName = name { currentUser.name = newName }
        if let newPhone = phoneNumber { currentUser.phoneNumber = newPhone }
        if let newAddress = deliveryAddress { currentUser.deliveryAddress = newAddress }

        user = currentUser
        saveUserToCSV(user: currentUser)
    }

    private func saveUserToCSV(user: User) {
        let csvHeader = "id,name,phoneNumber,deliveryAddress,avatar\n"
        let csvLine = "\(user.id),\(user.name),\(user.phoneNumber ?? ""),\(user.deliveryAddress),user3"

        let csvString = csvHeader + csvLine

        DispatchQueue.global(qos: .background).async {
            if let fileURL = self.getDocumentDirectory()?.appendingPathComponent("user.csv") {
                do {
                    try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("CSV file updated successfully.")
                } catch {
                    print("Error saving CSV file: \(error.localizedDescription)")
                }
            }
        }
    }

    private func getDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
