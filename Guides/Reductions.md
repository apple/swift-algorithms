# Reductions

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Reductions.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ReductionsTests.swift)]

Produces a sequence of values.

This has the behaviour of reduce, but instead of returning the final result
value, it returns the a sequence of the results returned from each element.

```swift
let runningTotal = (1...5).reductions(0, +)
print(Array(runningTotal))
// prints [0, 1, 3, 6, 10, 15]

let runningMinimum = [3, 4, 2, 3, 1].reductions(.max, min)
print(Array(runningMinimum))
// prints [3, 3, 2, 2, 1]
```

## Detailed Design

One new method is added to sequences:

```swift
extension LazySequenceProtocol {
  func reductions<Result>(
    _ initial: Result, 
    _ transform: @escaping (Result, Element) -> Result
  ) -> Reductions<Result, Self>
}

extension Sequence {
  public func reductions<Result>(
    _ initial: Result,
    _ transform: (Result, Element) throws -> Result
  ) rethrows -> [Result]
}
```

```swift
extension Collection {
  public func reductions(
    _ transform: (Element, Element) throws -> Element
  ) rethrows -> [Element]
}
```

### Complexity

Calling these methods is O(_1_).

### Naming

While the name `scan` is the term of art for this function, it has been 
discussed that `reductions` aligns better with the existing `reduce` function 
and will aid newcomers that might not know the existing `scan` term.

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

[SE-0045]: https://forums.swift.org/t/review-se-0045-add-scan-prefix-while-drop-while-and-iterate-to-the-stdlib/2382
[Issue 25]: https://github.com/apple/swift-algorithms/issues/25
[Brent_Royal-Gordon]: https://forums.swift.org/t/review-se-0045-add-scan-prefix-while-drop-while-and-iterate-to-the-stdlib/2382/6
[David Rönnqvist]: https://forums.swift.org/t/review-se-0045-add-scan-prefix-while-drop-while-and-iterate-to-the-stdlib/2382/8
[Kyle Macomber]: https://github.com/apple/swift-algorithms/issues/25#issuecomment-709317894

### Comparison with other langauges

**C++:** As of C++17, the `<algorithm>` library includes an `inclusive_scan`
function.

**[Clojure][Clojure]:** Clojure 1.2 added a `reductions` function.

**[Haskell][Haskell]:** Haskell includes a `scan` function for its
`Traversable` type, which is akin to Swift's `Sequence`.

**Python:** Python’s `itertools` includes an `accumulate` method. In version
3.3, a function paramenter was added. Version 3.8 added the optional initial
parameter.

**[Rust][Rust]:** Rust provides a `scan` function.

[Clojure]: http://clojure.github.io/clojure/clojure.core-api.html#clojure.core/reductions
[Haskell]: http://hackage.haskell.org/package/base-4.8.2.0/docs/Prelude.html#v:scanl
[Rust]: https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.scan
