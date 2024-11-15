# Swift Algorithms

**Swift Algorithms** is an open-source package of sequence and collection algorithms, along with their related types.

## Overview

The Algorithms package provides a variety of sequence and collection operations, letting you cycle over a collection's elements, find combinations and permutations, create a random sample, and more.

For example, the package includes a group of "chunking" methods, each of which breaks a collection into consecutive subsequences. One version tests adjacent elements to find the breaking point between chunks — you can use it to quickly separate an array into ascending runs:

```swift
let numbers = [10, 20, 30, 10, 40, 40, 10, 20]
let chunks = numbers.chunked(by: { $0 <= $1 })
// [[10, 20, 30], [10, 40, 40], [10, 20]]
```

Another version looks for a change in the transformation of each successive value. You can use that to separate a list of names into groups by the first character:

```swift
let names = ["Cassie", "Chloe", "Jasmine", "Jordan", "Taylor"]
let chunks = names.chunked(on: \.first)
// [["Cassie", "Chloe"], ["Jasmine", "Jordan"], ["Taylor"]]
```

Explore more chunking methods and the remainder of the `Algorithms` package in the links below.

## Documentation

For API documentation, see the library's official documentation in Xcode or on the Web.

- [API documentation][docs]
- [Swift.org announcement][announcement]
- [API Proposals/Guides][guides]

## Adding Swift Algorithms as a Dependency

To use the `Algorithms` library in a SwiftPM project, 
add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
```

Include `"Algorithms"` as a dependency for your executable target:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "Algorithms", package: "swift-algorithms"),
]),
```

Finally, add `import Algorithms` to your source code.

## Source Stability

The Swift Algorithms package is source stable; version numbers follow [Semantic Versioning](https://semver.org/). Source breaking changes to public API can only land in a new major version.

The public API of the `swift-algorithms` package consists of non-underscored declarations that are marked `public` in the `Algorithms` module. Interfaces that aren't part of the public API may continue to change in any release, including patch releases.

Future minor versions of the package may introduce changes to these rules as needed.

We'd like this package to quickly embrace Swift language and toolchain improvements that are relevant to its mandate. Accordingly, from time to time, we expect that new versions of this package will require clients to upgrade to a more recent Swift toolchain release. Requiring a new Swift release will only require a minor version bump.

[docs]: https://swiftpackageindex.com/apple/swift-algorithms/documentation/algorithms
[announcement]: https://swift.org/blog/swift-algorithms/
[guides]: https://github.com/apple/swift-algorithms/tree/main/Guides
