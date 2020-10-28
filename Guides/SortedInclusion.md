# Sorted Sequence Inclusion

[[Source](../Sources/Algorithms/SortedInclusion.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/SortedInclusionTests.swift)]

Methods to find how much two sorted sequences overlap.

(To-do: expand on this.)

## Detailed Design

The inclusion-detection methods are declared as extensions to `Sequence`.  The
overload that defaults comparisons to the standard less-than operator is
constrained to when the `Element` type conforms to `Comparable`.

A reported inclusion state is expressed with the `Inclusion` type.  This state
is based on the existence of elements that are shared, exclusive to the first
sequence, and exclusive to the second sequence.  This includes all the
degenerate combinations.  Convenience properties are included for easy tests.

```swift
enum Inclusion {
  case bothUninhabited, onlyFirstInhabited, onlySecondInhabited,
       dualExclusivesOnly, sharedOnly, firstExtendsSecond,
       secondExtendsFirst, dualExclusivesAndShared
}

extension Inclusion {
  var hasExclusivesToFirst: Bool { get }
  var hasExclusivesToSecond: Bool { get }
  var hasSharedElements: Bool { get }
  var areIdentical: Bool { get }
  var doesFirstIncludeSecond: Bool { get }
  var doesSecondIncludeFirst: Bool { get }
}

extension Sequence {
  func sortedOverlap<S: Sequence>(
    with other: S,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Inclusion where S.Element == Element
}

extension Sequence where Element: Comparable {
  func sortedOverlap<S: Sequence>(
    with other: S
  ) -> Inclusion where S.Element == Element
}
```

### Complexity

All of these methods have to walk the entirety of both sources, so they work in
O(_n_) operations, where _n_ is the length of the shorter source.

### Comparison with other languages

**C++:** The `<algorithm>` library defines the `includes` function, whose
functionality is part of the semantics of `sortedOverlap`.  The `includes`
function only detects of the second sequence is included within the first; it
doesn't notify if the inclusion is degenerate, or if inclusion fails because
it's actually reversed, both of which `sortedOverlap` can do.  To get the
direct functionality of `includes`, check the `doesFirstIncludeSecond` property
of the return value from `sortedOverlap`.

(To-do: add other languages.)
