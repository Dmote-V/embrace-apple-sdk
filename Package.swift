// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import Foundation
import PackageDescription


var linkerSettings: [LinkerSetting]? = []


let package = Package(
    name: "EmbraceIO",
    platforms: [
        .iOS(.v13), .tvOS(.v13), .macOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "EmbraceIO", targets: ["EmbraceIO"]),
        .library(name: "EmbraceCore", targets: ["EmbraceCore", "EmbraceConfiguration"]),
        .library(name: "EmbraceSemantics", targets: ["EmbraceSemantics"]),
        .library(name: "EmbraceMacros", targets: ["EmbraceMacros", "EmbraceCore"]),
        .library(name: "EmbraceCrash", targets: ["EmbraceCrash"]),
        .library(name: "EmbraceKSCrashBacktraceSupport", targets: ["EmbraceKSCrashBacktraceSupport"]),
        .library(name: "EmbraceCrashlyticsSupport", targets: ["EmbraceCrashlyticsSupport"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/kstenerud/KSCrash",
            from: "2.4.0"
        ),
        .package(
            url: "https://github.com/Dmote-V/opentelemetry-swift-core",
            branch: "datadog-package"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            "509.0.0"..<"603.0.0"
        )
    ],
    targets: [

        // main target ---------------------------------------------------------------
        .target(
            name: "EmbraceIO",
            dependencies: [
                "EmbraceCaptureService",
                "EmbraceCore",
                "EmbraceCommonInternal",
                "EmbraceSemantics",
                "EmbraceCrash",
                "EmbraceKSCrashBacktraceSupport"
            ],
            linkerSettings: linkerSettings
        ),

        .testTarget(
            name: "EmbraceIOTests",
            dependencies: [
                "EmbraceIO",
                "EmbraceCore",
                "TestSupport"
            ]
        ),

        // core ----------------------------------------------------------------------
        .target(
            name: "EmbraceCore",
            dependencies: [
                "EmbraceCaptureService",
                "EmbraceCommonInternal",
                "EmbraceConfigInternal",
                "EmbraceConfiguration",
                "EmbraceOTelInternal",
                "EmbraceStorageInternal",
                "EmbraceUploadInternal",
                "EmbraceObjCUtilsInternal",
                "EmbraceSemantics"
            ],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: linkerSettings
        ),

        .testTarget(
            name: "EmbraceCoreTests",
            dependencies: [
                "EmbraceCore",
                "TestSupport",
                "TestSupportObjc"
            ],
            resources: [
                .copy("Mocks/")
            ]
        ),

        // common --------------------------------------------------------------------
        .target(
            name: "EmbraceCommonInternal",
            dependencies: [
                "EmbraceAtomicsShim",
                .product(name: "OpenTelemetrySdk",
                         package: "opentelemetry-swift-core",
                         moduleAliases: ["OpenTelemetryApi": "OpenTelemetryApi137"]) //
            ],
            exclude: ["Atomic/README.md"]
        ),
        .testTarget(
            name: "EmbraceCommonInternalTests",
            dependencies: [
                "EmbraceCommonInternal",
                "TestSupport"
            ]
        ),

        // atomics ------------------------------------------------------------------
        .target(
            name: "EmbraceAtomicsShim",
            publicHeadersPath: "include"
        ),

        // semantics -----------------------------------------------------------------
        .target(
            name: "EmbraceSemantics",
            dependencies: [
                "EmbraceCommonInternal",
                .product(name: "OpenTelemetrySdk",
                         package: "opentelemetry-swift-core",
                         moduleAliases: ["OpenTelemetryApi": "OpenTelemetryApi137"]) //
            ]
        ),

        // capture service -----------------------------------------------------------
        .target(
            name: "EmbraceCaptureService",
            dependencies: [
                "EmbraceOTelInternal",
                "EmbraceConfiguration",
                .product(name: "OpenTelemetrySdk",
                         package: "opentelemetry-swift-core",
                         moduleAliases: ["OpenTelemetryApi": "OpenTelemetryApi137"]) //
            ]
        ),
        .testTarget(
            name: "EmbraceCaptureServiceTests",
            dependencies: [
                "EmbraceCaptureService",
                "TestSupport"
            ]
        ),

        // config --------------------------------------------------------------------
        .target(
            name: "EmbraceConfiguration",
            dependencies: []
        ),

        .testTarget(
            name: "EmbraceConfigurationTests",
            dependencies: [
                "EmbraceConfiguration"
            ]
        ),

        .target(
            name: "EmbraceConfigInternal",
            dependencies: [
                "EmbraceCommonInternal",
                "EmbraceConfiguration"
            ]
        ),

        .testTarget(
            name: "EmbraceConfigInternalTests",
            dependencies: [
                "EmbraceConfigInternal",
                "TestSupport"
            ],
            resources: [
                .copy("Fixtures")
            ]
        ),

        // OTel ----------------------------------------------------------------------
        .target(
            name: "EmbraceOTelInternal",
            dependencies: [
                "EmbraceCommonInternal",
                "EmbraceSemantics",
                .product(name: "OpenTelemetrySdk",
                         package: "opentelemetry-swift-core",
                        // Map the SDK’s `import OpenTelemetryApi` to a unique module name
                         moduleAliases: ["OpenTelemetryApi": "OpenTelemetryApi137"]) //
            ]
        ),
        .testTarget(
            name: "EmbraceOTelInternalTests",
            dependencies: [
                "EmbraceOTelInternal",
                "TestSupport"
            ]
        ),

        // storage -------------------------------------------------------------------
        .target(
            name: "EmbraceStorageInternal",
            dependencies: [
                "EmbraceCommonInternal",
                "EmbraceCoreDataInternal",
                "EmbraceSemantics"
            ]
        ),
        .testTarget(
            name: "EmbraceStorageInternalTests",
            dependencies: ["EmbraceStorageInternal", "TestSupport"],
            resources: [
                .copy("Mocks/")
            ]
        ),

        // upload --------------------------------------------------------------------
        .target(
            name: "EmbraceUploadInternal",
            dependencies: [
                "EmbraceCommonInternal",
                "EmbraceOTelInternal",
                "EmbraceCoreDataInternal"
            ]
        ),
        .testTarget(
            name: "EmbraceUploadInternalTests",
            dependencies: [
                "EmbraceUploadInternal",
                "EmbraceOTelInternal",
                "EmbraceCoreDataInternal",
                "TestSupport"
            ]
        ),

        // core data -----------------------------------------------------------------
        .target(
            name: "EmbraceCoreDataInternal",
            dependencies: [
                "EmbraceCommonInternal",
                "EmbraceObjCUtilsInternal"
            ]
        ),
        .testTarget(
            name: "EmbraceCoreDataInternalTests",
            dependencies: [
                "EmbraceCommonInternal",
                "TestSupport"
            ]
        ),

        // macros support -----------------------------------------------------------
        .macro(
            name: "EmbraceMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/EmbraceMacros/Plugins"
        ),
        .target(
            name: "EmbraceMacros",
            dependencies: [
                "EmbraceMacroPlugin",
                "EmbraceCore"
            ],
            path: "Sources/EmbraceMacros/Source"
        ),
        .testTarget(
            name: "EmbraceMacrosTests",
            dependencies: [
                "EmbraceMacroPlugin",
                "EmbraceIO",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),

        // kscrash support  -------------------------------------------------------
        .target(
            name: "EmbraceCrash",
            dependencies: [
                "EmbraceCommonInternal",
                .product(name: "Recording", package: "KSCrash")
            ],
            path: "Sources/ThirdParty/EmbraceKSCrashSupport"
        ),
        .target(
            name: "EmbraceKSCrashBacktraceSupport",
            dependencies: [
                "EmbraceCommonInternal",
                .product(name: "DemangleFilter", package: "KSCrash"),
                .product(name: "Recording", package: "KSCrash")
            ],
            path: "Sources/ThirdParty/EmbraceKSCrashBacktraceSupport"
        ),
        .testTarget(
            name: "EmbraceCrashTests",
            dependencies: ["EmbraceCore", "EmbraceCrash", "EmbraceCommonInternal", "TestSupport"],
            resources: [
                .copy("Mocks/")
            ]
        ),

        // crashlytics support  -------------------------------------------------------
        .target(
            name: "EmbraceCrashlyticsSupport",
            dependencies: [
                "EmbraceCommonInternal"
            ],
            path: "Sources/ThirdParty/EmbraceCrashlyticsSupport"
        ),
        .testTarget(
            name: "EmbraceCrashlyticsSupportTests",
            dependencies: ["EmbraceCrashlyticsSupport", "EmbraceCommonInternal", "TestSupport"],
            path: "Tests/ThirdParty/EmbraceCrashlyticsSupportTests"
        ),

        // Utilities
        .target(
            name: "EmbraceObjCUtilsInternal"
        ),
        .testTarget(
            name: "EmbraceObjCUtilsInternalTests",
            dependencies: ["EmbraceObjCUtilsInternal", "TestSupport"]
        ),

        // test support --------------------------------------------------------------
        .target(
            name: "TestSupport",
            dependencies: [
                "EmbraceCore",
                "EmbraceOTelInternal",
                "EmbraceCommonInternal",
                .product(name: "OpenTelemetrySdk", package: "opentelemetry-swift-core")
            ],
            path: "Tests/TestSupport",
            exclude: ["Objc"]
        ),
        .target(
            name: "TestSupportObjc",
            path: "Tests/TestSupport/Objc"
        )
    ]
)
