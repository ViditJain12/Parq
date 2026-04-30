import SwiftUI

enum Theme {
    static let background = Color(red: 0.03, green: 0.05, blue: 0.09)
    static let backgroundSecondary = Color(red: 0.05, green: 0.08, blue: 0.13)
    static let card = Color(red: 0.08, green: 0.11, blue: 0.17)
    static let cardBorder = Color.white.opacity(0.08)
    static let accentBlue = Color(red: 0.15, green: 0.44, blue: 1.0)
    static let accentBlueBright = Color(red: 0.34, green: 0.72, blue: 1.0)
    static let secondaryText = Color.white.opacity(0.62)
    static let destructive = Color(red: 1.0, green: 0.32, blue: 0.32)
    static let cornerRadius: CGFloat = 24
    static let cardShadow = Color(red: 0.11, green: 0.38, blue: 1.0).opacity(0.22)
}
