import SwiftUI

struct TimerSheetView: View {
    let onSelect: (Int) -> Void

    @State private var isShowingCustomPicker = false
    @State private var selectedCustomMinutes = 60

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Capsule()
                    .fill(Color.white.opacity(0.24))
                    .frame(width: 46, height: 5)
                    .padding(.top, 10)

                Text("How long are you parked?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    timerButton(
                        title: "30 min",
                        subtitle: "Quick stop",
                        systemImage: "clock",
                        minutes: 30,
                        isEmphasized: true
                    )
                    timerButton(
                        title: "1 hour",
                        subtitle: "Standard session",
                        systemImage: "clock.arrow.circlepath",
                        minutes: 60,
                        isEmphasized: false
                    )
                    timerButton(
                        title: "2 hours",
                        subtitle: "Longer parking",
                        systemImage: "clock.badge.checkmark",
                        minutes: 120,
                        isEmphasized: false
                    )
                    customButton
                }

                if isShowingCustomPicker {
                    VStack(spacing: 18) {
                        CircularTimerDialView(selectedMinutes: $selectedCustomMinutes, maxMinutes: 720)
                            .frame(height: 280)

                        Button {
                            onSelect(selectedCustomMinutes)
                        } label: {
                            Text("Start Timer")
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
                                .shadow(color: Theme.cardShadow, radius: 18, y: 8)
                        }
                        .disabled(selectedCustomMinutes <= 0)
                        .opacity(selectedCustomMinutes <= 0 ? 0.45 : 1)
                    }
                    .padding(18)
                    .background(sheetCardBackground)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationBackground(.clear)
    }

    private func timerButton(
        title: String,
        subtitle: String,
        systemImage: String,
        minutes: Int,
        isEmphasized: Bool
    ) -> some View {
        Button {
            onSelect(minutes)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isEmphasized ? .white : Theme.secondaryText)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(isEmphasized ? Color.white.opacity(0.78) : Theme.secondaryText)
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(buttonBackground(isEmphasized: isEmphasized))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isEmphasized ? Theme.accentBlueBright.opacity(0.45) : Theme.cardBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: isEmphasized ? Theme.cardShadow : .clear, radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var customButton: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                isShowingCustomPicker.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "dial.medium.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Custom")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(TimerDurationFormatter.string(for: selectedCustomMinutes))
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer()

                Image(systemName: isShowingCustomPicker ? "chevron.up" : "chevron.down")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(sheetCardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isShowingCustomPicker ? Theme.accentBlue.opacity(0.4) : Theme.cardBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func buttonBackground(isEmphasized: Bool) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                isEmphasized
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [Theme.accentBlueBright, Theme.accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(
                        LinearGradient(
                            colors: [Theme.card, Theme.backgroundSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var sheetCardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Theme.card.opacity(0.86))
            )
    }
}

#Preview {
    TimerSheetView { _ in }
        .preferredColorScheme(.dark)
}
