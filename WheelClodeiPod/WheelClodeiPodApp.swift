import SwiftUI

@main
struct WheelClodeiPodApp: App {
    @StateObject private var library = FileLibrary()
    @StateObject private var collaboration = CollaborationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
                .environmentObject(collaboration)
                .onAppear {
                    collaboration.onFileReceived = { url in
                        library.importFile(from: url)
                    }
                }
        }
    }
}
