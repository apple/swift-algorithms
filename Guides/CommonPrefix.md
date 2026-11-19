#  Common Prefix

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/CommonPrefix.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/CommonPrefixTests.swift)]

Methods for finding the longest common prefix or suffix of two sequences or
collections.

```swift
let string1 = "The quick brown fox jumps over the lazy dog."
let string2 = "The quick brown fox does not jump over the lazy dog."

string1.commonPrefix(with: string2) // "The quick brown fox "
string1.commonSuffix(with: string2) // " over the lazy dog."
```

Use `endOfCommonPrefix(with:)` to find the end of the longest common prefix of
two collections in both collections:

```swift
let (i1, i2) = string1.endOfCommonPrefix(with: string2)
string1[i1...] // "jumps over the lazy dog."
string2[i2...] // "does not jump over the lazy dog."
```

Similarly, `startOfCommonSuffix(with:)` finds the start of the longest common 
suffix of two collections in both collections:

```swift
let (i1, i2) = string1.startOfCommonSuffix(with: string2)
string1[..<i1] // "The quick brown fox jumps"
string2[..<i2] // "The quick brown fox does not jump"
```

## Detailed Design

All of the included methods take an equivalence function that can be left out
when the element type conforms to `Equatable`.

The `commonPrefix(with:)` method is available on sequences and takes a second
sequence as its argument. When called from a lazy context, the return type is
always `CommonPrefix`. If not, the method returns a `SubSequence` when called on
a collection, and on a sequence it returns an `[Element]` when an equivalence
function is provided and a `CommonPrefix` otherwise.

`CommonPrefix` always conforms to `Sequence` and conforms to `Collection` when
both base sequences conform. It also conforms to `LazySequenceProtocol` and
`LazyCollectionProtocol` when the first base sequence conforms.

|                              | `commonPrefix(with:)`        | `commonPrefix(with:by:)`
|------------------------------|------------------------------|------------------------------|
| **`LazySequenceProtocol`**   | `CommonPrefix<Self, Other>`  | `CommonPrefix<Self, Other>`  |
| **`Collection`**             | `Self.SubSequence`           | `Self.SubSequence`           |
| **`Sequence`**               | `CommonPrefix<Self, Other>`  | `[Self.Element]`             |

```swift
extension Sequence {
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> [Element]
}

extension Sequence where Element: Equatable {
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> CommonPrefix<Self, Other> where Other.Element == Element
}

extension LazySequenceProtocol {
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: @escaping (Element, Other.Element) -> Bool
  ) -> CommonPrefix<Self, Other>
}

extension Collection {
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> SubSequence
}

extension Collection where Element: Equatable {
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> SubSequence where Other.Element == Element
}

extension LazyCollectionProtocol where Element: Equatable {
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> CommonPrefix<Self, Other> where Other.Element == Element
}
```
 
The `commonSuffix(with:)` method is available on bidirectional collections and
takes a second bidirectional collection as its argument. It returns a
`SubSequence`.

```swift
extension BidirectionalCollection {
  public func commonSuffix<Other: BidirectionalCollection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> SubSequence
}

extension BidirectionalCollection where Element: Equatable {
  public func commonSuffix<Other: BidirectionalCollection>(
    with other: Other
  ) -> SubSequence where Other.Element == Element
}
```

The `endOfCommonPrefix(with:)` method is available on collections and takes a
second collection as its argument, returning a pair of indices that correspond
to the end of the longest common prefix in either collection.

```swift
extension Collection {
  public func endOfCommonPrefix<Other: Collection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> (Index, Other.Index)
}

extension Collection where Element: Equatable {
  public func endOfCommonPrefix<Other: Collection>(
    with other: Other
  ) -> (Index, Other.Index) where Other.Element == Element
}
```

The `startOfCommonSuffix(with:)` method is available on bidirectional
collections and takes a second bidirectional collection as its argument,
returning a pair of indices that correspond to the start of the longest common
suffix in either collection.

```swift
extension BidirectionalCollection {
  public func startOfCommonSuffix<Other: BidirectionalCollection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> (Index, Other.Index)
}

extension BidirectionalCollection where Element: Equatable {
  public func startOfCommonSuffix<Other: BidirectionalCollection>(
    with other: Other
  ) -> (Index, Other.Index) where Other.Element == Element
}
```

### Complexity

Calling these methods is O(_n_) where _n_ is the length of the corresponding
prefix or suffix, unless a `CommonSequence` is returned, in which case it's
O(1).

### Naming

The names `endsOfCommonPrefix` and `startsOfCommonSuffix` were considered
because a pair of indices is returned, but these were decided against in favor
of `endOfCommonPrefix` and `startOfCommonSuffix` to match the plurality of
"prefix" and "suffix".
