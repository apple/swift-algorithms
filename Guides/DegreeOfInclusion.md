# Sorted Sequence Inclusion

[[Source](../Sources/Algorithms/DegreeOfInclusion.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/DegreeOfInclusionTests.swift)]

Methods to find how much two sorted sequences overlap.

```swift
if (1...7).degreeOfInclusion(with: [1, 5, 6]).doesFirstIncludeSecond {
  print("The range is a superset of the array.")
}
```

The result is an enumeration detailing the precise containment relationship, if
any. If the result was `Bool`, then the method would need to be called again
(with swapped arguments) to confirm the actual inclusion degree.

## Detailed Design

The inclusion-detection methods are declared as extensions to `Sequence`. The
overload that defaults comparisons to the standard less-than operator is
constrained to when the `Element` type conforms to `Comparable`.

A reported inclusion state is expressed with the `SetInclusion` type. This state
is based on the existence of elements that are shared, exclusive to the first
sequence, and exclusive to the second sequence.  This includes all the
degenerate combinations, which are the ones where at least one source is empty.
Use the convenience properties `doesFirstIncludeSecond` and
`doesSecondIncludeFirst` (and `areIdentical`) to actually check if one source is
a superset of the other.

```swift
enum SetInclusion {
  case bothUninhabited, onlyFirstInhabited, onlySecondInhabited,
       dualExclusivesOnly, sharedOnly, firstExtendsSecond,
       secondExtendsFirst, dualExclusivesAndShared
}

extension SetInclusion {
  var hasExclusivesToFirst: Bool { get }
  var hasExclusivesToSecond: Bool { get }
  var hasSharedElements: Bool { get }
  var areIdentical: Bool { get }
  var doesFirstIncludeSecond: Bool { get }
  var doesSecondIncludeFirst: Bool { get }
}

extension Sequence {
  func degreeOfInclusion<S: Sequence>(
    with other: S,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> SetInclusion where S.Element == Element
}

extension Sequence where Element: Comparable {
  func degreeOfInclusion<S: Sequence>(
    with other: S
  ) -> SetInclusion where S.Element == Element
}
```

### Complexity

All of these methods have to walk the entirety of both sources, so they work in
O(_n_) operations, where _n_ is the length of the shorter source.

### Comparison with other languages

**C++:** The `<algorithm>` library defines the `includes` function, whose
functionality is part of the semantics of `degreeOfInclusion`. The `includes`
function only detects of the second sequence is included within the first; it
doesn't notify if the inclusion is degenerate, or if inclusion fails because
it's actually reversed, both of which `degreeOfInclusion` can do. To get the
direct functionality of `includes`, check the `doesFirstIncludeSecond` property
of the return value from `degreeOfInclusion`.

(To-do: add other languages.)
