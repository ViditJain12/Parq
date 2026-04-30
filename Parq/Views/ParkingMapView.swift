import MapKit
import SwiftUI
import UIKit

struct ParkingMapView: View {
    let spot: ParkingSpot
    let photo: UIImage?
    let onNavigate: () -> Void

    @State private var cameraPosition: MapCameraPosition

    init(spot: ParkingSpot, photo: UIImage?, onNavigate: @escaping () -> Void) {
        self.spot = spot
        self.photo = photo
        self.onNavigate = onNavigate

        let region = MKCoordinateRegion(
            center: spot.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )

        _cameraPosition = State(initialValue: .region(region))
    }

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    mapCard

                    if let photo {
                        photoCard(photo)
                    }

                    Button {
                        onNavigate()
                    } label: {
                        Label("Navigate Back", systemImage: "location.north.fill")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Theme.accentBlueBright, Theme.accentBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Theme.cardShadow, radius: 20, y: 8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Parked Location")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mapCard: some View {
        Map(position: $cameraPosition) {
            Marker("Parked Car", coordinate: spot.coordinate)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .frame(height: 460)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Theme.cardBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.24), radius: 22, y: 10)
    }

    private func photoCard(_ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Parking Photo")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Garage / floor reference")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .padding(18)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
            .fill(Theme.card.opacity(0.92))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            }
    }
}

#Preview {
    NavigationStack {
        ParkingMapView(
            spot: ParkingSpot(
                latitude: 37.7858,
                longitude: -122.4064,
                parkedAt: .now.addingTimeInterval(-1800),
                expiresAt: .now.addingTimeInterval(1800),
                addressTitle: "O'Farrell St",
                addressSubtitle: "Near Union Square",
                photoFilename: nil
            ),
            photo: nil,
            onNavigate: {}
        )
    }
    .preferredColorScheme(.dark)
}
