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

extension LazyCollection {

  @inlinable
  public func replacingSubrange<Replacements>(
    _ subrange: Range<Index>, with newElements: Replacements
  ) -> ReplacingSubrangeCollection<Base, Replacements> {
    ReplacingSubrangeCollection(base: elements, replacements: newElements, replacedRange: subrange)
  }
}

public struct ReplacingSubrangeCollection<Base, Replacements>
where Base: Collection, Replacements: Collection, Base.Element == Replacements.Element {

  @usableFromInline
  internal var base: Base

  @usableFromInline
  internal var replacements: Replacements

  @usableFromInline
  internal var replacedRange: Range<Base.Index>

  @inlinable
  internal init(base: Base, replacements: Replacements, replacedRange: Range<Base.Index>) {
    self.base = base
    self.replacements = replacements
    self.replacedRange = replacedRange
  }
}

extension ReplacingSubrangeCollection: Collection {

  public typealias Element = Base.Element

  public struct Index: Comparable {
    
    @usableFromInline
    internal enum Wrapped {
      case base(Base.Index)
      case replacement(Replacements.Index)
    }

    /// The underlying base/replacements index.
    ///
    @usableFromInline
    internal var wrapped: Wrapped

    /// The base indices which have been replaced.
    ///
    @usableFromInline
    internal var replacedRange: Range<Base.Index>

    @inlinable
    internal init(wrapped: Wrapped, replacedRange: Range<Base.Index>) {
      self.wrapped = wrapped
      self.replacedRange = replacedRange
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.wrapped, rhs.wrapped) {
      case (.base(let unwrappedLeft), .base(let unwrappedRight)):
        return unwrappedLeft < unwrappedRight
      case (.replacement(let unwrappedLeft), .replacement(let unwrappedRight)):
        return unwrappedLeft < unwrappedRight
      case (.base(let unwrappedLeft), .replacement(_)):
        return unwrappedLeft < lhs.replacedRange.lowerBound
      case (.replacement(_), .base(let unwrappedRight)):
        return !(unwrappedRight < lhs.replacedRange.lowerBound)
      }
    }

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
      // No need to check 'replacedRange', because it does not differ between indices from the same collection.
      switch (lhs.wrapped, rhs.wrapped) {
      case (.base(let unwrappedLeft), .base(let unwrappedRight)):
        return unwrappedLeft == unwrappedRight
      case (.replacement(let unwrappedLeft), .replacement(let unwrappedRight)):
        return unwrappedLeft == unwrappedRight
      default:
        return false
      }
    }
  }
}

extension ReplacingSubrangeCollection {

  @inlinable
  internal func makeIndex(_ position: Base.Index) -> Index {
    Index(wrapped: .base(position), replacedRange: replacedRange)
  }

  @inlinable
  internal func makeIndex(_ position: Replacements.Index) -> Index {
    Index(wrapped: .replacement(position), replacedRange: replacedRange)
  }

  @inlinable
  public var startIndex: Index {
    if base.startIndex == replacedRange.lowerBound {
      if replacements.isEmpty {
        return makeIndex(replacedRange.upperBound)
      }
      return makeIndex(replacements.startIndex)
    }
    return makeIndex(base.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    if replacedRange.lowerBound != base.endIndex || replacements.isEmpty {
      return makeIndex(base.endIndex)
    }
    return makeIndex(replacements.endIndex)
  }

  @inlinable
  public var count: Int {
    base.distance(from: base.startIndex, to: replacedRange.lowerBound)
    + replacements.count
    + base.distance(from: replacedRange.upperBound, to: base.endIndex)
  }

  @inlinable
  public func index(after i: Index) -> Index {
    switch i.wrapped {
    case .base(var baseIndex):
      base.formIndex(after: &baseIndex)
      if baseIndex == replacedRange.lowerBound {
        if replacements.isEmpty {
          return makeIndex(replacedRange.upperBound)
        }
        return makeIndex(replacements.startIndex)
      }
      return makeIndex(baseIndex)

    case .replacement(var replacementIndex):
      replacements.formIndex(after: &replacementIndex)
      if replacedRange.lowerBound != base.endIndex, replacementIndex == replacements.endIndex {
        return makeIndex(replacedRange.upperBound)
      }
      return makeIndex(replacementIndex)
    }
  }

  @inlinable
  public subscript(position: Index) -> Element {
    switch position.wrapped {
    case .base(let baseIndex): 
      return base[baseIndex]
    case .replacement(let replacementIndex): 
      return replacements[replacementIndex]
    }
  }
}

