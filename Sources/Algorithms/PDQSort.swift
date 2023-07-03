
extension Int {
  @inlinable
  internal var _log2: Int {
    Self.bitWidth - leadingZeroBitCount
  }
}

@inlinable internal var _partialInsertionSortSwapLimit: Int { 8 }

@inlinable internal var _insertionSortMaxCount: Int {
  #if INSERTION_MAX_32
  32
  #else
  20
  #endif
}

@inlinable internal var _medianOfMediansMinCount: Int { 200 }

extension MutableCollection where Self: BidirectionalCollection {
  @inlinable
  internal mutating func _partialInsertionSort(
    within range: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool {
    if range.isEmpty {
      return true
    }

    var sortedEnd = index(after: range.lowerBound)
    var swaps = 0
    
    // Continue sorting until the sorted elements cover the whole sequence.
    while sortedEnd != range.upperBound {
      var i = sortedEnd
      // Look backwards for `self[i]`'s position in the sorted sequence,
      // moving each element forward to make room.
      repeat {
        let j = index(before: i)
        
        // If `self[i]` doesn't belong before `self[j]`, we've found
        // its position.
        if try !areInIncreasingOrder(self[i], self[j]) {
          break
        }
        
        swapAt(i, j)
        i = j

        // Quit if we've completed more than the swap limit.
        swaps += 1
        if swaps > _partialInsertionSortSwapLimit { return false }
      } while i != range.lowerBound
      
      formIndex(after: &sortedEnd)
    }
    
    return true
  }
  
  /// Sorts `self[range]` according to `areInIncreasingOrder`. Stable.
  ///
  /// - Precondition: `sortedEnd != range.lowerBound`
  /// - Precondition: `elements[..<sortedEnd]` are already in order.
  @inlinable
  public
  mutating func _insertionSort(
    within range: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    if range.isEmpty {
      return
    }
    var sortedEnd = index(after: range.lowerBound)

    // Continue sorting until the sorted elements cover the whole sequence.
    while sortedEnd != range.upperBound {
      var i = sortedEnd
      #if INSERTION_TEMP
      let temp = self[i]
      #endif
      // Look backwards for `self[i]`'s position in the sorted sequence,
      // moving each element forward to make room.
      repeat {
        let j = index(before: i)
        
        // If `self[i]` doesn't belong before `self[j]`, we've found
        // its position.
        #if INSERTION_TEMP
        if try !areInIncreasingOrder(temp, self[j]) {
          break
        }
        self[j] = self[i]
        #else
        if try !areInIncreasingOrder(self[i], self[j]) {
          break
        }
        swapAt(i, j)
        #endif
        
        i = j
      } while i != range.lowerBound
      #if INSERTION_TEMP
      self[i] = temp
      #endif
      
      formIndex(after: &sortedEnd)
    }
  }
  
  @inlinable
  internal mutating func _sort2(
    _ a: Index, _ b: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    if try areInIncreasingOrder(self[b], self[a]) {
      swapAt(a, b)
    }
  }
  
  @inlinable
  internal mutating func _sort3a(
    _ a: Index, _ b: Index, _ c: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    try _sort2(a, b, by: areInIncreasingOrder)
    try _sort2(b, c, by: areInIncreasingOrder)
    try _sort2(a, b, by: areInIncreasingOrder)
  }

  /// Sorts the elements at `elements[a]`, `elements[b]`, and `elements[c]` to
  /// match the relative order of `a`, `b`, and `c`.
  @inlinable
  internal mutating func _sort3(
    _ a: Index, _ b: Index, _ c: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    // There are thirteen possible permutations for the original ordering of
    // the elements at indices `a`, `b`, and `c`. The comments in the code below
    // show the relative ordering of the three elements using a three-digit
    // number as shorthand for the position and comparative relationship of
    // each element. For example, "312" indicates that the element at `a` is the
    // largest of the three, the element at `b` is the smallest, and the element
    // at `c` is the median. This hypothetical input array has a 312 ordering for
    // `a`, `b`, and `c`:
    //
    //      [ 7, 4, 3, 9, 2, 0, 3, 7, 6, 5 ]
    //        ^              ^           ^
    //        a              b           c
    //
    // - If each of the three elements is distinct, they could be ordered as any
    //   of the permutations of 1, 2, and 3: 123, 132, 213, 231, 312, or 321.
    // - If two elements are equivalent and one is distinct, they could be
    //   ordered as any permutation of 1, 1, and 2 or 1, 2, and 2: 112, 121, 211,
    //   122, 212, or 221.
    // - If all three elements are equivalent, they are already in order: 111.
    
    switch try (areInIncreasingOrder(self[b], self[a]),
                areInIncreasingOrder(self[c], self[b])) {
    case (false, false):
      // 0 swaps: 123, 112, 122, 111
      break

    case (true, true):
      // 1 swap: 321
      // swap(a, c): 312->123
      swapAt(a, c)

    case (true, false):
      // 1 swap: 213, 212 --- 2 swaps: 312, 211
      // swap(a, b): 213->123, 212->122, 312->132, 211->121
      swapAt(a, b)

      if try areInIncreasingOrder(self[c], self[b]) {
        // 132 (started as 312), 121 (started as 211)
        // swap(b, c): 132->123, 121->112
        swapAt(b, c)
      }

    case (false, true):
      // 1 swap: 132, 121 --- 2 swaps: 231, 221
      // swap(b, c): 132->123, 121->112, 231->213, 221->212
      swapAt(b, c)

      if try areInIncreasingOrder(self[b], self[a]) {
        // 213 (started as 231), 212 (started as 221)
        // swap(a, b): 213->123, 212->122
        swapAt(a, b)
      }
    }
  }
}

extension MutableCollection where Self: RandomAccessCollection {
  @inlinable
  internal mutating func _siftDown(
    _ idx: Index,
    within range: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    var idx = idx
    var countToIndex = distance(from: range.lowerBound, to: idx)
    var countFromIndex = distance(from: idx, to: range.upperBound)
    // Check if left child is within bounds. If not, stop iterating, because
    // there are no children of the given node in the heap.
    while countToIndex + 1 < countFromIndex {
      let left = index(idx, offsetBy: countToIndex + 1)
      var largest = idx
      if try areInIncreasingOrder(self[largest], self[left]) {
        largest = left
      }
      // Check if right child is also within bounds before trying to examine it.
      if countToIndex + 2 < countFromIndex {
        let right = index(after: left)
        if try areInIncreasingOrder(self[largest], self[right]) {
          largest = right
        }
      }
      // If a child is bigger than the current node, swap them and continue
      // sifting down.
      if largest != idx {
        swapAt(idx, largest)
        idx = largest
        countToIndex = distance(from: range.lowerBound, to: idx)
        countFromIndex = distance(from: idx, to: range.upperBound)
      } else {
        break
      }
    }
  }

