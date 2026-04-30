import Foundation
import CoreLocation

struct ParkingSpot: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let parkedAt: Date
    let expiresAt: Date
    var addressTitle: String?
    var addressSubtitle: String?
    var photoFilename: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var timeRemaining: TimeInterval {
        max(0, expiresAt.timeIntervalSinceNow)
    }

    var isExpired: Bool {
        Date() >= expiresAt
    }
}
