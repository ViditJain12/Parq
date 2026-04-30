import SwiftUI
import UIKit

enum TimerDurationFormatter {
    static func string(for minutes: Int) -> String {
        let clampedMinutes = max(minutes, 0)
        let hours = clampedMinutes / 60
        let remainingMinutes = clampedMinutes % 60

        if hours == 0 {
            return "\(remainingMinutes) min"
        }

        if remainingMinutes == 0 {
            return "\(hours) hr"
        }

        return "\(hours) hr \(remainingMinutes) min"
    }
}

struct CircularTimerDialView: View {
    @Binding var selectedMinutes: Int
    let maxMinutes: Int

    @State private var lastHapticMinutes = 60

    private let minMinutes = 5
    private let stepMinutes = 5
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    private var clampedMinutes: Int {
        min(max(selectedMinutes, minMinutes), maxMinutes)
    }

    private var progress: Double {
        Double(clampedMinutes - minMinutes) / Double(max(maxMinutes - minMinutes, 1))
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineWidth = size * 0.1
            let knobSize = size * 0.1
            let radius = (size / 2) - (lineWidth / 2) - (knobSize / 2)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let angle = Angle.degrees((progress * 360) - 90)
            let knobPosition = CGPoint(
                x: center.x + CGFloat(cos(angle.radians)) * radius,
                y: center.y + CGFloat(sin(angle.radians)) * radius
            )

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.backgroundSecondary, Theme.background],
                            center: .center,
                            startRadius: size * 0.08,
                            endRadius: size * 0.52
                        )
                    )
                    .overlay {
                        Circle()
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    }

                Circle()
                    .stroke(Theme.accentBlue.opacity(0.12), lineWidth: lineWidth)

                tickRing(size: size, lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [Theme.accentBlueBright, Theme.accentBlue, Theme.accentBlueBright],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Theme.cardShadow, radius: 16)
                    .animation(.easeInOut(duration: 0.18), value: clampedMinutes)

                Circle()
                    .fill(Theme.accentBlueBright.opacity(0.15))
                    .frame(width: size * 0.7, height: size * 0.7)
                    .blur(radius: 18)

                VStack(spacing: 8) {
                    Text("Custom Timer")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accentBlueBright)

                    Text(TimerDurationFormatter.string(for: clampedMinutes))
                        .font(.system(size: size * 0.13, weight: .bold))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .minimumScaleFactor(0.65)

                    Text("Drag around the dial")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                }

                Circle()
                    .fill(Theme.accentBlueBright)
                    .frame(width: knobSize, height: knobSize)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.9), lineWidth: 3)
                    }
                    .shadow(color: Theme.cardShadow, radius: 16)
                    .position(knobPosition)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateSelection(for: value.location, in: geometry.size)
                    }
            )
            .onTapGesture { location in
                updateSelection(for: location, in: geometry.size)
            }
            .onAppear {
                if selectedMinutes <= 0 {
                    selectedMinutes = 60
                }
                lastHapticMinutes = clampedMinutes
                hapticGenerator.prepare()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func tickRing(size: CGFloat, lineWidth: CGFloat) -> some View {
        let tickCount = maxMinutes / stepMinutes
        let longTickEvery = 12
        let tickHeight = size * 0.045
        let longTickHeight = size * 0.07
        let tickWidth = size * 0.008
        let tickRadius = (size / 2) - lineWidth - (size * 0.035)

        ForEach(0...tickCount, id: \.self) { index in
            let tickProgress = Double(index) / Double(max(tickCount, 1))
            let isActive = tickProgress <= progress
            let isLongTick = index.isMultiple(of: longTickEvery)

            Capsule(style: .continuous)
                .fill(isActive ? Theme.accentBlueBright.opacity(isLongTick ? 0.95 : 0.7) : Color.white.opacity(isLongTick ? 0.16 : 0.08))
                .frame(width: tickWidth, height: isLongTick ? longTickHeight : tickHeight)
                .offset(y: -tickRadius)
                .rotationEffect(.degrees(tickProgress * 360))
        }
    }

    private func updateSelection(for location: CGPoint, in size: CGSize) {
        let newMinutes = minutes(for: location, in: size)

        if newMinutes != selectedMinutes {
            selectedMinutes = newMinutes

            if newMinutes != lastHapticMinutes {
                hapticGenerator.impactOccurred(intensity: 0.72)
                lastHapticMinutes = newMinutes
                hapticGenerator.prepare()
            }
        }
    }

    private func minutes(for location: CGPoint, in size: CGSize) -> Int {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let rawAngle = atan2(dy, dx) + (.pi / 2)
        let normalizedAngle = rawAngle < 0 ? rawAngle + (2 * .pi) : rawAngle
        let progress = normalizedAngle / (2 * .pi)
        let stepCount = max((maxMinutes - minMinutes) / stepMinutes, 1)
        let steppedIndex = Int(round(progress * Double(stepCount)))
        let rawMinutes = minMinutes + (steppedIndex * stepMinutes)

        return min(max(rawMinutes, minMinutes), maxMinutes)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var minutes = 90

        var body: some View {
            CircularTimerDialView(selectedMinutes: $minutes, maxMinutes: 720)
                .frame(width: 280, height: 280)
                .padding()
                .background(Theme.background)
                .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}
