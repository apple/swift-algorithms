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

/// A namespace for methods which return composed collections,
/// formed by replacing a region of a base collection
/// with another collection of elements.
///
/// Access the namespace via the `.overlay` member, available on all collections:
///
/// ```swift
/// let base = 0..<5
/// for n in base.overlay.inserting(42, at: 2) {
///   print(n)
/// }
/// // Prints: 0, 1, 42, 2, 3, 4
/// ```
///
public struct OverlayCollectionNamespace<Elements: Collection> {

  public let elements: Elements

  @inlinable
  internal init(elements: Elements) {
    self.elements = elements
  }
}

extension Collection {

  /// A namespace for methods which return composed collections,
  /// formed by replacing a region of this collection
  /// with another collection of elements.
  ///
  @inlinable
  public var overlay: OverlayCollectionNamespace<Self> {
    OverlayCollectionNamespace(elements: self)
  }

  /// If `condition` is true, returns an `OverlayCollection` by applying the given closure.
  /// Otherwise, returns an `OverlayCollection` containing the same elements as this collection.
  ///
  /// The following example takes an array of products, lazily wraps them in a `ListItem` enum,
  /// and conditionally inserts a call-to-action element if `showCallToAction` is true.
  ///
  /// ```swift
  /// var listItems: some Collection<ListItem> {
  ///   let products: [Product] = ...
  ///   return products
  ///     .lazy.map { 
  ///       ListItem.product($0)
  ///     }
  ///     .overlay(if: showCallToAction) {
  ///       $0.inserting(.callToAction, at: min(4, $0.elements.count))
  ///     }
  /// }
  /// ```
  ///
  @inlinable
  public func overlay<Overlay>(
    if condition: Bool, _ makeOverlay: (OverlayCollectionNamespace<Self>) -> OverlayCollection<Self, Overlay>
  ) -> OverlayCollection<Self, Overlay> {
    if condition {
      return makeOverlay(overlay)
    } else {
      return OverlayCollection(base: self, overlay: nil, replacedRange: startIndex..<startIndex)
    }
  }
}

extension OverlayCollectionNamespace {

  @inlinable
  public func replacingSubrange<Overlay>(
    _ subrange: Range<Elements.Index>, with newElements: Overlay
  ) -> OverlayCollection<Elements, Overlay> {
    OverlayCollection(base: elements, overlay: newElements, replacedRange: subrange)
  }

  @inlinable
  public func appending<Overlay>(
    contentsOf newElements: Overlay
  ) -> OverlayCollection<Elements, Overlay> {
    replacingSubrange(elements.endIndex..<elements.endIndex, with: newElements)
  }

  @inlinable
  public func inserting<Overlay>(
    contentsOf newElements: Overlay, at position: Elements.Index
  ) -> OverlayCollection<Elements, Overlay> {
    replacingSubrange(position..<position, with: newElements)
  }

  @inlinable
  public func removingSubrange(
    _ subrange: Range<Elements.Index>
  ) -> OverlayCollection<Elements, EmptyCollection<Elements.Element>> {
    replacingSubrange(subrange, with: EmptyCollection())
  }

  @inlinable
  public func appending(
    _ element: Elements.Element
  ) -> OverlayCollection<Elements, CollectionOfOne<Elements.Element>> {
    appending(contentsOf: CollectionOfOne(element))
  }

  @inlinable
  public func inserting(
    _ element: Elements.Element, at position: Elements.Index
  ) -> OverlayCollection<Elements, CollectionOfOne<Elements.Element>> {
    inserting(contentsOf: CollectionOfOne(element), at: position)
  }

  @inlinable
  public func removing(
    at position: Elements.Index
  ) -> OverlayCollection<Elements, EmptyCollection<Elements.Element>> {
    removingSubrange(position..<elements.index(after: position))
  }
}

/// A composed collections, formed by replacing a region of a base collection
/// with another collection of elements.
///
/// To create an OverlayCollection, use the methods in the ``OverlayCollectionNamespace``
/// namespace:
///
/// ```swift
/// let base = 0..<5
/// for n in base.overlay.inserting(42, at: 2) {
///   print(n)
/// }
/// // Prints: 0, 1, 42, 2, 3, 4
/// ```
///
public struct OverlayCollection<Base, Overlay>
where Base: Collection, Overlay: Collection, Base.Element == Overlay.Element {

  @usableFromInline
  internal var base: Base

  @usableFromInline
  internal var overlay: Optional<Overlay>

  @usableFromInline
  internal var replacedRange: Range<Base.Index>

  @inlinable
  internal init(base: Base, overlay: Overlay?, replacedRange: Range<Base.Index>) {
    self.base = base
    self.overlay = overlay
    self.replacedRange = replacedRange
  }
}

extension OverlayCollection: Collection {

  public typealias Element = Base.Element

  public struct Index: Comparable {
    
