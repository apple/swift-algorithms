# Extending

Chain two collections end-to-end,
or repeat a collection forever or a specific number of times.    

## Overview

_Chaining_ two collections 

```swift
let letters = chain("abcd", "EFGH")
// String(letters) == "abcdEFGH"

for (num, letter) in zip((1...3).cycled(), letters) { 
    print(num, letter)
} 
// 1 a
// 2 b
// 3 c
// 1 d
// 2 E
// 3 F
// 1 G
// 2 H
```

## Topics

### Chaining Two Collections

- ``chain(_:_:)``

### Cycling a Collection

- ``Swift/Collection/cycled()``
- ``Swift/Collection/cycled(times:)``

### Supporting Types

- ``Chain2Sequence``
- ``CycledSequence``
- ``CycledTimesCollection``
