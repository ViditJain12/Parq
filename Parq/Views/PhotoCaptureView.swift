import SwiftUI

struct PhotoCaptureView: View {
    var body: some View {
        ContentUnavailableView(
            "Photo Capture",
            systemImage: "camera",
            description: Text("This placeholder view is ready for camera integration later.")
        )
    }
}

#Preview {
    PhotoCaptureView()
}
