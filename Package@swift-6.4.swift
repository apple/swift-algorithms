// swift-tools-version:6.4
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// This manifest will be used instead of Package.swift on Swift 6.4 and later.

import PackageDescription

let package = Package(
  name: "swift-algorithms",
  products: [
    .library(
      name: "Algorithms",
      targets: ["Algorithms"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "Algorithms",
      dependencies: [
        .product(name: "RealModule", package: "swift-numerics")
      ],
      swiftSettings: [
        .enableExperimentalFeature("Lifetimes")
      ]),
    .testTarget(
      name: "SwiftAlgorithmsTests",
      dependencies: ["Algorithms"],
      swiftSettings: [
        .enableExperimentalFeature("Lifetimes")
      ]),
  ],
  swiftLanguageModes: [.v5]
)
