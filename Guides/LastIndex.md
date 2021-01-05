# LastIndex

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/LastIndex.swift) |
  [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/LastIndexTests.swift)]

The `lastIndexAsRange(where:)` and `lastIndexAsRange(of:)` methods return an optional range,
containing the last index of a matching element in the bidirectional collection.

The range's upper bound can then be used to form another half-open range.

```swift
let hexDigits: [Character] = Array("0123456789ABCDEF")

hexDigits.lastIndexAsRange(where: \.isLetter)  //-> 0xF..<0x10
hexDigits.lastIndexAsRange(where: \.isNumber)  //-> 0x9..<0xA
hexDigits.lastIndexAsRange(where: \.isSymbol)  //-> nil
hexDigits.lastIndexAsRange(of: "F")            //-> 0xF..<0x10
hexDigits.lastIndexAsRange(of: "9")            //-> 0x9..<0xA
hexDigits.lastIndexAsRange(of: "$")            //-> nil

if let range = hexDigits.lastIndexAsRange(where: \.isNumber) {
  let digits = hexDigits[..<range.upperBound]
  digits.allSatisfy(\.isNumber)  //-> true
}
```
