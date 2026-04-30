import AppKit
import SwiftUI

private struct ParqIconArtwork: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 226, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.05, green: 0.07, blue: 0.13),
                            Color(red: 0.015, green: 0.02, blue: 0.05)
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 540
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 226, style: .continuous)
                        .stroke(Color(red: 0.11, green: 0.32, blue: 0.86).opacity(0.42), lineWidth: 10)
                }
                .shadow(color: .black.opacity(0.55), radius: 30, y: 18)

            ParqPinShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.86, blue: 1.0),
                            Color(red: 0.14, green: 0.55, blue: 1.0),
                            Color(red: 0.12, green: 0.28, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.14, green: 0.70, blue: 1.0).opacity(0.55), radius: 28)
                .overlay {
                    ParqPinShape()
                        .stroke(Color(red: 0.33, green: 0.94, blue: 1.0).opacity(0.72), lineWidth: 4)
                        .blur(radius: 2)
                }
                .frame(width: 470, height: 620)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.15, green: 0.70, blue: 1.0).opacity(0.28),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 16,
                            endRadius: 120
                        )
                    )
                    .frame(width: 170, height: 170)

                CarFrontGlyph()
                    .fill(Color(red: 0.02, green: 0.04, blue: 0.09).opacity(0.96))
                    .frame(width: 148, height: 96)
            }
            .offset(y: 172)
        }
        .frame(width: 1024, height: 1024)
        .background(Color.black)
    }
}

private struct ParqPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.30, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.30, y: h * 0.58))
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.96),
            control1: CGPoint(x: w * 0.26, y: h * 0.78),
            control2: CGPoint(x: w * 0.38, y: h * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.68),
            control1: CGPoint(x: w * 0.62, y: h * 0.86),
            control2: CGPoint(x: w * 0.68, y: h * 0.74)
        )
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.68))
        path.addCurve(
            to: CGPoint(x: w * 0.82, y: h * 0.36),
            control1: CGPoint(x: w * 0.86, y: h * 0.68),
            control2: CGPoint(x: w * 0.92, y: h * 0.48)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.12),
            control1: CGPoint(x: w * 0.82, y: h * 0.20),
            control2: CGPoint(x: w * 0.72, y: h * 0.12)
        )
        path.closeSubpath()

        return path.strokedPath(.init(lineWidth: w * 0.16, lineCap: .round, lineJoin: .round))
    }
}

private struct CarFrontGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.15, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.20, y: h * 0.38))
        path.addCurve(
            to: CGPoint(x: w * 0.36, y: h * 0.18),
            control1: CGPoint(x: w * 0.24, y: h * 0.24),
            control2: CGPoint(x: w * 0.29, y: h * 0.18)
        )
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.18))
        path.addCurve(
            to: CGPoint(x: w * 0.80, y: h * 0.38),
            control1: CGPoint(x: w * 0.71, y: h * 0.18),
            control2: CGPoint(x: w * 0.76, y: h * 0.24)
        )
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.63, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.61, y: h * 0.68))
        path.addLine(to: CGPoint(x: w * 0.39, y: h * 0.68))
        path.addLine(to: CGPoint(x: w * 0.37, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.62))
        path.closeSubpath()

        path.move(to: CGPoint(x: w * 0.32, y: h * 0.36))
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.36))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.24))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.24))
        path.closeSubpath()

        path.addEllipse(in: CGRect(x: w * 0.23, y: h * 0.50, width: w * 0.14, height: h * 0.10))
        path.addEllipse(in: CGRect(x: w * 0.63, y: h * 0.50, width: w * 0.14, height: h * 0.10))

        return path
    }
}

let outputURL = URL(fileURLWithPath: "/Users/viditjain/PersonalProjects/Parq/Parq/Assets.xcassets/AppIcon.appiconset/parq-icon-1024.png")
let renderer = ImageRenderer(content: ParqIconArtwork())
renderer.proposedSize = .init(width: 1024, height: 1024)
renderer.scale = 1

guard let nsImage = renderer.nsImage else {
    fatalError("Failed to render icon image.")
}

guard let tiffData = nsImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode PNG image.")
}

try pngData.write(to: outputURL)
print("Wrote icon to \(outputURL.path)")
