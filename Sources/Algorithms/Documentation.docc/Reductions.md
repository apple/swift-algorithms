# Reductions

Find the incremental values of a sequence "reduce" operation.

## Overview

Call one of the `reductions` methods when you want the result of a `reduce` operation along with all of its intermediate values: 

```swift
let exclusiveRunningTotal = (1...5).reductions(0, +)
print(exclusiveRunningTotal)
// prints [0, 1, 3, 6, 10, 15]

let inclusiveRunningTotal = (1...5).reductions(+)
print(inclusiveRunningTotal)
// prints [1, 3, 6, 10, 15]
```

## Topics

- ``Swift/Sequence/reductions(_:)``
- ``Swift/Sequence/reductions(_:_:)``
- ``Swift/Sequence/reductions(into:_:)``
- ``Swift/LazySequenceProtocol/reductions(_:)``
- ``Swift/LazySequenceProtocol/reductions(_:_:)``
- ``Swift/LazySequenceProtocol/reductions(into:_:)``

### Supporting Types

- ``InclusiveReductionsSequence``
- ``ExclusiveReductionsSequence``

### Deprecated Methods

- <doc:DeprecatedScan>
