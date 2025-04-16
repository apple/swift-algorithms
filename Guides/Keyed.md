# Keyed

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Keyed.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/KeyedTests.swift)]

Stores the elements of a sequence as the values of a Dictionary, keyed by the result of the given closure.

```swift
let fruits = ["Apricot", "Banana", "Apple", "Cherry", "Blackberry", "Avocado", "Coconut"]
let fruitByLetter = fruits.keyed(by: { $0.first! })
// Results in:
// [
//     "A": "Avocado",
//     "B": "Blackberry",
//     "C": "Coconut",
// ]
```

On a key-collision, the latest element is kept by default. Alternatively, you can provide a closure which specifies which value to keep:

```swift
let fruits = ["Apricot", "Banana", "Apple", "Cherry", "Blackberry", "Avocado", "Coconut"]
let fruitsByLetter = fruits.keyed(
    by: { $0.first! },
    resolvingConflictsWith: { key, old, new in old } // Always pick the first fruit
)
// Results in:
// [
//     "A": "Apricot",
//     "B": "Banana",
//     "C": "Cherry",
// ]
```

## Detailed Design

The `keyed(by:)` and `keyed(by:resolvingConflictsWith:)` methods are declared in an `Sequence` extension, both returning `[Key: Element]`.

```swift
extension Sequence {
    public func keyed<Key>(
        by keyForValue: (Element) throws -> Key
    ) rethrows -> [Key: Element]
    
    public func keyed<Key>(
        by keyForValue: (Element) throws -> Key,
        resolvingConflictsWith resolve: ((Key, Element, Element) throws -> Element)? = nil
    ) rethrows -> [Key: Element]
}
```

### Complexity

Calling `keyed(by:)` is an O(_n_) operation.

### Comparison with other languages

| Language      | "Keying" API |
|---------------|-------------|
| Java          | [`toMap`](https://docs.oracle.com/en/java/javase/20/docs/api/java.base/java/util/stream/Collectors.html#toMap(java.util.function.Function,java.util.function.Function)) |
| Kotlin        | [`associatedBy`](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.collections/associate-by.html) |
| C#            | [`ToDictionary`](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.todictionary?view=net-7.0#system-linq-enumerable-todictionary) |
| Ruby (ActiveSupport) | [`index_by`](https://rubydoc.info/gems/activesupport/7.0.5/Enumerable#index_by-instance_method) |
| PHP (Laravel) | [`keyBy`](https://laravel.com/docs/10.x/collections#method-keyby) |

#### Rejected alternative names

1. Java's `toMap` is referring to `Map`/`HashMap`, their naming for Dictionaries and other associative collections. It's easy to confuse with the transformation function, `Sequence.map(_:)`.
2. C#'s `toXXX()` naming doesn't suite Swift well, which tends to prefer `Foo.init` over `toFoo()` methods.
3. Ruby's `index_by` naming doesn't fit Swift well, where "index" is a specific term (e.g. the `associatedtype Index` on `Collection`). There is also a [`index(by:)`](Index.md) method in swift-algorithms, is specifically to do with matching elements up with their indices, and not any arbitrary derived value.

#### Alternative names

Kotlin's `associatedBy` naming is a good alternative, and matches the past tense of [Swift's API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/), though perhaps we'd spell it `associated(by:)`.

#### Customization points

Java and C# are interesting in that they provide overloads that let you customize the type of the outermost collection. E.g. using an `OrderedDictionary` instead of the default (hashed, unordered) `Dictionary`.
