# Permutations

[[Source](../Sources/Algorithms/MergeSorted.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/MergeSortedTests.swift)]

A method that returns the merger of the sorted receiver and the sorted argument,
or a subset of that merger.  The result is also sorted, with the same criteria.

## Detailed Design

The `mergeSorted(with:keeping:by:)` method is declared as a `Sequence`
extension, and returns a standard `Array` of the same element type.

```swift
extension Sequence {
  /// Returns an array listing the merger of this sequence and the given
  /// sequence, but keeping only the selected subset, assuming both sources are
  /// sorted according to the given predicate that can compare elements.
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] where S.Element == Element
}
```

Besides the sequence that will be combined with the receiver and the predicate
to be used as the sorting criteria, the following subsets of the merged sequence
can be selected:

```swift
/// The manners two (multi)sets may be combined.
public enum SetCombination: CaseIterable {
  case nothing, firstMinusSecond, secondMinusFirst, symmetricDifference,
       intersection, first, second, union, sum
}
```

The `.sum` case is the usual merge sort.  The `.nothing`, `.first`, `.second`
cases are somewhat degenerate and aren't generally used.  The other cases are
the usual subsets.  The difference between `.union` and `.sum` is that the
former generates mergers where common elements are included only once, while the
latter includes both copies of each shared value.  When `.sum` is in place, the
copies from the second sequence go after all the copies from the first.

When the `Element` type is `Comparable`, the `mergeSorted(with:keeping:)` method
is added, which defaults the comparison predicate to the standard `<` operator:

```swift
extension Sequence where Element: Comparable {
  /// Returns an array listing the merger of this sequence and the given
  /// sequence, but keeping only the selected subset, and assuming both sources
  /// are sorted.
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination
  ) -> [Element] where S.Element == Element
}
```

If the ordering predicate does not throw, then the merged sequence may be
computed on-demand by making at least the receiver lazy:

```swift
extension LazySequenceProtocol {
  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given lazy sequence, but keeping only the selected subset, assuming both
  /// sources are sorted according to the given predicate that can compare
  /// elements.
  public func mergeSorted<S: LazySequenceProtocol>(
    with second: S,
    keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> MergedSequence<Elements, S.Elements> where S.Element == Element

  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given sequence, but keeping only the selected subset, assuming both
  /// sources are sorted according to the given predicate that can compare
  /// elements.
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> MergedSequence<Elements, S> where S.Element == Element
}

extension LazySequenceProtocol where Element: Comparable {
  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given lazy sequence, but keeping only the selected subset, and assuming
  /// both sources are sorted.
  public func mergeSorted<S: LazySequenceProtocol>(
    with second: S,
    keeping selection: SetCombination
  ) -> MergedSequence<Elements, S.Elements> where S.Element == Element

  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given sequence, but keeping only the selected subset, and assuming both
  /// sources are sorted.
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination
  ) -> MergedSequence<Elements, S> where S.Element == Element
}
```

If both source sequences also conform to (at least) `Collection`, then the
returned sequence representing the merger is also a collection.

### Complexity

Calling `mergeSorted(with:keeping:by:)` or `mergeSorted(with:keeping:)` is an
O(*n* + *m*) operation, where *n* and *m* are the lengths of the operand
sequences.  Creating an iterator and/or lazy sequence is O(1), while iterating
through all of lazy sequence will be O(*n* + *m*).  If the kept subset is one of
the degenerate cases, the complexity will be shorter.

### Comparison with other languages

**C++:** The `<algorithm>` library defines the `set_difference`,
`set_intersection`, `set_symmetric_difference`, `set_union`, and `merge`
functions.  They can be all distilled into one algorithm, which the
`mergeSorted(with:keeping:by:)` method and its overloads do for Swift.  The
`.firstMinusSecond` and `.secondMinusFirst` subsets are equivalent to calls to
`set_difference`; `.intersection` to `set_intersection`; `.symmetricDifference`
to `set_symmetric_difference`; `.union` to `set_union`; and `.sum` to `merge`.
