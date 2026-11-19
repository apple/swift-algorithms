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

#if compiler(>=6.4) && hasFeature(Lifetimes)

//===----------------------------------------------------------------------===//
// prefix(maxCount:)
//===----------------------------------------------------------------------===//

/// An iterable that produces the first elements of a base iterable, up to a
/// maximum count.
///
/// Create a `PrefixIterable` by calling the `prefix(maxCount:)` method.
@available(anyAppleOS 27.0, *)
@frozen
public struct PrefixIterable<
  Base: Iterable & ~Copyable & ~Escapable
>: ~Copyable, ~Escapable where Base.Element: ~Copyable {
  @usableFromInline internal let _base: Base
  @usableFromInline internal let _maxCount: Int

  @export(implementation)
  @_lifetime(copy base)
  internal init(_base base: consuming Base, maxCount: Int) {
    precondition(maxCount >= 0, "Can't take a prefix of negative length.")
    _base = base
    _maxCount = maxCount
  }
}

@available(anyAppleOS 27.0, *)
extension PrefixIterable: Iterable
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable {
  public typealias Element = Base.Element
  public typealias Failure = Base.Failure

  /// The iterator for a `PrefixIterable`.
  @frozen
  public struct BorrowingIterator
  : BorrowingIteratorProtocol, ~Copyable, ~Escapable {
    public typealias Element = Base.Element
    public typealias Failure = Base.Failure

    @usableFromInline internal var _base: Base.BorrowingIterator
    @usableFromInline internal var _remaining: Int

    @export(implementation)
    @_lifetime(copy base)
    internal init(
      _base base: consuming Base.BorrowingIterator, remaining: Int
    ) {
      _base = base
      _remaining = remaining
    }

    @inlinable
    @_lifetime(&self)
    @_lifetime(self: copy self)
    public mutating func nextSpan(
      maxCount: Int
    ) throws(Base.Failure) -> Span<Base.Element> {
      precondition(maxCount >= 0, "Can't return a negative number of elements.")
      let limit = Swift.min(maxCount, _remaining)
      guard limit > 0 else { return Span() }
      let span = try _base.nextSpan(maxCount: limit)
      _remaining &-= (span.isEmpty ? _remaining : span.count)
      return span
    }

    @inlinable
    @_lifetime(self: copy self)
    public mutating func skip(by maxOffset: Int) throws(Base.Failure) -> Int {
      precondition(maxOffset >= 0, "Can't skip by a negative offset.")
      let limit = Swift.min(maxOffset, _remaining)
      guard limit > 0 else { return 0 }
      let skipped = try _base.skip(by: limit)
      // TODO: should we zero _remaining if `skipped` is less than `limit`?
      _remaining &-= skipped
      return skipped
    }
  }

  @export(implementation)
  @_lifetime(borrow self)
  public func makeBorrowingIterator() -> BorrowingIterator {
    BorrowingIterator(
      _base: _base.makeBorrowingIterator(), remaining: _maxCount
    )
  }

  @export(implementation)
  public var underestimatedCount: Int {
    Swift.min(_maxCount, _base.underestimatedCount)
  }
}

@available(anyAppleOS 27.0, *)
extension Iterable where Self: ~Copyable & ~Escapable, Element: ~Copyable {
  /// Returns an iterable that produces the first `maxCount` elements of this
  /// iterable.
  ///
  /// If this iterable has fewer than `maxCount` elements, the result produces
  /// every element. The result stores this iterable by value, consuming it.
  ///
  /// ```swift
  /// let numbers = [10, 20, 30, 40, 50]
  /// let firstThree = numbers.span.prefix(maxCount: 3)
  /// for x in firstThree { print(x) } // prints 10, 20, 30.
  /// ```
  ///
  /// - Parameter maxCount: The maximum number of elements to produce.
  ///   `maxCount` must be greater than or equal to zero.
  /// - Returns: An iterable that produces the first `maxCount` elements of
  ///   this iterable.
  @inlinable
  @_lifetime(copy self)
  public consuming func prefix(maxCount: Int) -> PrefixIterable<Self> {
    PrefixIterable(_base: self, maxCount: maxCount)
  }
}

#endif
