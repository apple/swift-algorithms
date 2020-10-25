# Sorted Prefix

[[Source](../Sources/Algorithms/SortedPrefix.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/SortedPrefixTests.swift)]

Methods to measure how long a collection maintains being sorted, either along a given predicate or defaulting to the standard less-than operator, with variants for strictly-increasing sequences.

(To-Do: put better explaination here.)

## Detailed Design

The core methods are declared as extensions to `Collection`.  The versions that default comparison to the less-than operator are constrained to collections where the element type conforms to `Comparable`.

```swift
extension Collection {
 func sortedEndIndex(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index

 func rampedEndIndex(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index
}

extension Collection where Element: Comparable {
  func sortedEndIndex() -> Index
  func rampedEndIndex() -> Index
}
```

Checking if the entire collection is sorted (or strictly increasing) can be done by comparing the result of a showcased method to `endIndex`.

### Complexity

These methods have to walk their entire collection until a non-match is found, so they all work in O(_n_) operations, where _n_ is the length of the collection.

### Comparison with other languages

**C++:** The `<algorithm>` library defines `is_sorted` and `is_sorted_until`, the latter of which functions like `sortedEndPrefix`.

(To-Do: Put other languages here.)
