// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mecab-Swift",
    defaultLocalization: "en",
    platforms: [.macOS(.v10_11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Mecab-Swift",
            targets: ["Mecab-Swift"]),
        
        .library(
                name: "IPADic",
                targets: ["IPADic"]),
        
        .library(
            name: "CharacterFilter",
            targets: ["CharacterFilter"]),
        
        .library(
            name: "StringTools",
            targets: ["StringTools"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "Dictionary"),
        
        .target(
            name: "Mecab-Swift",
            dependencies: ["mecab", "StringTools", "Dictionary"]),

        .target(name: "CharacterFilter"),
        .target(name: "StringTools"),
        
        .target(name: "IPADic", dependencies: ["Dictionary"], resources: [.copy("ipadic dictionary")]),
        
        .testTarget(
            name: "Mecab-SwiftTests",
            dependencies: ["Mecab-Swift", "CharacterFilter", "IPADic"]),
        
        .testTarget(
            name: "StringToolsTests",
            dependencies: ["StringTools"],
            resources: [.copy("Resources/helicobacter.html")]),
        
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
                          "src/Makefile.msvc.in",
                          "csharp",
                          "doc",
                          "example",
                          "java",
                          "man",
                          "misc",
                          "perl",
                          "python",
                          "ruby",
                          "swig",
                          "tests",
                          "aclocal.m4",
                          "AUTHORS",
                          "autogen.sh",
                          "ChangeLog",
                          "config.guess",
                          "config.h.in",
                          "config.rpath",
                          "config.sub",
                          "configure",
                          "configure.in",
                          "GPL",
                          "INSTALL",
                          "LGPL",
                          "install-sh",
                          "libtool",
                          "ltmain.sh",
                          "Makefile.am",
                          "Makefile.in",
                          "Makefile.train",
                          "mecab-config.in",
                          "mecab.iss.in",
                          "mecabrc.in",
                          "missing",
                          "mkinstalldirs",
                          "NEWS",
                          "README",
                          "stamp-h.in",
                          
                ],
                
                sources: ["src"],
                resources: [.copy("BSD"), .copy("COPYING")],
                publicHeadersPath: "swift",
                cSettings: [.define("HAVE_CONFIG_H"),
                        .headerSearchPath(".")],
                cxxSettings: [.define("HAVE_ICONV")],
                swiftSettings: nil,
                linkerSettings: [.linkedLibrary("iconv")]),
    ]
)
