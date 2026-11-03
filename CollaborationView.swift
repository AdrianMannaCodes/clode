import SwiftUI
import MultipeerConnectivity

struct CollaborationView: View {
    @EnvironmentObject var collaboration: CollaborationManager
    @EnvironmentObject var library: FileLibrary
    @State private var showPicker = false
    @State private var sendTarget: FileItem?

    var body: some View {
        List {
            Section {
                Text(collaboration.status).font(.caption)
            }
            Section("Session") {
                Button(collaboration.isHosting ? "Stop Hosting" : "Host Session") {
                    collaboration.isHosting ? collaboration.stopAll() : collaboration.startHosting()
                }
                Button("Find Nearby Devices") { collaboration.startBrowsing() }
            }
            Section("Nearby") {
                ForEach(collaboration.discoveredPeers, id: \.self) { peer in
                    Button(peer.displayName) { collaboration.invite(peer) }
                }
            }
            Section("Connected") {
                ForEach(collaboration.connectedPeers, id: \.self) { peer in
                    Text(peer.displayName)
                }
            }
            Section("Send a file") {
                ForEach(library.files) { file in
                    Button(file.name) { collaboration.send(file.url) }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Collaborate")
    }
}
