# Trim

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Trim.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/TrimTests.swift)]

Returns a `SubSequence` formed by discarding all elements at the start and end 
of the collection which satisfy the given predicate.

This example uses `trimming(while:)` to get a substring without the white space 
at the beginning and end of the string.

```swift
let myString = "   hello, world  "
print(myString.trimming(while: \.isWhitespace)) // "hello, world"

let results = [2, 10, 11, 15, 20, 21, 100].trimming(while: { $0.isMultiple(of: 2) })
print(results) // [11, 15, 20, 21]
```

## Detailed Design

A new method is added to `BidirectionalCollection`:

```swift
extension BidirectionalCollection {
    public func trimming(while predicate: (Element) throws -> Bool) rethrows -> SubSequence
}
```

This method requires `BidirectionalCollection` for an efficient implementation 
which visits as few elements as possible.

A less-efficient implementation is _possible_ for any `Collection`, which would 
involve always traversing the entire collection. This implementation is not 
provided, as it would mean developers of generic algorithms who forget to add
the `BidirectionalCollection` constraint will receive that inefficient
implementation:

```swift
func myAlgorithm<Input>(input: Input) where Input: Collection {
    let trimmedInput = input.trimming(while: { ... }) // Uses least-efficient implementation.
}

func myAlgorithm2<Input>(input: Input) where Input: BidirectionalCollection {
    let trimmedInput = input.trimming(while: { ... }) // Uses most-efficient implementation.
}
```

Swift provides the `BidirectionalCollection` protocol for marking types which 
support reverse traversal, and generic types and algorithms which want to make 
use of that should add it to their constraints.

### >= 0.3.0

In `v0.3.0` new methods are added to allow discarding all the elements matching 
the predicate at the beginning (prefix) or at the ending (suffix) of the 
collection.
- `trimmingSuffix(while:)` can only be run on collections conforming to the 
`BidirectionalCollection` protocol.  
- `trimmingPrefix(while:)` can be run also on collections conforming to the 
`Collection` protocol.

```swift
let myString = "   hello, world  "
print(myString.trimmingPrefix(while: \.isWhitespace)) // "hello, world   "

print(myString.trimmingSuffix(while: \.isWhitespace)) // "   hello, world"
```
Also mutating variants for all the methods already existing and the new ones are 
added.
```swift
var myString = "   hello, world  "
myString.trim(while: \.isWhitespace)
print(myString) // "hello, world"
```

### Complexity

Calling this method is O(_n_).

### Naming

The name `trim` has precedent in other programming languages. Another popular 
alternative might be `strip`.

| Example usage | Languages |
|-|-|
| ''String''.Trim([''chars'']) | C#, VB.NET, Windows PowerShell |
| ''string''.strip(); | D |
| (.trim ''string'') | Clojure |
| ''sequence'' [ predicate? ] trim | Factor |
| (string-trim '(#\Space #\Tab #\Newline) ''string'') | Common Lisp |
| (string-trim ''string'') | Scheme |
| ''string''.trim() | Java, JavaScript (1.8.1+), Rust |
| Trim(''String'') | Pascal, QBasic, Visual Basic, Delphi |
| ''string''.strip() | Python |
| strings.Trim(''string'', ''chars'') | Go |
| LTRIM(RTRIM(''String'')) | Oracle SQL, T-SQL |
| string:strip(''string'' [,''option'', ''char'']) | Erlang |
| ''string''.strip or ''string''.lstrip or ''string''.rstrip | Ruby |
| trim(''string'') | PHP, Raku |
| [''string'' stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] | Objective-C/Cocoa |
| ''string'' withBlanksTrimmed ''string'' withoutSpaces ''string'' withoutSeparators | Smalltalk |
| string trim ''$string'' | Tcl |
| TRIM(''string'') or TRIM(ADJUSTL(''string'')) | Fortran |
| TRIM(''string'') | SQL |
| String.trim ''string'' | OCaml 4+ |

Note: This is an abbreviated list from Wikipedia.
[Full table](https://en.wikipedia.org/wiki/Comparison_of_programming_languages_(string_functions)#trim)

The standard library includes a variety of methods which perform similar 
operations:

- Firstly, there are `dropFirst(Int)` and `dropLast(Int)`. These return slices 
but do not support user-defined predicates. If the collection's `count` is less 
than the number of elements to drop, they return an empty slice.
- Secondly, there is `drop(while:)`, which also returns a slice and is 
equivalent to a 'left-trim' (trimming from the head but not the tail). If the 
entire collection is dropped, this method returns an empty slice.
- Thirdly, there are `removeFirst(Int)` and `removeLast(Int)` which do not 
return slices and actually mutate the collection. If the collection's `count` is 
less than the number of elements to remove, this method triggers a runtime 
error.
- Lastly, there are the `popFirst()` and `popLast()` methods, which work like 
`removeFirst()` and `removeLast()`, except they do not trigger a runtime error 
for empty collections.

The closest neighbours to this function would be the `drop` family of methods. 
Unfortunately, unlike `dropFirst(Int)`,the name `drop(while:)` does not specify 
which end(s) of the  collection it operates on. Moreover, one could easily
mistake code such as:

```swift
let result = myString.drop(while: \.isWhitespace)
```

With a lazy filter that drops _all_ whitespace characters regardless of where 
they are in the string. Besides that, the root `trim` leads to clearer, more 
concise code, which is more aligned with other programming languages:

```swift
// Does `result` contain the input, trimmed of certain elements?
// Or does this code mutate `input` in-place and return the elements which were dropped?
let result = input.dropFromBothEnds(while: { ... })

// No such ambiguity here.
let result = input.trimming(while: { ... })
```
