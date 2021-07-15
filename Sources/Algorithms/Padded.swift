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

public struct PrefixPadded<Base: Collection> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let paddingElement: Base.Element

  @usableFromInline
  internal let paddingCount: Int

  @inlinable
  internal init(
    base: Base,
    paddingElement: Base.Element,
    paddedLength: Int
  ) {
    self.base = base
    self.paddingElement = paddingElement
    self.paddingCount = Swift.max(0, paddedLength - base.count)
  }
}

extension PrefixPadded: Collection {
  public typealias Element = Base.Element

  public struct Index: Comparable {
    @usableFromInline
    internal let state: State

    @inlinable
    internal init(state: PrefixPadded<Base>.Index.State) {
      self.state = state
    }

    @usableFromInline
    internal enum State: Equatable {
      case padding(Int)
      case base(Base.Index)

      @inlinable
      internal static func == (
        lhs: State,
        rhs: State
      ) -> Bool {
        switch (lhs, rhs) {
        case let (.padding(lhsPad), .padding(rhsPad)):
          return lhsPad == rhsPad
        case let (.base(lhsIndex), .base(rhsIndex)):
          return lhsIndex == rhsIndex
        default:
          return false
        }
      }
    }

    @inlinable
    public static func < (
      lhs: PrefixPadded<Base>.Index,
      rhs: PrefixPadded<Base>.Index
    ) -> Bool {
      switch (lhs.state, rhs.state) {
      case let (.base(lhsIndex), .base(rhsIndex)):
        return lhsIndex < rhsIndex
      case let (.padding(lhsPadIndex), .padding(rhsPadIndex)):
        return lhsPadIndex < rhsPadIndex
      case (.base, .padding):
        return false
      case (.padding, .base):
        return true
      }
    }

    @inlinable
    public static func == (
      lhs: PrefixPadded<Base>.Index,
      rhs: PrefixPadded<Base>.Index
    ) -> Bool {
      lhs.state == rhs.state
    }
  }

  @inlinable
  public var startIndex: Index {
    Index(
      state: paddingCount > 0
        ? .padding(0)
        : .base(base.startIndex))
  }

  @inlinable
  public var endIndex: Index {
    Index(state: .base(base.endIndex))
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")
    switch i.state {
    case .padding(let paddingIndex):
      return paddingIndex + 1 < paddingCount
        ? Index(state: .padding(paddingIndex + 1))
        : Index(state: .base(base.startIndex))
    case .base(let baseIndex):
      return Index(state: .base(base.index(after: baseIndex)))
    }
  }

  @inlinable
  public subscript(position: Index) -> Base.Element {
    precondition(position != endIndex, "Can't subscript using endIndex")
    switch position.state {
    case .padding: return paddingElement
    case .base(let index): return base[index]
    }
  }

  @inlinable
  public var count: Int {
    paddingCount + base.count
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    if distance >= 0 {
      guard let index = offsetForward(i, by: distance, limitedBy: endIndex) else {
        fatalError("Index is out of bounds")
      }
      return index
    } else {
      guard let index = offsetBackward(i, by: -distance, limitedBy: startIndex) else {
        fatalError("Index is out of bounds")
      }
      return index
    }
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    if distance >= 0 {
      return limit >= i
        ? offsetForward(i, by: distance, limitedBy: limit)
        : index(i, offsetBy: distance)
    } else {
      return limit <= i
        ? offsetBackward(i, by: -distance, limitedBy: limit)
        : index(i, offsetBy: distance)
    }
  }

  @inlinable
  internal func offsetForward(
    _ i: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit >= i)

