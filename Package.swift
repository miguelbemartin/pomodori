// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pomodori",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Pomodori",
            path: "Sources/Pomodori",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/Pomodori/Info.plist"])
            ]
        )
    ]
)
