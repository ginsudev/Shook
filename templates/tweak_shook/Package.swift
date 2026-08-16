// swift-tools-version: 5.10.0

import Foundation
import PackageDescription

let projectDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

@dynamicMemberLookup struct TheosConfiguration {
    private let dict: [String: String]

    init(at path: String) {
        let configURL = URL(fileURLWithPath: path, relativeTo: projectDir)
        guard let infoString = try? String(contentsOf: configURL, encoding: .utf8) else {
            fatalError("Could not find Theos SPM config. Have you run `make spm` yet?")
        }
        let pairs = infoString
            .split(separator: "\n")
            .map { $0.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false).map(String.init) }
            .map { ($0[0], $0[1]) }
        dict = Dictionary(uniqueKeysWithValues: pairs)
    }

    subscript(
        key: String,
        or defaultValue: @autoclosure () -> String? = nil
    ) -> String {
        if let value = dict[key] {
            return value
        } else if let def = defaultValue() {
            return def
        } else {
            fatalError("""
            Could not get value of key '\(key)' from Theos SPM config. \
            Try running `make spm` again.
            """)
        }
    }

    subscript(dynamicMember key: String) -> String { self[key] }
}

let conf = TheosConfiguration(at: ".theos/spm_config")
let theosPath = conf.theos
let sdk = conf.sdk
let resourceDir = conf.swiftResourceDir
let deploymentTarget = conf.deploymentTarget
let triple = "arm64-apple-ios\(deploymentTarget)"

let libFlags: [String] = [
    "-F\(theosPath)/vendor/lib", "-F\(theosPath)/lib",
    "-I\(theosPath)/vendor/include", "-I\(theosPath)/include"
]

let cFlags: [String] = libFlags + [
    "-target", triple, "-isysroot", sdk,
    "-Wno-unused-command-line-argument", "-Qunused-arguments",
]

let swiftFlags: [String] = libFlags + [
    "-target", triple, "-sdk", sdk, "-resource-dir", resourceDir,
]

let package = Package(
    name: "@@PROJECTNAME@@",
    platforms: [.iOS(deploymentTarget)],
    products: [
        .library(
            name: "@@PROJECTNAME@@",
            targets: ["@@PROJECTNAME@@"]
        ),
    ],
    dependencies: [
        // Compile-time-only dependency so Xcode resolves `import Shook`.
        .package(path: "\(theosPath)/mod/shook"),
    ],
    targets: [
        .target(
            name: "@@PROJECTNAME@@C",
            cSettings: [.unsafeFlags(cFlags)]
        ),
        .target(
            name: "@@PROJECTNAME@@Loader",
            cSettings: [.unsafeFlags(cFlags)]
        ),
        .target(
            name: "@@PROJECTNAME@@",
            dependencies: [
                "@@PROJECTNAME@@C",
                .product(name: "Shook", package: "Shook"),
            ],
            swiftSettings: [.unsafeFlags(swiftFlags)]
        ),
    ]
)