    switch (i.state, limit.state) {
    case let (.padding(i), .padding(limit)):
      return i + distance <= limit
        ? Index(state: .padding(i + distance))
        : nil
    case let (.padding(i), .base(limit)):
      return i + distance >= paddingCount
        ? base.index(base.startIndex, offsetBy: distance - paddingCount + i, limitedBy:limit)
          .map { Index.init(state: .base($0)) }
        : Index(state: .padding(i + distance))
    case let (.base(i), .base(limit)):
      return base.index(i, offsetBy: distance, limitedBy:limit)
        .map { Index.init(state: .base($0)) }
    case (.base, .padding):
      // impossible because `limit >= i`
      fatalError()
    }
  }

  @inlinable
  internal func offsetBackward(
    _ i: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit <= i)

    switch (i.state, limit.state) {
    case let (.padding(i), .padding(limit)):
      return i - distance >= limit
        ? Index(state: .padding(i - distance))
        : nil
    case let (.base(i), .padding(limit)):
      let baseDistance = base.distance(from: base.startIndex, to: i)
      return baseDistance >= distance
        ? Index(state: .base(base.index(i, offsetBy: -distance)))
        : paddingCount - distance + baseDistance >= limit
          ? Index(state: .padding(paddingCount - distance + baseDistance))
          : nil
    case let (.base(i), .base(limit)):
      return base.index(i, offsetBy: -distance, limitedBy:limit)
        .map { Index.init(state: .base($0)) }
    case (.padding, .base):
      // impossible because `limit <= i`
      fatalError()
    }
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.state, end.state) {
    case let (.padding(start), .padding(end)):
      return end - start
    case let (.padding(start), .base(end)):
      return paddingCount - start + base.distance(from: base.startIndex, to: end)
    case let (.base(start), .padding(end)):
      return end - paddingCount + base.distance(from: start, to: base.startIndex)
    case let (.base(start), .base(end)):
      return base.distance(from: start, to: end)
    }
  }
}

extension PrefixPadded.Index.State: Hashable where Base.Index: Hashable {}
extension PrefixPadded.Index: Hashable where Base.Index: Hashable {}
extension PrefixPadded: RandomAccessCollection where Base: RandomAccessCollection {}

extension PrefixPadded: BidirectionalCollection
where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Can't advance before startIndex")
    switch i.state {
    case .padding(let paddingIndex):
      return Index(state: .padding(paddingIndex - 1))
    case .base(let baseIndex):
      return baseIndex == base.startIndex
        ? Index(state: .padding(paddingCount - 1))
        : Index(state: .base(base.index(before: baseIndex)))
    }
  }
}

extension Collection {
  @inlinable
  public func prefixPadded(
    with element: Element,
    toCount paddingLength: Int
  ) -> PrefixPadded<Self> {
    PrefixPadded(
      base: self,
      paddingElement: element,
      paddedLength: paddingLength)
  }
}

public struct SuffixPadded<Base: Collection> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let paddingElement: Base.Element

  @usableFromInline
  internal let paddingCount: Int

  @inlinable
  internal init(
    base: Base,
    paddingElement: Base.Element,
    paddedLength: Int
  ) {
    self.base = base
    self.paddingElement = paddingElement
    self.paddingCount = Swift.max(0, paddedLength - base.count)
  }
}

extension SuffixPadded: Collection {
  public typealias Element = Base.Element

  public struct Index: Comparable {
    @usableFromInline
    internal let state: State

    @inlinable
    internal init(state: SuffixPadded<Base>.Index.State) {
      self.state = state
    }

    @usableFromInline
    internal enum State: Equatable {
      case padding(Int)
      case base(Base.Index)

      @inlinable
      internal static func == (
        lhs: State,
        rhs: State
      ) -> Bool {
        switch (lhs, rhs) {
        case let (.padding(lhsPad), .padding(rhsPad)):
          return lhsPad == rhsPad
        case let (.base(lhsIndex), .base(rhsIndex)):
          return lhsIndex == rhsIndex
        default:
          return false
        }
      }
    }

    @inlinable
    public static func < (
      lhs: SuffixPadded<Base>.Index,
      rhs: SuffixPadded<Base>.Index
    ) -> Bool {
      switch (lhs.state, rhs.state) {
      case let (.base(lhsIndex), .base(rhsIndex)):
        return lhsIndex < rhsIndex
      case let (.padding(lhsPadIndex), .padding(rhsPadIndex)):
        return lhsPadIndex < rhsPadIndex
      case (.base, .padding):
        return true
      case (.padding, .base):
        return false
      }
    }

    @inlinable
    public static func == (
      lhs: SuffixPadded<Base>.Index,
      rhs: SuffixPadded<Base>.Index
    ) -> Bool {
      lhs.state == rhs.state
    }
  }

  @inlinable
  public var startIndex: Index {
    Index(state: .base(base.startIndex))
  }

  @inlinable
  public var endIndex: Index {
    Index(state: .padding(paddingCount))
  }

