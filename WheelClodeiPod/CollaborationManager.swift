import Foundation
import MultipeerConnectivity
import Combine
#if canImport(UIKit)
import UIKit
#endif

/// Peer-to-peer file sharing over MultipeerConnectivity (Wi-Fi, peer-to-peer Wi-Fi, Bluetooth).
/// No iCloud or internet service is involved. Both devices must run the app.
@MainActor
final class CollaborationManager: NSObject, ObservableObject {
    static let serviceType = "wheelclode" // 1-15 chars, lowercase letters, digits, hyphens

    @Published private(set) var connectedPeers: [MCPeerID] = []
    @Published private(set) var discoveredPeers: [MCPeerID] = []
    @Published private(set) var status: String = "Idle"
    @Published var isHosting = false

    /// Called on the main actor when a file from a peer has finished downloading to a temp URL.
    var onFileReceived: ((URL) -> Void)?

    let myPeerID: MCPeerID
    private let session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    override init() {
        let name: String
        #if canImport(UIKit)
        name = UIDevice.current.name
        #else
        name = Host.current().localizedName ?? "Device"
        #endif
        myPeerID = MCPeerID(displayName: String(name.prefix(60)))
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }

    func startHosting() {
        let adv = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        adv.delegate = self
        adv.startAdvertisingPeer()
        advertiser = adv
        isHosting = true
        status = "Hosting as \(myPeerID.displayName)"
    }

    func startBrowsing() {
        let br = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        br.delegate = self
        br.startBrowsingForPeers()
        browser = br
        status = "Searching for nearby devices"
    }

    func stopAll() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
        session.disconnect()
        isHosting = false
        discoveredPeers = []
        status = "Stopped"
    }

    func invite(_ peer: MCPeerID) {
        browser?.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }

    /// Sends a file to all connected peers as a resource transfer.
    func send(_ url: URL) {
        guard !session.connectedPeers.isEmpty else {
            status = "No connected peers"
            return
        }
        for peer in session.connectedPeers {
            session.sendResource(at: url, withName: url.lastPathComponent, toPeer: peer) { [weak self] error in
                Task { @MainActor in
                    self?.status = error.map { "Send failed: \($0.localizedDescription)" }
                        ?? "Sent \(url.lastPathComponent)"
                }
            }
        }
    }
}

extension CollaborationManager: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            self.connectedPeers = session.connectedPeers
            switch state {
            case .connected: self.status = "Connected to \(peerID.displayName)"
            case .connecting: self.status = "Connecting to \(peerID.displayName)"
            case .notConnected: self.status = "Disconnected from \(peerID.displayName)"
            @unknown default: break
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        Task { @MainActor in self.status = "Receiving \(resourceName)" }
    }

    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let localURL, error == nil else {
            Task { @MainActor in self.status = "Receive failed: \(error?.localizedDescription ?? "unknown")" }
            return
        }
        // MultipeerConnectivity deletes localURL when this callback returns, so move it first.
        let staging = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
        let dest = staging.appendingPathComponent(resourceName)
        do {
            try FileManager.default.moveItem(at: localURL, to: dest)
        } catch {
            Task { @MainActor in self.status = "Receive failed: \(error.localizedDescription)" }
            return
        }
        Task { @MainActor in
            self.status = "Received \(resourceName) from \(peerID.displayName)"
            self.onFileReceived?(dest)
        }
    }

    nonisolated func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

extension CollaborationManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor in
            invitationHandler(true, self.session)
        }
    }

    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Task { @MainActor in self.status = "Hosting failed: \(error.localizedDescription)" }
    }
}

extension CollaborationManager: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            if !self.discoveredPeers.contains(peerID) { self.discoveredPeers.append(peerID) }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            self.discoveredPeers.removeAll { $0 == peerID }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Task { @MainActor in self.status = "Search failed: \(error.localizedDescription)" }
    }
}
