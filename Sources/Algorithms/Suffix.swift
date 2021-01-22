//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Suffix(while:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  public func suffix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    let start = startIndex
    var result = endIndex
    while result != start {
      let previous = index(before: result)
      guard try predicate(self[previous]) else { break }

      result = previous
    }
    return self[result...]
  }
}