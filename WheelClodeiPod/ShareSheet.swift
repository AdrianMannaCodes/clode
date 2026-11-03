import SwiftUI
#if canImport(UIKit)
import UIKit

/// Wraps UIActivityViewController so files can be exported via the system share sheet
/// (AirDrop, Files, Mail, Messages, and any other app).
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
/// Fallback for platforms without UIKit. Export is not available here.
struct ShareSheet: View {
    let items: [Any]

    var body: some View {
        Text("Export is available on iOS and iPadOS.")
    }
}
#endif
