# Contains Count Where

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/ContainsCountWhere.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ContainsCountWhereTests.swift)]

Returns whether or not a sequence has a particular number of elements matching a given criteria.

If you need to compare the count of a filtered sequence, using this method can give you a performance boost over filtering the entire collection, then comparing its count.

```swift
let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print(numbers.contains(atLeast: 2, where: { $0.isMultiple(of: 3) }))
// prints "true"
```

These functions can return for _some_ infinite sequences with _some_ predicates whereas `filter(_:)` followed by `count` can’t ever do that, resulting in an infinite loop. For example, finding if there are more than 500 prime numbers with four digits (base 10). Note that there are 1,061 prime numbers with four digits, significantly more than 500.

```swift
// NOTE: Replace `primes` with a real infinite prime number `Sequence`.
let primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, …
print(primes.contains(moreThan: 500, where: { String($0).count == 4 }))
// prints "true"
```

## Detailed Design

A function named `contains(countIn:where:)` added as an extension to `Sequence`:

```swift
extension Sequence {
  public func contains<R: RangeExpression>(
    countIn rangeExpression: R,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool where R.Bound: FixedWidthInteger
}
```

Five small wrapper functions added to make working with different ranges easier and more readable at the call-site:

```swift
extension Sequence {
  public func contains(
    exactly exactCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool
  
  public func contains(
    atLeast minimumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool
  
  public func contains(
    moreThan minimumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool
  
  public func contains(
    lessThan maximumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool
  
  public func contains(
    lessThanOrEqualTo maximumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool
}
```

### Complexity

These methods are all O(_n_) in the worst case, but often return much earlier than that.

### Naming

The naming of this function is based off of the `contains(where:)` function on `Sequence` in the standard library. While the standard library function only checks for a non-zero count, these functions can check for any count.

### Comparison with other languages

Many languages have functions like Swift’s [`count(where:)`](https://github.com/apple/swift/pull/16099) function.<sup>[1](#footnote1)</sup> While these functions are useful when needing a complete count, they do not return early when simply needing to do a comparison on the count.

**C++:** The `<algorithm>` library’s [`count_if`](https://www.cplusplus.com/reference/algorithm/count_if/)

**Ruby:** [`count{|item|block}`](https://ruby-doc.org/core-1.9.3/Array.html#method-i-count)

----

<a name="footnote1">1</a>: [Temporarily removed](https://github.com/apple/swift/pull/22289#issue-249472009)