  /// Converts an index of `Base` to the corresponding `Index` by mapping
  /// `base.endIndex` to `Index(state: .padding(0))`.
  @inlinable
  internal func normalizeIndex(_ i: Base.Index) -> Index {
    i == base.endIndex ? Index(state: .padding(0)) : Index(state: .base(i))
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")
    switch i.state {
    case .padding(let paddingIndex):
      return Index(state: .padding(paddingIndex + 1))
    case .base(let baseIndex):
      return normalizeIndex(base.index(after: baseIndex))
    }
  }

  @inlinable
  public subscript(position: Index) -> Base.Element {
    precondition(position != endIndex, "Can't subscript using endIndex")
    switch position.state {
    case .padding: return paddingElement
    case .base(let index): return base[index]
    }
  }

  @inlinable
  public var count: Int {
    paddingCount + base.count
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    print("index distance", i, distance)
    if distance >= 0 {
      guard let index = offsetForward(i, by: distance, limitedBy: endIndex) else {
        fatalError("Index is out of bounds")
      }
      return index
    } else {
      guard let index = offsetBackward(i, by: -distance, limitedBy: startIndex) else {
        fatalError("Index is out of bounds")
      }
      return index
    }
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    if distance >= 0 {
      return limit >= i
        ? offsetForward(i, by: distance, limitedBy: limit)
        : index(i, offsetBy: distance)
    } else {
      return limit <= i
        ? offsetBackward(i, by: -distance, limitedBy: limit)
        : index(i, offsetBy: distance)
    }
  }

  @inlinable
  internal func offsetForward(
    _ i: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit >= i)

    switch (i.state, limit.state) {
    case let (.padding(i), .padding(limit)):
      return i + distance <= limit
        ? Index(state: .padding(i + distance))
        : nil
    case let (.base(i), .padding(limit)):
      let baseDistance = base.distance(from: i, to: base.endIndex)
      return baseDistance >= distance
        ? normalizeIndex(base.index(i, offsetBy: distance))
        : distance - baseDistance <= limit
          ? Index(state: .padding(distance - baseDistance))
          : nil
    case let (.base(i), .base(limit)):
      return base.index(i, offsetBy: distance, limitedBy:limit)
        .map(normalizeIndex)
    case (.padding, .base):
      // impossible because `limit >= i`
      fatalError()
    }
  }

  @inlinable
  internal func offsetBackward(
    _ i: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit <= i)

    switch (i.state, limit.state) {
    case let (.padding(i), .padding(limit)):
      return i - distance >= limit
        ? Index(state: .padding(i - distance))
        : nil
    case let (.padding(i), .base(limit)):
      return i - distance >= 0
        ? Index(state: .padding(i - distance))
        : base.index(base.endIndex, offsetBy: i - distance, limitedBy:limit)
          .map(normalizeIndex)
    case let (.base(i), .base(limit)):
      return base.index(i, offsetBy: -distance, limitedBy:limit)
        .map(normalizeIndex)
    case (.base, .padding):
      // impossible because `limit <= i`
      fatalError()
    }
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.state, end.state) {
    case let (.padding(start), .padding(end)):
      return end - start
    case let (.padding(start), .base(end)):
      return base.distance(from: base.endIndex, to: end) - start
    case let (.base(start), .padding(end)):
      return base.distance(from: start, to: base.endIndex) + end
    case let (.base(start), .base(end)):
      return base.distance(from: start, to: end)
    }
  }
}

extension SuffixPadded.Index.State: Hashable where Base.Index: Hashable {}
extension SuffixPadded.Index: Hashable where Base.Index: Hashable {}
extension SuffixPadded: RandomAccessCollection where Base: RandomAccessCollection {}

extension SuffixPadded: BidirectionalCollection
where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Can't advance before startIndex")
    switch i.state {
    case .padding(let paddingIndex):
      return paddingIndex == 0
        ? Index(state: .base(base.index(before:base.endIndex)))
        : Index(state: .padding(paddingIndex - 1))
    case .base(let baseIndex):
      return Index(state: .base(base.index(before: baseIndex)))
    }
  }
}

extension Collection {
  @inlinable
  public func suffixPadded(
    with element: Element,
    toCount paddingLength: Int
  ) -> SuffixPadded<Self> {
    SuffixPadded(
      base: self,
      paddingElement: element,
      paddedLength: paddingLength)
  }
}
