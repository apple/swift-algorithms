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
// sortedPrefix(_:by:)
//===----------------------------------------------------------------------===//

extension Collection {

  public func sortedPrefix(
    _ count: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Self.Element] {
    assert(count >= 0, """
      Cannot prefix with a negative amount of elements!
      """
    )
    assert(count <= self.count, """
      Cannot prefix more than this Collection's size!
      """
    )

    // If we're attempting to prefix more than 10% of the collection, it's faster to sort everything.
    guard count < (self.count / 10) else {
      return Array(try sorted(by: areInIncreasingOrder).prefix(count))
    }

    var result = try self.prefix(count).sorted(by: areInIncreasingOrder)
    for e in self.dropFirst(count) {
      if let last = result.last, try areInIncreasingOrder(last, e) { continue }
      if let insertionIndex = try result.firstIndex  (where: { try areInIncreasingOrder(e, $0) }) {
        result.insert(e, at: insertionIndex)
        result.removeLast()
      }
    }
    return result
  }
}

extension Collection where Element: Comparable {

  public func sortedPrefix(_ count: Int) -> [Element] {
    return sortedPrefix(count, by: <)
  }
}