  @inlinable
  internal mutating func _heapify(
    within range: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    // Here we build a heap starting from the lowest nodes and moving to the
    // root. On every step we sift down the current node to obey the max-heap
    // property:
    //   parent >= max(leftChild, rightChild)
    //
    // We skip the rightmost half of the array, because these nodes don't have
    // any children.
    let root = range.lowerBound
    let half = distance(from: range.lowerBound, to: range.upperBound) / 2
    var node = index(root, offsetBy: half)

    while node != root {
      formIndex(before: &node)
      try _siftDown(node, within: range, by: areInIncreasingOrder)
    }
  }

  @inlinable
  internal mutating func _heapSort(
    within range: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    var hi = range.upperBound
    let lo = range.lowerBound
    try _heapify(within: range, by: areInIncreasingOrder)
    formIndex(before: &hi)
    while hi != lo {
      swapAt(lo, hi)
      try _siftDown(lo, within: lo..<hi, by: areInIncreasingOrder)
      formIndex(before: &hi)
    }
  }
}

extension MutableCollection where Self: BidirectionalCollection {
  @inlinable
  public // testing
  mutating func _partitionLeft(
    subrange: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index {
    assert(distance(from: subrange.lowerBound, to: subrange.upperBound) >= 2)
    
    var (low, high) = (subrange.lowerBound, subrange.upperBound)
    let pivot = self[subrange.lowerBound]
    
    // Search from end for last element equal to or less than pivot.
    repeat {
      formIndex(before: &high)
      // Don't need a separate `high > low` check, since self[low] == pivot,
      // which is a terminating condition based on comparison above.
    } while try areInIncreasingOrder(pivot, self[high])
    
    // Search from beginning for first element greater than pivot.
    if high == index(before: subrange.upperBound) {
      while low < high {
        formIndex(after: &low)
        guard try !areInIncreasingOrder(pivot, self[low]) else {
          break
        }
      }
    } else {
      repeat {
        formIndex(after: &low)
      } while try !areInIncreasingOrder(pivot, self[low])
    }
    
    // Swap remaining elements as needed.
    while low < high {
      swapAt(low, high)
      repeat {
        formIndex(before: &high)
      } while try areInIncreasingOrder(pivot, self[high])
      repeat {
        formIndex(after: &low)
      } while try !areInIncreasingOrder(pivot, self[low])
    }
    
    // Move pivot to end of lower partition and return its position.
    swapAt(subrange.lowerBound, high)
    return high
  }
  
  @inlinable
  public // testing
  mutating func _partitionRight(
    subrange: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> (Index, alreadyPartitioned: Bool) {
    assert(distance(from: subrange.lowerBound, to: subrange.upperBound) >= 2)
    
    var (low, high) = (subrange.lowerBound, subrange.upperBound)
    let pivot = self[subrange.lowerBound]
    
    // Search from start for first element greater than or equal to pivot.
    repeat {
      formIndex(after: &low)
    } while try areInIncreasingOrder(self[low], pivot)
    
    // Search from end for last element less than pivot.
    if low == index(after: subrange.lowerBound) {
      while low < high {
        formIndex(before: &high)
        guard try !areInIncreasingOrder(self[high], pivot) else {
          break
        }
      }
    } else {
      repeat {
        formIndex(before: &high)
      } while try !areInIncreasingOrder(self[high], pivot)
    }

    let noSwapsRequired = low >= high
    
    // Swap remaining elements as needed.
    while low < high {
      swapAt(low, high)
      repeat {
        formIndex(after: &low)
      } while try areInIncreasingOrder(self[low], pivot)
      repeat {
        formIndex(before: &high)
      } while try !areInIncreasingOrder(self[high], pivot)
    }
    
    // Move pivot to start of upper partition and return its position.
    let result = index(before: low)
    swapAt(subrange.lowerBound, result)
    return (result, noSwapsRequired)
  }
}

extension MutableCollection where Self: RandomAccessCollection {
  @inlinable
  public // testing
  mutating func _preparePivot(
    subrange: Range<Index>,
    count: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    let low = subrange.lowerBound
    let high = index(before: subrange.upperBound)
    let mid = index(low, offsetBy: count / 2)

    if count > _medianOfMediansMinCount {
      // Sort three "letter groups" of elements:
      //    [A1, B1, C1, ..., A2, B2, C2, ..., C3, B3, A3]
      let low2 = index(after: low)
      let high2 = index(before: high)
      let midLo = index(before: mid)
      let midHi = index(after: mid)
      try _sort3(low, midLo, high, by: areInIncreasingOrder)
      try _sort3(low2, mid, high2, by: areInIncreasingOrder)
      try _sort3(
        index(after: low2), midHi, index(before: high2),
        by: areInIncreasingOrder)
      // After sorting, each lettered group of elements is sorted, so the
      // middle three elements are the three medians. Sort those three.
      try _sort3(midLo, mid, midHi, by: areInIncreasingOrder)
      
      // The median of medians is the pivot; move it to the front.
      swapAt(low, mid)
    } else {
      // Note the order of index parameters; the smallest element will be at `mid`,
      // the middle element at `low`, and the largest element at `high`:
      try _sort3(mid, low, high, by: areInIncreasingOrder)
    }
  }

  @inlinable
  internal mutating func _shuffleElements(subrange: Range<Index>, count: Int) {
    guard count > _insertionSortMaxCount else { return }
    
    var low = subrange.lowerBound
    var lowQuarter = index(low, offsetBy: count / 4)
    var high = index(before: subrange.upperBound)
    var highQuarter = index(high, offsetBy: -count / 4)
    swapAt(low, lowQuarter)
    swapAt(high, highQuarter)
    
    if count > _insertionSortMaxCount {
      for _ in 0..<2 {
        formIndex(after: &low)
        formIndex(before: &lowQuarter)
        formIndex(before: &high)
        formIndex(after: &highQuarter)
        swapAt(low, lowQuarter)
        swapAt(high, highQuarter)
      }
    }
  }

  @inlinable
  internal mutating func _pdqSortImpl(
    subrange: Range<Index>,
    count: Int,
    isLeftmost: Bool,
    remainingBadPartitions: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    guard count > _insertionSortMaxCount else {
      try _insertionSort(within: subrange, by: areInIncreasingOrder)
      return
    }
    
    try _preparePivot(subrange: subrange, count: count, by: areInIncreasingOrder)
    
    if !isLeftmost {
      let predecessor = index(before: subrange.lowerBound)
      if try !areInIncreasingOrder(self[predecessor], self[subrange.lowerBound]) {
        let newLow = try _partitionLeft(subrange: subrange, by: areInIncreasingOrder)
        try _pdqSortImpl(
          subrange: newLow..<subrange.upperBound,
          count: distance(from: newLow, to: subrange.upperBound),
          isLeftmost: false,
          remainingBadPartitions: remainingBadPartitions,
          by: areInIncreasingOrder)
        return
      }
    }
    
    let (pivot, alreadyPartitioned) = try _partitionRight(
      subrange: subrange, by: areInIncreasingOrder)
    
    let startOfUpper = index(after: pivot)
    let lowerCount = distance(from: subrange.lowerBound, to: pivot)
    let upperCount = count - lowerCount - 1
    let minPartitionSize = count / 8
    let isBadPartition = lowerCount < minPartitionSize || upperCount < minPartitionSize
    
    var remainingBadPartitions = remainingBadPartitions
    if isBadPartition {
      // If we've had too many bad partitions, fall back to heap sort.
      remainingBadPartitions -= 1
      guard remainingBadPartitions > 0 else {
        try _heapSort(within: subrange, by: areInIncreasingOrder)
        return
      }
      
      // Try shuffling elements within the partition to decrease chance of poor
      // pivot selection.
      _shuffleElements(subrange: subrange.lowerBound..<pivot, count: lowerCount)
      _shuffleElements(subrange: startOfUpper..<subrange.upperBound, count: upperCount)
    } else {
      // If there were no swaps required, use insertion sort to scan for already
      // sorted partitions, including some minor fix-ups.
      if alreadyPartitioned {
        if try _partialInsertionSort(within: subrange.lowerBound..<pivot, by: areInIncreasingOrder)
            && _partialInsertionSort(within: startOfUpper..<subrange.upperBound, by: areInIncreasingOrder) {
          return
        }
      }
    }
    
    try _pdqSortImpl(
      subrange: subrange.lowerBound..<pivot,
      count: lowerCount,
      isLeftmost: isLeftmost,
      remainingBadPartitions: remainingBadPartitions,
      by: areInIncreasingOrder)
    try _pdqSortImpl(
      subrange: startOfUpper..<subrange.upperBound,
      count: upperCount,
      isLeftmost: false,
      remainingBadPartitions: remainingBadPartitions,
      by: areInIncreasingOrder)
  }
  
  @inlinable
  public mutating func sortUnstable(
    subrange: Range<Index>,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    let count = distance(from: subrange.lowerBound, to: subrange.upperBound)
    try _pdqSortImpl(
      subrange: subrange,
      count: count,
      isLeftmost: true,
      remainingBadPartitions: count._log2,
      by: areInIncreasingOrder)
  }
  
  @inlinable
  public mutating func sortUnstable(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    try sortUnstable(subrange: startIndex..<endIndex, by: areInIncreasingOrder)
  }
}

extension MutableCollection where Self: RandomAccessCollection, Element: Comparable {
  @inlinable
  public mutating func sortUnstable(subrange: Range<Index>) {
    sortUnstable(subrange: subrange, by: <)
  }

  @inlinable
  public mutating func sortUnstable() {
    sortUnstable(by: <)
  }
}
