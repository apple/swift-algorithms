# Binary Search

[[Source](../Sources/Algorithms/BinarySearch.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/BinarySearchTests.swift)]

Methods that locate a given value within a collection, narrowing the location by half in each round.  The collection already has to be sorted along the given predicate, or simple non-decreasing order if the predicate is defaulted to the standard less-than operator.

As many data structures need to internally store their elements in order, the pre-sorted requirement usually isn't onerous.

(To-Do: put better explanation here.)

## Detailed Design

The core methods are declared as extensions to `Collection`.  The versions that default comparison to the less-than operator are constrained to collections where the element type conforms to `Comparable`.

```swift
extension Collection {
  func someSortedPosition(
    of target: Element,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> (index: Index, isMatch: Bool)

  func lowerSortedBound(
    around match: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index

  func upperSortedBound(
    around match: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index

  func sortedRange(
    for target: Element,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Range<Index>
}

extension Collection where Element: Comparable {
  func someSortedPosition(of target: Element) -> (index: Index, isMatch: Bool)
  func lowerSortedBound(around match: Index) -> Index
  func upperSortedBound(around match: Index) -> Index
  func sortedRange(for target: Element) -> Range<Index>
}
```

Generally, only `sortedRange(for:)`, or `sortedRange(for: by:)`, is needed to perform a binary search.  These methods are wrappers to calls to the other three.  Use those other methods if you need only one phase of the search process and you want to save time.

Note that while `sortedRange` and `someSortedPosition` work with a target value, and therefore may not be actually present in the collection, the `lowerSortedBound` and `upperSortedBound` methods work with a target index; that index must point to a known-good match, such as the first result from `someSortedPosition` (if the second result from that same call is `true`).

### Complexity

The search process narrows down the range in half each time, leading the search to work in O(log _n_) rounds, where _n_ is the length of the collection.  When the collection supports O(1) traversal, _i.e._ random access, the search will then work in O(log _n_) operations.  Search is permitted for collections with sub-random-access traversal, but this worsens the time for search to O(_n_).

### Comparison with other languages

**C++:** The `<algorithm>` library defines `binary_search` as an analog to `someSortedPosition`.  The C++ function returns only an existence check; you cannot exploit the result, either success or failure, without calling a related method.  Since the computation ends up with the location anyway, the Swift method bundles the existence check along with where the qualifying element was found.  The returned index helps even during failure, as it's the best place to insert a matching element.

Of course, immediately using only the `isMatch` member from a call to `someSortedPosition` acts as a direct counterpart to `binary_search`.

Some implementations of `binary_search` may punt to `lower_bound`, but `someSortedPosition` stops at the first discovered match, without unnecessarily taking extra time searching for the border.  The trade-off is that `someSortedPosition` needs to do up to two comparisons per round instead of one.

The same library defines `lower_bound` and `upper_bound` as analogs to `lowerSortedBound` and `upperSortedBound`.  The C++ functions match `binary_search` in that they search for a target value, while the Swift methods take a known-good target index.  This difference in the Swift methods is meant to segregate functionality.

The same C++ library defines `equal_range` as an analog to `sortedRange`.

(To-Do: Put other languages here.)
