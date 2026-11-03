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
struct ShareSheet: View {
    let items: [Any]
    init(items: [Any], applicationActivities: [Any]? = nil) { self.items = items }
    var body: some View { Text("Export is available on iOS and iPadOS.") }
}
#endif
