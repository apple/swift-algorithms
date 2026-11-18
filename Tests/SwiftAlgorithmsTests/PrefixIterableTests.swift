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

import Algorithms
import XCTest

/// Throws from its third `nextSpan` call, and from `skip` if `skipFails`.
@available(anyAppleOS 27.0, *)
private struct ThrowingIterable: Iterable, ~Escapable {

  typealias Element = Int
  typealias Failure = TestError

  let base: Span<Int>
  let skipFails: Bool

  @_lifetime(copy base)
  init(_ base: Span<Int>, skipFails: Bool = false) {
    self.base = base
    self.skipFails = skipFails
  }

  struct BorrowingIterator: BorrowingIteratorProtocol, ~Copyable, ~Escapable {
    typealias Element = Int
    typealias Failure = TestError

    var inner: Span<Int>.BorrowingIterator
    let skipFails: Bool
    var calls = 0

    @_lifetime(copy inner)
    init(_ inner: consuming Span<Int>.BorrowingIterator, skipFails: Bool) {
      self.inner = inner
      self.skipFails = skipFails
    }

    @_lifetime(&self)
    @_lifetime(self: copy self)
    mutating func nextSpan(maxCount: Int) throws(TestError) -> Span<Int> {
      if calls == 2 { throw TestError() }
      calls += 1
      return inner.nextSpan(maxCount: maxCount)
    }

    @_lifetime(self: copy self)
    mutating func skip(by maxOffset: Int) throws(TestError) -> Int {
      if skipFails { throw TestError() }
      return inner.skip(by: maxOffset)
    }
  }

  @_lifetime(borrow self)
  func makeBorrowingIterator() -> BorrowingIterator {
    BorrowingIterator(base.makeBorrowingIterator(), skipFails: skipFails)
  }
}

private struct TestError: Error, Equatable {}

/// Counts the calls that an iterator receives.
private final class CallLog {
  var nextSpanCalls = 0
  var skipCalls = 0
}

/// Returns at most `chunkSize` elements per `nextSpan` call, and logs calls.
@available(anyAppleOS 27.0, *)
private struct ShortSpanIterable: Iterable, ~Escapable {
  typealias Element = Int

  let base: Span<Int>
  let chunkSize: Int
  let log: CallLog

  @_lifetime(copy base)
  init(_ base: Span<Int>, chunkSize: Int = .max, log: CallLog = CallLog()) {
    self.base = base
    self.chunkSize = chunkSize
    self.log = log
  }

  struct BorrowingIterator: BorrowingIteratorProtocol, ~Copyable, ~Escapable {
    typealias Element = Int

    var inner: Span<Int>.BorrowingIterator
    let chunkSize: Int
    let log: CallLog

    @_lifetime(copy inner)
    init(
      _ inner: consuming Span<Int>.BorrowingIterator,
      chunkSize: Int,
      log: CallLog
    ) {
      self.inner = inner
      self.chunkSize = chunkSize
      self.log = log
    }

    @_lifetime(&self)
    @_lifetime(self: copy self)
    mutating func nextSpan(maxCount: Int) -> Span<Int> {
      log.nextSpanCalls += 1
      return inner.nextSpan(maxCount: Swift.min(maxCount, chunkSize))
    }

    @_lifetime(self: copy self)
    mutating func skip(by maxOffset: Int) -> Int {
      log.skipCalls += 1
      return inner.skip(by: maxOffset)
    }
  }

  @_lifetime(borrow self)
  func makeBorrowingIterator() -> BorrowingIterator {
    BorrowingIterator(
      base.makeBorrowingIterator(), chunkSize: chunkSize, log: log)
  }
}

private struct Token: ~Copyable {
  var id: Int
}

class IterableTestCase: XCTestCase {
  override func setUpWithError() throws {
    guard #available(anyAppleOS 27.0, *) else {
      throw XCTSkip("Iterable requires anyAppleOS 27.0.")
    }
  }
}

