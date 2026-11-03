# clode (WheelClode iPod)

A retro click-wheel iPod-style app written in SwiftUI.

## Features
- iPod-style click wheel: drag around the ring to scroll, center button to select, outer buttons for menu, play/pause, previous and next.
- File management for 36 extensions across audio, video, images, text, code, documents, archives and data, plus an Other fallback.
- Import files through the system file picker. Files are stored in the app's own Documents folder.
- Export any file through the system share sheet (UIActivityViewController), so you can send it with AirDrop, Files, Mail, Messages and more.
- Collaboration uses MultipeerConnectivity (Wi-Fi, peer-to-peer Wi-Fi, Bluetooth). It does not use iCloud Drive or any cloud service. Both devices need the app open.

## Open it
1. Open Xcode 15 or later, or Swift Playgrounds on iPad or Mac.
2. Create a new iOS App project using SwiftUI, then copy the files in `WheelClodeiPod/` into it.
3. Add these keys to Info.plist (or the target's Info tab):
   - `NSLocalNetworkUsageDescription`: "WheelClode uses the local network to share files with nearby devices."
   - `NSBonjourServices`: array containing `_wheelclode._tcp` and `_wheelclode._udp`
4. Run on two devices. Use Host Session on one and Find Nearby Devices on the other, then invite the peer.

## Files
- `WheelClodeiPod/WheelClodeiPodApp.swift`: app entry point
- `WheelClodeiPod/ContentView.swift`: iPod screen, menus, file list and detail
- `WheelClodeiPod/iPodWheelView.swift`: click wheel gesture and buttons
- `WheelClodeiPod/FileTypes.swift`: file kinds and categories
- `WheelClodeiPod/FileLibrary.swift`: local file storage and import
- `WheelClodeiPod/CollaborationManager.swift`: MultipeerConnectivity sessions and transfers
- `WheelClodeiPod/CollaborationView.swift`: collaboration UI
- `WheelClodeiPod/ShareSheet.swift`: export via UIActivityViewController
- `WheelClodeiPod/FileTypes+Examples.md`: supported type list

## Notes
- Collaboration is tested only in code review so far. Build and run on real devices to verify.
- MultipeerConnectivity is not supported on macOS for this UI layout. Use iOS or iPadOS.
