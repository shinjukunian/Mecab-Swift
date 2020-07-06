// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mecab-Swift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Mecab-Swift",
            targets: ["Mecab-Swift", "CharacterFilter"]),
        
        .library(
            name: "CharacterFilter",
            targets: ["CharacterFilter"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        
        .target(name: "mecab", dependencies: [],
                path: "Sources/mecab/mecab",
                exclude: ["src/mecab-cost-train.cpp",
                          "src/mecab-dict-gen.cpp",
                          "src/mecab-dict-index.cpp",
                          "src/mecab-system-eval.cpp",
                          "src/mecab-test-gen.cpp",
                          "src/mecab.cpp",
                          "src/make.bat",
                          "src/Makefile.am",
                          "src/Makefile.in",
                          "src/Makefile.msvc.in"
                ],
                sources: ["src"],
                publicHeadersPath: "swift",
                cSettings: [.define("HAVE_CONFIG_H"),
                        .headerSearchPath(".")],
                cxxSettings: [.define("HAVE_ICONV")],
                swiftSettings: nil,
                linkerSettings: [.linkedLibrary("iconv")]),
         
        .target(
            name: "Mecab-Swift",
            dependencies: ["mecab"]),

        .target(name: "CharacterFilter"),
        
        .testTarget(
            name: "Mecab-SwiftTests",
            dependencies: ["Mecab-Swift", "CharacterFilter"]),
    ]
)
