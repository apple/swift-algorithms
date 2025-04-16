# Grouped

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/PartitionMap.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PartitionMapTests.swift)]
 
Groups up elements of a sequence into two Arrays while applying a transform closure for each element.

```swift
func process(results: [Result<Response, any Error>]) {
  let (successes, failures) = results
   .partitionMap { result -> PartitionMapResult2<Response, any Error> in
     switch result {
     case .success(let value): .first(value)
     case .failure(let error): .second(error)
     }
   }
}
```

It is similar to some other grouping functions, but achives another goals.
- in comparison to `partitioned(by:)` it allows to make to make a transform for each element of the source sequence 
independently for groups. Also it is possible to make more then 2 groups.
- in comparison to `grouped(by:)` & `split(whereSeparator:)` it has exact number of groups defined at compile time.
For `grouped(by:)` & `split(whereSeparator:)` number of groups is dynamicaly defined while program executiin.

## Detailed Design

The `partitionMap(_:)` method is declared as a `Sequence` extension returning a tuple with 2 or 3 arrays.
`([NewTypeA], [NewTypeB])`.

```swift
extension Sequence {
  public func partitionMap<A, B, C, Error>(
    _ transform: (Element) throws(Error) -> PartitionMapResult3<A, B, C>
  ) throws(Error) -> ([A], [B], [C])
}
```

`PartitionMapResult` Types are needed because of current generic limitations.
It is separated into public struct and internal enum. Such design has benefits
in comparison to plain enum:
- prevent its usage as a general purpose Either / OneOf Type – there are no
public properties which makes it usable outside the library.
- allows to rename `first`, `second` and `third` without source breakage.
If something more suitable will be found in future then old static initializers can be
deprecated with introducing new ones.

### Complexity

Calling `partitionMap(_:)` is an O(_n_) operation.
