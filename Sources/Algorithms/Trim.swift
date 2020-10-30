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

extension BidirectionalCollection {

  /// Returns a `SubSequence` formed by discarding all elements at the start and end of the collection
  /// which satisfy the given predicate.
  ///
  /// This example uses `trimming(where:)` to get a substring without the white space at the
  /// beginning and end of the string:
  ///
  ///  ```
  ///  let myString = "  hello, world  "
  ///  print(myString.trimming(where: \.isWhitespace)) // "hello, world"
  ///  ```
  ///
  /// - parameters:
  ///    - predicate:  A closure which determines if the element should be omitted from the
  ///                  resulting slice.
  ///
  /// - complexity: `O(n)`, where `n` is the length of this collection.
  ///
  @inlinable
  public func trimming(
    where predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {

    // Consume elements from the front.
    let sliceStart = try firstIndex { try predicate($0) == false } ?? endIndex
    // sliceEnd is the index _after_ the last index to match the predicate.
    var sliceEnd = endIndex
    while sliceStart != sliceEnd {
      let idxBeforeSliceEnd = index(before: sliceEnd)
      guard try predicate(self[idxBeforeSliceEnd]) else {
        return self[sliceStart..<sliceEnd]
      }
      sliceEnd = idxBeforeSliceEnd
    }
    // Trimmed everything.
    return self[Range(uncheckedBounds: (sliceStart, sliceStart))]
  }
}
