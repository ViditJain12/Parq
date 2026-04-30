import CoreLocation
import Combine
import Foundation
import MapKit
import UIKit

@MainActor
final class ParkingViewModel: ObservableObject {
    @Published var parkingSpot: ParkingSpot?
    @Published var parkingPhoto: UIImage?
    @Published var walkingTimeEstimate: TimeInterval?
    @Published var leaveByTime: Date?
    @Published var safetyBufferTime: TimeInterval?
    @Published var showTimerSheet = false
    @Published var errorMessage: String?
    @Published var isFetchingLocation = false

    let locationManager = LocationManager()

    private let storage = ParkingStorage()
    private let photoStorage = ParkingPhotoStorage()
    private let notificationManager = NotificationManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        parkingSpot = storage.load()
        if let filename = parkingSpot?.photoFilename {
            parkingPhoto = photoStorage.loadParkingPhoto(filename: filename)
        }
        locationManager.requestPermission()
        notificationManager.requestPermission()
        bindLocationUpdates()

        if parkingSpot != nil {
            refreshWalkingEstimate()
        }
    }

    func startParkingFlow() {
        errorMessage = nil
        showTimerSheet = false
        isFetchingLocation = true
        locationManager.requestCurrentLocation()
    }

    func saveParkingSpot(minutes: Int) {
        guard let location = locationManager.currentLocation else {
            errorMessage = "Could not get your current location. Try again."
            return
        }

        let now = Date()
        let expiresAt = now.addingTimeInterval(TimeInterval(minutes * 60))

        let spot = ParkingSpot(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            parkedAt: now,
            expiresAt: expiresAt,
            addressTitle: nil,
            addressSubtitle: nil,
            photoFilename: nil
        )

        parkingSpot = spot
        parkingPhoto = nil
        walkingTimeEstimate = nil
        leaveByTime = nil
        safetyBufferTime = nil
        storage.save(spot)
        notificationManager.scheduleParkingNotifications(expiresAt: expiresAt)
        showTimerSheet = false

        updateWalkingEstimate(from: location, to: spot)
        enrichParkingSpotAddress(for: location, baseSpot: spot)
    }

    func clearParkingSpot() {
        if let filename = parkingSpot?.photoFilename {
            photoStorage.deleteParkingPhoto(filename: filename)
        }

        parkingSpot = nil
        parkingPhoto = nil
        walkingTimeEstimate = nil
        leaveByTime = nil
        safetyBufferTime = nil
        storage.clear()
        notificationManager.cancelParkingNotifications()
    }

    func attachParkingPhoto(_ image: UIImage) {
        guard var spot = parkingSpot else { return }

        if let existingFilename = spot.photoFilename {
            photoStorage.deleteParkingPhoto(filename: existingFilename)
        }

        guard let filename = photoStorage.saveParkingPhoto(image: image) else {
            errorMessage = "Could not save your parking photo. Try again."
            return
        }

        spot.photoFilename = filename
        parkingSpot = spot
        parkingPhoto = photoStorage.loadParkingPhoto(filename: filename) ?? image
        storage.save(spot)
    }

    func refreshWalkingEstimate() {
        guard parkingSpot != nil else { return }
        locationManager.requestCurrentLocation()
    }

    func safetyBuffer(for walkingTime: TimeInterval) -> TimeInterval {
        let fiveMinutes: TimeInterval = 5 * 60
        let fifteenMinutes: TimeInterval = 15 * 60

        if walkingTime < fiveMinutes {
            return 2 * 60
        } else if walkingTime <= fifteenMinutes {
            return 5 * 60
        } else {
            return 7 * 60
        }
    }

    private func bindLocationUpdates() {
        locationManager.$currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                guard let self else { return }
                guard let location else { return }

                if self.isFetchingLocation {
                    self.isFetchingLocation = false
                    self.showTimerSheet = true
                }

                if let spot = self.parkingSpot {
                    self.updateWalkingEstimate(from: location, to: spot)
                }
            }
            .store(in: &cancellables)

        locationManager.$locationError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let self, let error else { return }
                guard self.isFetchingLocation else { return }

                self.isFetchingLocation = false

                switch error.code {
                case .denied:
                    self.errorMessage = "Location access is denied. Enable it in Settings for the simulator or app."
                default:
                    self.errorMessage = "Could not get your current location. Try again."
                }
            }
            .store(in: &cancellables)
    }

    func openDirections() {
        guard let spot = parkingSpot else { return }
        let application = UIApplication.shared

        // iOS requires LSApplicationQueriesSchemes to include "comgooglemaps"
        // before canOpenURL can detect whether Google Maps is installed.
        if let googleMapsURL = googleMapsDirectionsURL(for: spot),
           application.canOpenURL(googleMapsURL) {
            application.open(googleMapsURL)
            return
        }

        let location = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = "Parked Car"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }

    private func googleMapsDirectionsURL(for spot: ParkingSpot) -> URL? {
        var components = URLComponents()
        components.scheme = "comgooglemaps"
        components.host = ""
        components.queryItems = [
            URLQueryItem(name: "daddr", value: "\(spot.latitude),\(spot.longitude)"),
            URLQueryItem(name: "directionsmode", value: "walking")
        ]

        return components.url
    }

    private func updateWalkingEstimate(from currentLocation: CLLocation, to spot: ParkingSpot) {
        let source = MKMapItem(location: currentLocation, address: nil)
        let destination = MKMapItem(location: CLLocation(latitude: spot.latitude, longitude: spot.longitude), address: nil)

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculateETA { [weak self] response, error in
            guard let self else { return }
            guard error == nil, let response else {
                Task { @MainActor in
                    self.walkingTimeEstimate = nil
                    self.leaveByTime = nil
                    self.safetyBufferTime = nil

                    if let currentSpot = self.parkingSpot {
                        self.notificationManager.scheduleParkingNotifications(expiresAt: currentSpot.expiresAt)
                    }
                }
                return
            }

            Task { @MainActor in
                let walkingTime = response.expectedTravelTime
                let buffer = self.safetyBuffer(for: walkingTime)
                let leaveTime = spot.expiresAt.addingTimeInterval(-(walkingTime + buffer))

                guard self.isCurrentSession(spot) else { return }

                self.walkingTimeEstimate = walkingTime
                self.safetyBufferTime = buffer
                self.leaveByTime = leaveTime
                self.notificationManager.scheduleParkingNotifications(
                    expiresAt: spot.expiresAt,
                    walkingTime: walkingTime,
                    leaveByTime: leaveTime
                )
            }
        }
    }

    private func enrichParkingSpotAddress(for location: CLLocation, baseSpot: ParkingSpot) {
        guard let request = MKReverseGeocodingRequest(location: location) else { return }

        request.getMapItems { [weak self] mapItems, error in
            guard let self, error == nil, let mapItem = mapItems?.first else { return }

            Task { @MainActor in
                var updatedSpot = baseSpot
                updatedSpot.addressTitle = self.addressTitle(from: mapItem)
                updatedSpot.addressSubtitle = self.addressSubtitle(from: mapItem, title: updatedSpot.addressTitle)

                guard self.isCurrentSession(baseSpot) else { return }

                self.parkingSpot = updatedSpot
                self.storage.save(updatedSpot)
            }
        }
    }

    private func isCurrentSession(_ spot: ParkingSpot) -> Bool {
        guard let currentSpot = parkingSpot else { return false }

        return currentSpot.latitude == spot.latitude &&
            currentSpot.longitude == spot.longitude &&
            currentSpot.parkedAt == spot.parkedAt &&
            currentSpot.expiresAt == spot.expiresAt
    }

    private func addressTitle(from mapItem: MKMapItem) -> String {
        if let shortAddress = mapItem.address?.shortAddress, !shortAddress.isEmpty {
            return shortAddress
                .components(separatedBy: ",")
                .first?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .nonEmpty ?? shortAddress
        }

        if let name = mapItem.name, !name.isEmpty {
            return name
        }

        return "Saved Parking Spot"
    }

    private func addressSubtitle(from mapItem: MKMapItem, title: String?) -> String? {
        var components: [String] = []

        if let name = mapItem.name, !name.isEmpty, name != title {
            components.append(name)
        }

        guard !components.isEmpty else { return nil }

        return "Near " + Array(components.prefix(2)).joined(separator: " | ")
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
