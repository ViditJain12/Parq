import Foundation

final class ParkingStorage {
    private let key = "saved_parking_spot"

    func save(_ spot: ParkingSpot) {
        guard let data = try? JSONEncoder().encode(spot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func load() -> ParkingSpot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ParkingSpot.self, from: data)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
