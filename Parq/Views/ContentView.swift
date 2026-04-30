import Combine
import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = ParkingViewModel()
    @State private var currentTime = Date()
    @State private var isShowingPhotoSourceDialog = false
    @State private var isShowingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        header

                        if let spot = viewModel.parkingSpot {
                            activeParkingView(spot: spot)
                        } else {
                            idleStateView
                        }

                        if let error = viewModel.errorMessage {
                            errorCard(message: error)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showTimerSheet) {
                TimerSheetView { minutes in
                    viewModel.saveParkingSpot(minutes: minutes)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePickerView(sourceType: imagePickerSourceType) { image in
                    viewModel.attachParkingPhoto(image)
                    isShowingImagePicker = false
                } onCancel: {
                    isShowingImagePicker = false
                }
                .ignoresSafeArea()
            }
            .confirmationDialog("Parking Photo", isPresented: $isShowingPhotoSourceDialog, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Photo") {
                        imagePickerSourceType = .camera
                        isShowingImagePicker = true
                    }
                }

                Button("Choose from Library") {
                    imagePickerSourceType = .photoLibrary
                    isShowingImagePicker = true
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Add a garage, floor, or landmark photo for this parking spot.")
            }
            .onReceive(timer) { date in
                currentTime = date
            }
            .task(id: viewModel.parkingSpot?.parkedAt) {
                if viewModel.parkingSpot != nil {
                    viewModel.refreshWalkingEstimate()
                }
            }
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.background, Theme.backgroundSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Theme.accentBlue.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: -110, y: -210)

            Circle()
                .fill(Theme.accentBlueBright.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 90)
                .offset(x: 130, y: -40)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Parq")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private func activeParkingView(spot: ParkingSpot) -> some View {
        VStack(spacing: 22) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Theme.accentBlue.opacity(0.18))

                    Image(systemName: "car.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accentBlueBright)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Car Parked")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Your parking session is active")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer()
            }

            CountdownRingView(
                parkedAt: spot.parkedAt,
                expiresAt: spot.expiresAt,
                currentTime: currentTime
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 4)

            parkedTimePill(for: spot)

            locationCard

            smartLeaveCard

            parkingPhotoSection

            NavigationLink {
                ParkingMapView(spot: spot, photo: viewModel.parkingPhoto, onNavigate: {
                    viewModel.openDirections()
                })
            } label: {
                Label("View Map", systemImage: "map.fill")
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

            Button {
                viewModel.clearParkingSpot()
            } label: {
                Label("Clear Parking Spot", systemImage: "trash")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.red.opacity(0.08))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    }
                    .foregroundStyle(Theme.destructive)
            }
            .buttonStyle(.plain)
        }
    }

    private var idleStateView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("Save your parking spot in one tap.")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text("A simple reminder, wrapped in a cleaner experience.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(.top, 36)

            Button {
                viewModel.startParkingFlow()
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.accentBlue.opacity(0.18))
                        .frame(width: 270, height: 270)
                        .blur(radius: 22)

                    Circle()
                        .stroke(Theme.accentBlue.opacity(0.2), lineWidth: 24)
                        .frame(width: 236, height: 236)
                        .blur(radius: 8)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accentBlueBright, Theme.accentBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .shadow(color: Theme.cardShadow, radius: 28, y: 10)
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        }

                    if viewModel.isFetchingLocation {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                    } else {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 68, height: 68)
                                    .blur(radius: 4)

                                Image(systemName: "car.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    .symbolEffect(.bounce, options: .repeat(.periodic(delay: 2.2)))
                            }

                            Text("Tap To Park")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isFetchingLocation)

            Text("Tap once when you leave your car and Parq will take care of the rest.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func parkedTimePill(for spot: ParkingSpot) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.badge.checkmark")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.accentBlueBright)

            Text("Parked at \(parkedTimeString(for: spot))")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(Theme.card.opacity(0.9))
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                }
        )
    }

    private var parkingPhotoSection: some View {
        Group {
            if let image = viewModel.parkingPhoto {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Parking Photo")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text("Garage / floor reference")
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondaryText)
                        }

                        Spacer()

                        Button("Replace") {
                            isShowingPhotoSourceDialog = true
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accentBlueBright)
                    }

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 170)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(18)
                .background(cardBackground)
            } else {
                Button {
                    isShowingPhotoSourceDialog = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Theme.accentBlue.opacity(0.16))

                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundStyle(Theme.accentBlueBright)
                        }
                        .frame(width: 54, height: 54)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add Photo")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text("Remember garage floor, column, or landmark.")
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondaryText)
                        }

                        Spacer()
                    }
                    .padding(18)
                    .background(cardBackground)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var smartLeaveCard: some View {
        Group {
            if let walkingTime = viewModel.walkingTimeEstimate,
               let leaveByTime = viewModel.leaveByTime,
               let buffer = viewModel.safetyBufferTime {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Theme.accentBlue.opacity(0.16))

                        Image(systemName: leaveByTime <= Date() ? "figure.walk.motion" : "figure.walk")
                            .font(.title3)
                            .foregroundStyle(Theme.accentBlueBright)
                    }
                    .frame(width: 54, height: 54)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(walkingTimeString(from: walkingTime))
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(leaveByTime <= Date() ? "Leave now" : "Leave by \(clockTimeString(from: leaveByTime))")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.accentBlueBright)
                        Text("Includes \(bufferString(from: buffer))")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }

                    Spacer()
                }
                .padding(18)
                .background(cardBackground)
            }
        }
    }

    private var locationCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.accentBlue.opacity(0.16))

                Image(systemName: "parkingsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.accentBlueBright)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.parkingSpot?.addressTitle ?? "Saved Parking Spot")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(viewModel.parkingSpot?.addressSubtitle ?? "Your parked location is ready on the map.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer()
        }
        .padding(18)
        .background(cardBackground)
    }

    private func errorCard(message: String) -> some View {
        Text(message)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.red.opacity(0.12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    }
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
            .fill(Theme.card.opacity(0.92))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            }
    }

    private func parkedTimeString(for spot: ParkingSpot) -> String {
        parkedTimeFormatter.string(from: spot.parkedAt)
    }

    private func walkingTimeString(from interval: TimeInterval) -> String {
        let totalMinutes = max(1, Int(ceil(interval / 60)))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0, minutes > 0 {
            return "\(hours) hr \(minutes) min walk back"
        } else if hours > 0 {
            return "\(hours) hr walk back"
        } else {
            return "\(totalMinutes) min walk back"
        }
    }

    private func bufferString(from interval: TimeInterval) -> String {
        let totalMinutes = max(1, Int(round(interval / 60)))
        return "\(totalMinutes) min buffer"
    }

    private func clockTimeString(from date: Date) -> String {
        parkedTimeFormatter.string(from: date)
    }

    private var parkedTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
