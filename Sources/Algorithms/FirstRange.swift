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
// firstRange(of:)
//===----------------------------------------------------------------------===//

extension Collection {
  @inlinable
  public func firstRange<Other: Collection>(
    of other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Range<Index>? {
    var searchStart = startIndex
    
    guard let needleFirst = other.first else {
      return searchStart..<searchStart
    }

    while let matchStart = try self[searchStart...]
            .firstIndex(where: { try areEquivalent($0, needleFirst) })
    {
      var index = matchStart
      var otherIndex = other.startIndex

      repeat {
        formIndex(after: &index)
        other.formIndex(after: &otherIndex)
        
        if otherIndex == other.endIndex {
          return matchStart..<index
        } else if index == endIndex {
          return nil
        }
      } while try areEquivalent(self[index], other[otherIndex])

      searchStart = self.index(after: matchStart)
    }

    return nil
  }
}

extension Collection where Element: Equatable {
  @inlinable
  public func firstRange<Other: Collection>(of other: Other) -> Range<Index>?
    where Other.Element == Element
  {
    firstRange(of: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// lastRange(of:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  @inlinable
  public func lastRange<Other: BidirectionalCollection>(
    of other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Range<Index>? {
    var searchEnd = endIndex
    
    guard let otherLastIndex = other.indices.last else {
      return searchEnd..<searchEnd
    }
    
    let needleLast = other[otherLastIndex]

    while let matchEnd = try self[..<searchEnd]
            .lastIndex(where: { try areEquivalent($0, needleLast) })
    {
      var index = matchEnd
      var otherIndex = otherLastIndex

      repeat {
        if otherIndex == other.startIndex {
          return index..<self.index(after: matchEnd)
        } else if index == startIndex {
          return nil
        }

        formIndex(before: &index)
        other.formIndex(before: &otherIndex)
      } while try areEquivalent(self[index], other[otherIndex])

      searchEnd = matchEnd
    }

    return nil
  }
}

extension BidirectionalCollection where Element: Equatable {
  @inlinable
  public func lastRange<Other: BidirectionalCollection>(
    of other: Other
  ) -> Range<Index>? where Other.Element == Element {
    lastRange(of: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// contains(_:)
//===----------------------------------------------------------------------===//

extension Collection {
  @inlinable
  public func contains<Other: Collection>(
    _ other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> Bool {
    try firstRange(of: other, by: areEquivalent) != nil
  }
}

extension Collection where Element: Equatable {
  @inlinable
  public func contains<Other: Collection>(
    _ other: Other
  ) -> Bool where Other.Element == Element {
    contains(other, by: ==)
  }
}
