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

extension RangeReplaceableCollection {
  /// Returns a new collection of the same type whose length is expanded
  /// to `paddedCount` by repeating the padding `element` at the start.
  ///
  /// In case the length of the collection is longer than or equal to the
  /// `paddedCount`, the original collection is returned.
  ///
  /// This example uses `paddingStart(with:toCount:)` to obtain
  /// `String`s justified to the desired `paddedCount`.
  ///
  ///     let numbers = (7...12).map(String.init)
  ///         .map { $0.paddingStart(with: "0", toCount: 2) }
  ///     print(numbers) // ["07", "08", "09", "10", "11", "12"]
  ///
  /// - Parameters:
  ///   - element: The element which is repeated to expand the collection.
  ///   - paddedCount: The length of the padded collection.
  ///
  /// - Complexity: O(_m_), when the collection's length is less than the
  /// `paddedCount`, where _m_ is the `paddedCount`. O(_n_) when the
  /// collection's length is greater than or equal to the `paddedCount`, where
  /// _n_ is the length of the collection. For a `RandomAccessCollection`
  /// when the collection's length is greater than or equal to the `paddedCount`,
  /// the complexity is reduced to O(_1_).
  @inlinable
  public func paddingStart(
    with element: Element,
    toCount paddedCount: Int
  ) -> Self {
    let padElementCount = paddedCount - count

    // Early exit if no padding is required.
    guard padElementCount > 0 else { return self }

    var paddedCollection = Self.init()
    paddedCollection.reserveCapacity(paddedCount)
    paddedCollection.append(contentsOf: repeatElement(element, count: padElementCount))
    paddedCollection.append(contentsOf: self)

    return paddedCollection
  }

  /// Mutates a `RangeReplaceableCollection` by expanding its length
  /// to `paddedCount` repeating the padding `element` at the start.
  ///
  /// The collection not mutated in the case where the length of the collection is
  /// longer than or equal to the `paddedCount`.
  ///
  /// This example uses `padStart(with:toCount:)` to get a `String`
  /// justified to the desired `paddedCount`.
  ///
  ///     var myString = "Hello, World!"
  ///     myString.padStart(with: " ", toCount: 20)
  ///     myString // "       Hello, World!"
  ///
  /// - Parameters:
  ///   - element: The element which is repeated to expand the `Collection`.
  ///   - paddedCount: The length of the padded `Collection`.
  ///
  /// - Complexity: O(_m_), when the collection's length is less than the
  /// `paddedCount`, where _m_ is the `paddedCount`. O(_n_) when the
  /// collection's length is greater than or equal to the `paddedCount`, where
  /// _n_ is the length of the collection. For a `RandomAccessCollection`
  /// when the collection's length is greater than or equal to the `paddedCount`,
  /// the complexity is reduced to O(_1_).
  @inlinable
  public mutating func padStart(
    with element: Element,
    toCount paddedCount: Int
  ) {
    self = self.paddingStart(with: element, toCount: paddedCount)
  }

  /// Returns a new collection of the same type whose length is expanded
  /// to `paddedCount` by repeating the padding `element` at the end.
  ///
  /// In case the length of the collection is longer than or equal to the
  /// `paddedCount`, the original collection is returned.
  ///
  /// This example uses `paddingEnd(with:toCount:)` on `Data` to expand
  /// it to 8 bytes in length.
  ///
  ///     let data = Data([0xDE, 0xAD, 0xBE, 0xEF])
  ///         .paddingEnd(with: UInt8.zero, toCount: 8)
  ///     // data contains [0xDE, 0xAD, 0xBE, 0xEF, 0x00, 0x00, 0x00, 0x00]
  ///
  /// - Parameters:
  ///   - element: The element which is repeated to expand the collection.
  ///   - paddedCount: The length of the padded collection.
  ///
  /// - Complexity: O(_m_), when the collection's length is less than the
  /// `paddedCount`, where _m_ is the `paddedCount`. O(_n_) when the
  /// collection's length is greater than or equal to the `paddedCount`, where
  /// _n_ is the length of the collection. For a `RandomAccessCollection`
  /// when the collection's length is greater than or equal to the `paddedCount`,
  /// the complexity is reduced to O(_1_).
  @inlinable
  public func paddingEnd(
    with element: Element,
    toCount paddedCount: Int
  ) -> Self {
    let padElementCount = paddedCount - count

    // Early exit if no padding is required.
    guard padElementCount > 0 else { return self }

    var paddedCollection = Self.init()
    paddedCollection.reserveCapacity(paddedCount)
    paddedCollection.append(contentsOf: self)
    paddedCollection.append(contentsOf: repeatElement(element, count: padElementCount))

    return paddedCollection
  }

  /// Mutates a `RangeReplaceableCollection` by expanding its length
  /// to `paddedCount` repeating the padding `element` at the end.
  ///
  /// The collection not mutated in the case where the length of the collection is
  /// longer than or equal to the `paddedCount`.
  ///
  /// This example uses `padEnd(with:toCount:)` to get a `String`
  /// justified to the desired `paddedCount`.
  ///
  ///     var myString = "Hello, World!"
  ///     myString.padEnd(with: " ", toCount: 20)
  ///     myString // "Hello, World!       "
  ///
  /// - Parameters:
  ///   - element: The element which is repeated to expand the `Collection`.
  ///   - paddedCount: The length of the padded `Collection`.
  ///
  /// - Complexity: O(_m_), when the collection's length is less than the
  /// `paddedCount`, where _m_ is the `paddedCount`. O(_n_) when the
  /// collection's length is greater than or equal to the `paddedCount`, where
  /// _n_ is the length of the collection. For a `RandomAccessCollection`
  /// when the collection's length is greater than or equal to the `paddedCount`,
  /// the complexity is reduced to O(_1_).
  @inlinable
  public mutating func padEnd(
    with element: Element,
    toCount paddedCount: Int
  ) {
    self = self.paddingEnd(with: element, toCount: paddedCount)
  }
}
