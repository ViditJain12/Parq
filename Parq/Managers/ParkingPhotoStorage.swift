import Foundation
import UIKit

struct ParkingPhotoStorage {
    private let fileManager = FileManager.default

    func saveParkingPhoto(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.88) else { return nil }

        let filename = "parking-photo-\(UUID().uuidString).jpg"
        let url = documentsDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    func loadParkingPhoto(filename: String) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deleteParkingPhoto(filename: String) {
        let url = documentsDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: url)
    }

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