    @usableFromInline
    internal enum Wrapped {
      case base(Base.Index)
      case overlay(Overlay.Index)
    }

    /// The underlying base/overlay index.
    ///
    @usableFromInline
    internal var wrapped: Wrapped

    /// The base index at which the overlay starts -- i.e. `replacedRange.lowerBound`
    ///
    @usableFromInline
    internal var startOfReplacedRange: Base.Index

    @inlinable
    internal init(wrapped: Wrapped, startOfReplacedRange: Base.Index) {
      self.wrapped = wrapped
      self.startOfReplacedRange = startOfReplacedRange
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.wrapped, rhs.wrapped) {
      case (.base(let unwrappedLeft), .base(let unwrappedRight)):
        return unwrappedLeft < unwrappedRight
      case (.overlay(let unwrappedLeft), .overlay(let unwrappedRight)):
        return unwrappedLeft < unwrappedRight
      case (.base(let unwrappedLeft), .overlay(_)):
        return unwrappedLeft < lhs.startOfReplacedRange
      case (.overlay(_), .base(let unwrappedRight)):
        return !(unwrappedRight < lhs.startOfReplacedRange)
      }
    }

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
      // No need to check 'startOfReplacedRange', because it does not differ between indices from the same collection.
      switch (lhs.wrapped, rhs.wrapped) {
      case (.base(let unwrappedLeft), .base(let unwrappedRight)):
        return unwrappedLeft == unwrappedRight
      case (.overlay(let unwrappedLeft), .overlay(let unwrappedRight)):
        return unwrappedLeft == unwrappedRight
      default:
        return false
      }
    }
  }
}

extension OverlayCollection {

  @inlinable
  internal func makeIndex(_ position: Base.Index) -> Index {
    Index(wrapped: .base(position), startOfReplacedRange: replacedRange.lowerBound)
  }

  @inlinable
  internal func makeIndex(_ position: Overlay.Index) -> Index {
    Index(wrapped: .overlay(position), startOfReplacedRange: replacedRange.lowerBound)
  }

  @inlinable
  public var startIndex: Index {
    if let overlay = overlay, base.startIndex == replacedRange.lowerBound {
      if overlay.isEmpty {
        return makeIndex(replacedRange.upperBound)
      }
      return makeIndex(overlay.startIndex)
    }
    return makeIndex(base.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    guard let overlay = overlay else {
      return makeIndex(base.endIndex)
    }
    if replacedRange.lowerBound != base.endIndex || overlay.isEmpty {
      return makeIndex(base.endIndex)
    }
    return makeIndex(overlay.endIndex)
  }

  @inlinable
  public var count: Int {
    guard let overlay = overlay else {
      return base.count
    }
    return base.distance(from: base.startIndex, to: replacedRange.lowerBound)
    + overlay.count
    + base.distance(from: replacedRange.upperBound, to: base.endIndex)
  }

  @inlinable
  public var isEmpty: Bool {
    return replacedRange.lowerBound == base.startIndex
    && replacedRange.upperBound == base.endIndex
    && (overlay?.isEmpty ?? true)
  }

  @inlinable
  public func index(after i: Index) -> Index {
    switch i.wrapped {
    case .base(var baseIndex):
      base.formIndex(after: &baseIndex)
      if let overlay = overlay, baseIndex == replacedRange.lowerBound {
        if overlay.isEmpty {
          return makeIndex(replacedRange.upperBound)
        }
        return makeIndex(overlay.startIndex)
      }
      return makeIndex(baseIndex)

    case .overlay(var overlayIndex):
      overlay!.formIndex(after: &overlayIndex)
      if replacedRange.lowerBound != base.endIndex, overlayIndex == overlay!.endIndex {
        return makeIndex(replacedRange.upperBound)
      }
      return makeIndex(overlayIndex)
    }
  }

  @inlinable
  public subscript(position: Index) -> Element {
    switch position.wrapped {
    case .base(let baseIndex): 
      return base[baseIndex]
    case .overlay(let overlayIndex):
      return overlay![overlayIndex]
    }
  }
}

extension OverlayCollection: BidirectionalCollection
where Base: BidirectionalCollection, Overlay: BidirectionalCollection {

  @inlinable
  public func index(before i: Index) -> Index {
    switch i.wrapped {
    case .base(var baseIndex):
      if let overlay = overlay, baseIndex == replacedRange.upperBound {
        if overlay.isEmpty {
          return makeIndex(base.index(before: replacedRange.lowerBound))
        }
        return makeIndex(overlay.index(before: overlay.endIndex))
      }
      base.formIndex(before: &baseIndex)
      return makeIndex(baseIndex)

    case .overlay(var overlayIndex):
      if overlayIndex == overlay!.startIndex {
        return makeIndex(base.index(before: replacedRange.lowerBound))
      }
      overlay!.formIndex(before: &overlayIndex)
      return makeIndex(overlayIndex)
    }
  }
}
