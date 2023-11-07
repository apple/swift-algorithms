# Grouped

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Grouped.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/GroupedTests.swift)]
 
Groups up elements of a sequence into a new Dictionary, whose values are Arrays of grouped elements, each keyed by the result of the given closure.

```swift
let fruits = ["Apricot", "Banana", "Apple", "Cherry", "Avocado", "Coconut"]
let fruitsByLetter = fruits.grouped(by: { $0.first! })
// Results in:
// [
//     "B": ["Banana"],
//     "A": ["Apricot", "Apple", "Avocado"],
//     "C": ["Cherry", "Coconut"],
// ]
```

If you wish to achieve a similar effect but for single values (instead of Arrays of grouped values), see [`keyed(by:)`](Keyed.md).

## Detailed Design

The `grouped(by:)` method is declared as a `Sequence` extension returning
`[GroupKey: [Element]]`.

```swift
extension Sequence {
    public func grouped<GroupKey>(
        by keyForValue: (Element) throws -> GroupKey
    ) rethrows -> [GroupKey: [Element]]
}
```

### Complexity

Calling `grouped(by:)` is an O(_n_) operation.

### Comparison with other languages

| Language      | Grouping API |
|---------------|--------------|
| Java          | [`groupingBy`](https://docs.oracle.com/en/java/javase/20/docs/api/java.base/java/util/stream/Collectors.html#groupingBy(java.util.function.Function)) |
| Kotlin        | [`groupBy`](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/group-by.html) |
| C#            | [`GroupBy`](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.groupby?view=net-7.0#system-linq-enumerable-groupby) |
| Rust          | [`group_by`](https://doc.rust-lang.org/std/primitive.slice.html#method.group_by) |
| Ruby          | [`group_by`](https://ruby-doc.org/3.2.2/Enumerable.html#method-i-group_by) |
| Python        | [`groupby`](https://docs.python.org/3/library/itertools.html#itertools.groupby) |
| PHP (Laravel) | [`groupBy`](https://laravel.com/docs/10.x/collections#method-groupby) |

#### Naming

All the surveyed languages name this operation with a variant of "grouped" or "grouping". The past tense `grouped(by:)` best fits [Swift's API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

#### Customization points

Java and C# are interesting in that they provide multiple overloads with several points of customization:

1. Changing the type of the groups.
    1. E.g. the groups can be Sets instead of Arrays.
    1. Akin to calling `.transformValues { group in Set(group) }` on the resultant dictionary, but avoiding the intermediate allocation of Arrays of each group.
2. Picking which elements end up in the groupings.
    1. The default is the elements of the input sequence, but can be changed.
    2. Akin to calling `.transformValues { group in group.map(someTransform) }` on the resultant dictionary, but avoiding the intermediate allocation of Arrays of each group.
3. Changing the type of the outermost collection.
    1. E.g using an `OrderedDictionary`, `SortedDictionary` or `TreeDictionary` instead of the default (hashed, unordered) `Dictionary`.
    2. There's no great way to achieve this with the  `grouped(by:)`. One could wrap the resultant dictionary in an initializer to one of the other dictionary types, but that isn't sufficient: Once the `Dictionary` loses the ordering, there's no way to get it back when constructing one of the ordered dictionary variants.

It is not clear which of these points of customization are worth supporting, or what the best way to express them might be.
