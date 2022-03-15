# Reductions

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Reductions.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ReductionsTests.swift)]

Produces all the intermediate results of reducing a sequence's elements using a 
closure.

```swift
let exclusiveRunningTotal = (1...5).reductions(0, +)
print(exclusiveRunningTotal)
// prints [0, 1, 3, 6, 10, 15]

let intoRunningTotal = (1...5).reductions(into: 0, +=)
print(intoRunningTotal)
// prints [0, 1, 3, 6, 10, 15]

let inclusiveRunningTotal = (1...5).reductions(+)
print(inclusiveRunningTotal)
// prints [1, 3, 6, 10, 15]
```

## Detailed Design

One trio of methods are added to `LazySequenceProtocol` for a lazily evaluated
sequence and another trio are added to `Sequence` which are eagerly evaluated.

```swift
extension LazySequenceProtocol {
    public func reductions<Result>(
        _ initial: Result,
        _ transform: @escaping (Result, Element) -> Result
    ) -> ExclusiveReductionsSequence<Result, Self>

    public func reductions<Result>(
        into initial: Result,
        _ transform: @escaping (inout Result, Element) -> Void
    ) -> ExclusiveReductionsSequence<Result, Self>

    public func reductions(
        _ transform: @escaping (Element, Element) -> Element
    ) -> InclusiveReductionsSequence<Self>
}
```

```swift
extension Sequence {
    public func reductions<Result>(
        _ initial: Result, 
        _ transform: (Result, Element) throws -> Result
    ) rethrows -> [Result]

    public func reductions<Result>(
        into initial: Result,
        _ transform: (inout Result, Element) throws -> Void
    ) rethrows -> [Result]

    public func reductions(
        _ transform: (Element, Element) throws -> Element
    ) rethrows -> [Element]
}
```

### Complexity

Calling the lazy methods, those defined on `LazySequenceProtocol`, is O(_1_).
Calling the eager methods, those returning an array, is O(_n_).

### Naming

While the name `scan` is the term of art for this function, it has been 
discussed that `reductions` aligns better with the existing `reduce` function 
and will aid newcomers that might not know the existing `scan` term. 

Deprecated `scan` methods have been added for people who are familiar with the
term, so they can easily discover the `reductions` methods via compiler
deprecation warnings.

Below are two quotes from the Swift forum [discussion about SE-0045][SE-0045] 
which proposed adding `scan` to the standard library and one from
[issue #25][Issue 25] on the swift-algorithms GitHub project. These provide
the reasoning to use the name `reductions`.

[Brent Royal-Gordon][Brent_Royal-Gordon]:
> I really like the `reduce`/`reductions` pairing instead of `reduce`/`scan`;
it does a really good job of explaining the relationship between the two
functions.

[David Rönnqvist][David Rönnqvist]:
> As other have already pointed out, I also feel that `scan` is the least
intuitive name among these and that the `reduce`/`reductions` pairing would do
a good job at explaining the relation between the two.

[Kyle Macomber][Kyle Macomber]:
> As someone unfamiliar with the prior art, `reductions` strikes me as very
approachable—I feel like I can extrapolate the expected behavior purely from my
familiarity with `reduce`.

As part of early discussions, it was decided to have two variants, one which
takes an initial value to use for the first element in the returned sequence, 
and another which uses the first value of the base sequence as the initial
value. C++ calls these variants exclusive and inclusive respectively and so 
these terms carry through as the name for the lazy sequences; 
`ExclusiveReductionsSequence` and `InclusiveReductionsSequence`.

[SE-0045]: https://forums.swift.org/t/review-se-0045-add-scan-prefix-while-drop-while-and-iterate-to-the-stdlib/2382
[Issue 25]: https://github.com/apple/swift-algorithms/issues/25
[Brent_Royal-Gordon]: https://forums.swift.org/t/review-se-0045-add-scan-prefix-while-drop-while-and-iterate-to-the-stdlib/2382/6
[David Rönnqvist]: https://forums.swift.org/t/review-se-0045-add-scan-prefix-while-drop-while-and-iterate-to-the-stdlib/2382/8
[Kyle Macomber]: https://github.com/apple/swift-algorithms/issues/25#issuecomment-709317894

### Comparison with other languages

**C++:** As of C++17, the `<algorithm>` library includes both
[`exclusive_scan`][C++ Exclusive] and [`inclusive_scan`][C++ Inclusive]
functions.

**[Clojure][Clojure]:** Clojure 1.2 added a `reductions` function.

**[Haskell][Haskell]:** Haskell includes a `scan` function for its
`Traversable` type, which is akin to Swift's `Sequence`.

**Python:** Python’s `itertools` includes an `accumulate` method. In version
3.3, a function parameter was added. Version 3.8 added the optional initial
parameter.

**[Rust][Rust]:** Rust provides a `scan` function.

[C++ Exclusive]: https://en.cppreference.com/w/cpp/algorithm/exclusive_scan
[C++ Inclusive]: https://en.cppreference.com/w/cpp/algorithm/inclusive_scan
[Clojure]: http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/reductions
[Haskell]: http://hackage.haskell.org/package/base-4.8.2.0/docs/Prelude.html#v:scanl
[Rust]: https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.scan
