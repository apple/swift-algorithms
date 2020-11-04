//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// firstNonNil(_:)
//===----------------------------------------------------------------------===//

public extension Sequence {
    /// Returns the first element in `self` that `transform` maps to a `.some`.
  func firstNonNil<Result>(
    _ transform: (Element) throws -> Result?
  ) rethrows -> Result? {
        for value in self {
            if let value = try transform(value) {
                return value
            }
        }
        return nil
    }
}