@available(anyAppleOS 27.0, *)
final class PrefixIterableTests: IterableTestCase {
  /// Collects all elements, requesting at most `chunk` at a time.
  private func elements<Base: Iterable & ~Copyable & ~Escapable>(
    of iterable: borrowing Base,
    chunk: Int = .max
  ) -> [Base.Element]
  where Base.Element: Copyable, Base.Failure == Never {
    var iterator = iterable.makeBorrowingIterator()
    var result: [Base.Element] = []
    while true {
      let span = iterator.nextSpan(maxCount: chunk)
      if span.isEmpty { break }
      for i in span.indices {
        result.append(span[i])
      }
    }
    return result
  }

  func testCounts() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    XCTAssertEqual(elements(of: span.prefix(maxCount: 3)), [10, 20, 30])
    XCTAssertEqual(elements(of: span.prefix(maxCount: 1)), [10])
    XCTAssertEqual(elements(of: span.prefix(maxCount: 0)), [])
    XCTAssertEqual(elements(of: span.prefix(maxCount: 5)), numbers)
    XCTAssertEqual(elements(of: span.prefix(maxCount: 99)), numbers)
    XCTAssertEqual(
      elements(of: span.prefix(maxCount: .max)), numbers)
  }

  func testChunkedConsumption() {
    var numbers = [10, 20, 30, 40, 50]
    for chunk in [1, 2, 3, 4, 100] {
      XCTAssertEqual(
        elements(of: numbers.mutableSpan.prefix(maxCount: 3), chunk: chunk),
        [10, 20, 30],
        "chunk size \(chunk)"
      )
    }
  }

  func testPrefixOfPrefix() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    XCTAssertEqual(
      elements(of: span.prefix(maxCount: 4).prefix(maxCount: 2)), [10, 20]
    )
    XCTAssertEqual(
      elements(of: span.prefix(maxCount: 2).prefix(maxCount: 4)), [10, 20]
    )
  }

  func testUnderestimatedCount() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    XCTAssertEqual(span.prefix(maxCount: 3).underestimatedCount, 3)
    XCTAssertEqual(span.prefix(maxCount: 5).underestimatedCount, 5)
    XCTAssertEqual(span.prefix(maxCount: 99).underestimatedCount, 5)
    XCTAssertEqual(span.prefix(maxCount: 0).underestimatedCount, 0)
  }

  func testSkip() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let result = span.prefix(maxCount: 4)
    var iterator = result.makeBorrowingIterator()
    XCTAssertEqual(iterator.skip(by: 0), 0)
    XCTAssertEqual(iterator.skip(by: 1), 1)
    XCTAssertEqual(iterator.nextSpan(maxCount: 1)[0], 20)
    XCTAssertEqual(iterator.skip(by: 100), 2)
    XCTAssertTrue(iterator.nextSpan(maxCount: 10).isEmpty)
    XCTAssertEqual(iterator.skip(by: 5), 0)
  }

  func testInlineArray() {
    let inline: InlineArray<4, Int> = [1, 2, 3, 4]
    XCTAssertEqual(elements(of: inline.prefix(maxCount: 2)), [1, 2])
  }

  func testNoncopyableElements() {
    var unique = UniqueArray<Token>()
    for id in 0..<5 {
      unique.append(Token(id: id))
    }
    let result = unique.prefix(maxCount: 3)
    var iterator = result.makeBorrowingIterator()
    var ids: [Int] = []
    while true {
      let span = iterator.nextSpan(maxCount: 2)
      if span.isEmpty { break }
      for i in span.indices {
        ids.append(span[i].id)
      }
    }
    XCTAssertEqual(ids, [0, 1, 2])
  }

  /// Returns `iterable`'s elements one at a time.
  private func oneByOne(
    _ iterable: borrowing some Iterable<Int, TestError> & ~Copyable & ~Escapable
  ) -> (elements: [Int], error: TestError?) {
    var iterator = iterable.makeBorrowingIterator()
    var result: [Int] = []
    do throws(TestError) {
      while true {
        let span = try iterator.nextSpan(maxCount: 1)
        if span.isEmpty { break }
        result.append(span[0])
      }
    } catch {
      return (result, error)
    }
    return (result, nil)
  }

  func testPropagatesTypedFailure() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let (elements, error) = oneByOne(ThrowingIterable(span).prefix(maxCount: 9))
    XCTAssertEqual(elements, [10, 20])
    XCTAssertEqual(error, TestError())
  }

  func testCompletePrefix() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let (elements, error) = oneByOne(ThrowingIterable(span).prefix(maxCount: 2))
    XCTAssertEqual(elements, [10, 20])
    XCTAssertNil(error)
  }

  func testShortSpans() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    XCTAssertEqual(
      elements(of: ShortSpanIterable(span, chunkSize: 2).prefix(maxCount: 4)),
      [10, 20, 30, 40]
    )
    XCTAssertEqual(
      elements(of: ShortSpanIterable(span, chunkSize: 2).prefix(maxCount: 5)),
      numbers
    )
    XCTAssertEqual(
      elements(of: ShortSpanIterable(span, chunkSize: 2).prefix(maxCount: 99)),
      numbers
    )
  }

  func testExhaustedBase() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let log = CallLog()
    let result = ShortSpanIterable(span, log: log).prefix(maxCount: 99)
    var iterator = result.makeBorrowingIterator()
    XCTAssertEqual(iterator.nextSpan(maxCount: 99).count, 5)
    for _ in 0..<3 {
      XCTAssertTrue(iterator.nextSpan(maxCount: 99).isEmpty)
    }
    XCTAssertEqual(log.nextSpanCalls, 2)
  }

  func testSkipPastEndOfShortBase() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let result = span.prefix(maxCount: 99)
    var iterator = result.makeBorrowingIterator()
    XCTAssertEqual(iterator.skip(by: 1), 1)
    // The prefix has 98 left, but the base has only 4.
    XCTAssertEqual(iterator.skip(by: 100), 4)
    XCTAssertTrue(iterator.nextSpan(maxCount: 10).isEmpty)
    XCTAssertEqual(iterator.skip(by: 1), 0)
  }

  func testSkipIsForwardedToBase() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let log = CallLog()
    let result = ShortSpanIterable(span, log: log).prefix(maxCount: 4)
    var iterator = result.makeBorrowingIterator()
    XCTAssertEqual(iterator.skip(by: 3), 3)
    XCTAssertEqual(log.skipCalls, 1)
    XCTAssertEqual(log.nextSpanCalls, 0)
    let rest = iterator.nextSpan(maxCount: 10)
    XCTAssertEqual(rest.count, 1)
    XCTAssertEqual(rest[0], 40)
  }

  func testSkipOfNothing() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let log = CallLog()
    let result = ShortSpanIterable(span, log: log).prefix(maxCount: 2)
    var iterator = result.makeBorrowingIterator()
    XCTAssertEqual(iterator.skip(by: 0), 0)
    XCTAssertEqual(iterator.nextSpan(maxCount: 10).count, 2)
    XCTAssertEqual(iterator.skip(by: 3), 0)
    XCTAssertEqual(log.skipCalls, 0)
  }

  func testSkipPropagatesTypedFailure() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let result = ThrowingIterable(span, skipFails: true).prefix(maxCount: 3)
    var iterator = result.makeBorrowingIterator()
    var thrown: TestError?
    do throws(TestError) {
      _ = try iterator.skip(by: 2)
    } catch {
      thrown = error
    }
    XCTAssertEqual(thrown, TestError())

    let empty = ThrowingIterable(span, skipFails: true).prefix(maxCount: 0)
    var emptyIterator = empty.makeBorrowingIterator()
    XCTAssertEqual(try emptyIterator.skip(by: 2), 0)
  }

  func testNextSpanOfZero() {
    let numbers = [10, 20, 30, 40, 50]
    let span = numbers.span
    let log = CallLog()
    let result = ShortSpanIterable(span, log: log).prefix(maxCount: 3)
    var iterator = result.makeBorrowingIterator()
    XCTAssertTrue(iterator.nextSpan(maxCount: 0).isEmpty)
    XCTAssertEqual(log.nextSpanCalls, 0)
    XCTAssertEqual(iterator.nextSpan(maxCount: 10).count, 3)
  }
}

#endif
