# Overlay

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Overlay.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/OverlayTests.swift)]

Compose collections by overlaying the elements of one collection
over an arbitrary region of another collection.

Swift offers many interesting collections, for instance:

- `Range<Int>` allows us to express the numbers in `0..<1000`
   in an efficient way that does not allocate storage for each number.
   
- `Repeated<Int>` allows us to express, say, one thousand copies of the same value,
   without allocating space for a thousand values.
   
- `LazyMapCollection` allows us to transform the elements of a collection on-demand,
   without creating a copy of the source collection and eagerly transforming every element.

- The collections in this package, such as `.chunked`, `.cycled`, `.joined`, and `.interspersed`,
  similarly compute their elements on-demand.

While these collections can be very efficient, it is difficult to compose them in to arbitrary datasets.
If we have the Range `5..<10`, and want to insert a `0` in the middle of it, we would need to allocate storage
for the entire collection, losing the benefits of `Range<Int>`. Similarly, if we have some numbers in storage
(say, in an Array) and wish to insert a contiguous range in the middle of it, we have to allocate storage
in the Array and cannot take advantage of `Range<Int>` memory efficiency.

The `OverlayCollection` allows us to form arbitrary compositions without mutating
or allocating storage for the result.

```swift
// 'numbers' is a composition of:
// - Range<Int>, and
// - CollectionOfOne<Int>

let numbers = (5..<10).overlay.inserting(0, at: 7)

for n in numbers {
  // n: 5, 6, 0, 7, 8, 9
  //          ^
}
```

```swift
// 'numbers' is a composition of:
// - Array<Int>, and
// - Range<Int>

let rawdata = [3, 6, 1, 4, 6]
let numbers = rawdata.overlay.inserting(contentsOf: 5..<10, at: 3)

for n in numbers {
  // n: 3, 6, 1, 5, 6, 7, 8, 9, 4, 6
  //             ^^^^^^^^^^^^^
}
```

We can also insert elements in to a `LazyMapCollection`:

```swift
enum ListItem {
  case product(Product)
  case callToAction
}

let products: [Product] = ...

var listItems: some Collection<ListItem> {
  products
    .lazy.map { ListItem.product($0) }
    .overlay.inserting(.callToAction, at: min(4, products.count))
}

for item in listItems {
  // item: .product(A), .product(B), .product(C), .callToAction, .product(D), ...
  //                                              ^^^^^^^^^^^^^
}
```

## Detailed Design

An `.overlay` member is added to all collections:

```swift
extension Collection {
  public var overlay: OverlayCollectionNamespace<Self> { get }
}
```

This member returns a wrapper structure, `OverlayCollectionNamespace`,
which provides a similar suite of methods to the standard library's `RangeReplaceableCollection` protocol.  

However, while `RangeReplaceableCollection` methods mutate the collection they are applied to,
these methods return a new `OverlayCollection` value which substitutes the specified elements on-demand.

```swift
extension OverlayCollectionNamespace {

  // Multiple elements:

  public func replacingSubrange<Overlay>(
    _ subrange: Range<Elements.Index>, with newElements: Overlay
  ) -> OverlayCollection<Elements, Overlay>

  public func appending<Overlay>(
    contentsOf newElements: Overlay
  ) -> OverlayCollection<Elements, Overlay>

  public func inserting<Overlay>(
    contentsOf newElements: Overlay, at position: Elements.Index
  ) -> OverlayCollection<Elements, Overlay>

  public func removingSubrange(
    _ subrange: Range<Elements.Index>
  ) -> OverlayCollection<Elements, EmptyCollection<Elements.Element>>
  
  // Single elements:
  
  public func appending(
    _ element: Elements.Element
  ) -> OverlayCollection<Elements, CollectionOfOne<Elements.Element>>

  public func inserting(
    _ element: Elements.Element, at position: Elements.Index
  ) -> OverlayCollection<Elements, CollectionOfOne<Elements.Element>>

  public func removing(
    at position: Elements.Index
  ) -> OverlayCollection<Elements, EmptyCollection<Elements.Element>>
  
}
```

`OverlayCollection` conforms to `BidirectionalCollection` when both the base and overlay collections conform.

### Conditional Overlays

In order to allow overlays to be applied conditionally, another function is added to all collections:

```swift
extension Collection {

  public func overlay<Overlay>(
    if condition: Bool,
    _ makeOverlay: (OverlayCollectionNamespace<Self>) -> OverlayCollection<Self, Overlay>
  ) -> OverlayCollection<Self, Overlay>
  
}
```

If the `condition` parameter is `true`, the `makeOverlay` closure is invoked to apply the desired overlay.
If `condition` is `false`, the closure is not invoked, and the function returns a no-op overlay,
containing the same elements as the base collection. 

This allows overlays to be applied conditionally while still being usable as opaque return types:

```swift
func getNumbers(shouldInsert: Bool) -> some Collection<Int> {
  (5..<10).overlay(if: shouldInsert) { $0.inserting(0, at: 7) }
}

for n in getNumbers(shouldInsert: true) {
  // n: 5, 6, 0, 7, 8, 9
}

for n in getNumbers(shouldInsert: false) {
  // n: 5, 6, 7, 8, 9
}
``` 
