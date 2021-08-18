# Product

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Product.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ProductTests.swift)]

A function for iterating over every pair of elements in two different
collections.

```swift
let seasons = ["winter", "spring", "summer", "fall"]
for (year, season) in product(1900...2020, seasons) {
    // ...
}

// Is equivalent to:
for years in 1900...2020 {
    for season in seasons {
        // ...
    }
}
```

When either collection is empty, the resulting wrapper collection is also empty.

## Detailed Design

The `product` function takes (at minimum) a sequence and a collection and
returns a `Product2Sequence` type:

```swift
public func product<Base1: Sequence, Base2: Collection>(
    _ s1: Base1, _ s2: Base2
) -> Product2Sequence<Base1, Base2>
```

We require `Collection` conformance for `Base2`, since it needs to be iterated
over multiple times. `Base1`, by contrast, is only iterated over a single time,
so it can be a sequence.
 
The `Product2Sequence` type wraps the base sequence and collection, and acts as
a sequence in the base case, upgrading to a collection, a bidirectional
collection, and a random-access collection when both base collections have those
conformances.

We don't provide higher arities (like `Product3Sequence`, `Product4Sequence`,
etc.) at this time to match the standard library's `Zip2` type. Users can
compose multiple calls to `product` if they would like higher arities.

### Complexity

Since the `product` function returns a wrapper type, that call is O(1);
collection operations on the resulting wrapper are O(_m \* n_).

### Naming

This function and the resulting collection provide the cartesian product of two
collections. While `product` is precedented in other languages, the name has an
unfortunate overlap with multiplication, where `product(numbers1, numbers2)`
could be seen as producing an element-wise product.

### Comparison with other languages

**Ruby:** You can call the `product` method on an array, passing one or more
arrays to form n-ary tuples — passing a single array gives the same semantics as
this function.

**Python:** Passing two or more collections to `product` returns the product of
those collections. Passing one collection and a `repeat=n` parameter is
equivalent to passing that collection `n` times. For example, `product("ABC",
repeat=2)` yields `"AA", "AB", "AC", "BA", "BB", "BC", "CA", "CB", "CC"`.

