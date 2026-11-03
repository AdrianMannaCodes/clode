// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WheelClodeiPod",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "WheelClodeiPod",
            targets: ["WheelClodeiPod"],
            bundleIdentifier: "com.adrianmannacodes.wheelclodeipod",
            teamIdentifier: nil,
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [.portrait, .landscapeRight, .landscapeLeft, .portraitUpsideDown]
        )
    ],
    targets: [
        .executableTarget(
            name: "WheelClodeiPod",
            path: "WheelClodeiPod",
            exclude: ["FileTypes+Examples.md"]
        )
    ]
)
