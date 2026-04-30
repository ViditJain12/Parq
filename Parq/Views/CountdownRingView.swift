import SwiftUI

struct CountdownRingView: View {
    let parkedAt: Date
    let expiresAt: Date
    let currentTime: Date

    private var totalDuration: TimeInterval {
        max(expiresAt.timeIntervalSince(parkedAt), 1)
    }

    private var remainingDuration: TimeInterval {
        max(expiresAt.timeIntervalSince(currentTime), 0)
    }

    private var progress: Double {
        remainingDuration / totalDuration
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.backgroundSecondary,
                            Theme.background
                        ],
                        center: .center,
                        startRadius: 18,
                        endRadius: 140
                    )
                )
                .overlay {
                    Circle()
                        .stroke(Theme.cardBorder, lineWidth: 1)
                }

            Circle()
                .stroke(Theme.accentBlue.opacity(0.12), lineWidth: 20)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Theme.accentBlueBright,
                            Theme.accentBlue,
                            Theme.accentBlueBright
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.cardShadow, radius: 16)
                .animation(.easeInOut(duration: 0.35), value: progress)

            Circle()
                .stroke(Theme.accentBlueBright.opacity(0.35), lineWidth: 4)
                .blur(radius: 10)
                .padding(18)

            VStack(spacing: 8) {
                Text("TIME LEFT")
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(Theme.accentBlueBright)

                Text(TimeFormatter.timeRemainingString(from: remainingDuration))
                    .font(.system(size: 42, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(remainingDuration == 0 ? Theme.destructive : .white)
                    .minimumScaleFactor(0.65)

                Text(remainingDuration >= 3600 ? "hours" : remainingDuration >= 60 ? "min" : "sec")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .frame(width: 264, height: 264)
    }
}

#Preview {
    CountdownRingView(
        parkedAt: .now.addingTimeInterval(-900),
        expiresAt: .now.addingTimeInterval(2700),
        currentTime: .now
    )
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
