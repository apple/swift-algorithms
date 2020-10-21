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
// uniqued()
//===----------------------------------------------------------------------===//

extension Sequence where Element: Hashable {
  /// Returns an array with only the unique elements of this sequence, in the
  /// order of the first occurence of each unique element.
  @inlinable
  public func uniqued() -> [Element] {
    uniqued(on: { $0 })
  }
}

extension Sequence {
  /// Returns an array with the unique elements of this sequence (as determined
  /// by the given projection), in the order of the first occurence of each
  /// unique element.
  @inlinable
  public func uniqued<Subject: Hashable>(
    on projection: (Element) throws -> Subject
  ) rethrows -> [Element] {
    var seen: Set<Subject> = []
    var result: [Element] = []
    for element in self {
      if seen.insert(try projection(element)).inserted {
        result.append(element)
      }
    }
    return result
  }
}
