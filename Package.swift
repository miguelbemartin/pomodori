// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pomodoro",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Pomodoro",
            path: "Sources/Pomodoro",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/Pomodoro/Info.plist"])
            ]
        )
    ]
)
