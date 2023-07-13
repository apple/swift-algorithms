//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// merge(at:by:) / merge(subrange:at:by:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
  public mutating func merge(
    at middle: Index,
    by areInAscendingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    try merge(subrange: startIndex..<endIndex, at: middle, by: areInAscendingOrder)
  }
  
  public mutating func merge(
    subrange: Range<Index>,
    at middle: Index,
    by areInAscendingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    if subrange.lowerBound == middle || subrange.upperBound == middle { return }
    
    let lowerBound = distance(from: startIndex, to: subrange.lowerBound)
    let rangeCount = distance(from: subrange.lowerBound, to: subrange.upperBound)
    let lowerCount = distance(from: subrange.lowerBound, to: middle)
    
    // FIXME: Insertion sort for small counts?
    
    let result: Void? = try withContiguousMutableStorageIfAvailable
    { selfBuffer -> Void in
      let upperCount = rangeCount - lowerCount
      let upperBound = lowerBound + rangeCount
      let endOfLower = lowerBound + lowerCount
      
      try withUnsafeTemporaryAllocation(
        of: Element.self, capacity: Swift.min(lowerCount, upperCount)
      ) { tempBuffer in
        if lowerCount < upperCount {
          // Merge into lower section from start of tempBuffer and upper section,
          // prioritizing tempBuffer values
          
          // Move elements from lower section to temporary buffer
          _ = tempBuffer.moveInitialize(
            fromContentsOf: selfBuffer[lowerBound..<endOfLower])
          
          var firstUninitialized = selfBuffer.baseAddress! + lowerBound
          var tempSource = tempBuffer.baseAddress!
          let tempUpper = tempSource + tempBuffer.count
          var selfSource = selfBuffer.baseAddress! + endOfLower
          let selfUpper = selfBuffer.baseAddress! + upperBound
          
          func finalize() {
            if tempSource < tempUpper {
              firstUninitialized.moveInitialize(
                from: tempSource,
                count: tempUpper - tempSource)
            }
          }
          
          do {
            while tempSource < tempUpper && selfSource < selfUpper {
              if try areInAscendingOrder(selfSource.pointee, tempSource.pointee) {
                firstUninitialized.moveInitialize(from: selfSource, count: 1)
                selfSource += 1
              } else {
                firstUninitialized.moveInitialize(from: tempSource, count: 1)
                tempSource += 1
              }
              firstUninitialized += 1
            }
          } catch {
            finalize()
            throw error
          }
          
          finalize()
        } else {
          // Merge (backwards) into upper section from end of tempBuffer and lower,
          // prioritizing tempBuffer values
          _ = tempBuffer.moveInitialize(
            fromContentsOf: selfBuffer[endOfLower..<upperBound])
          
          var lastUninitialized = selfBuffer.baseAddress! + upperBound - 1
          var tempSource = (tempBuffer.baseAddress! + tempBuffer.count) - 1
          let tempLowerBound = tempBuffer.baseAddress!
          var selfSource = (selfBuffer.baseAddress! + endOfLower) - 1
          let selfLowerBound = selfBuffer.baseAddress! + lowerBound
          
          while tempSource >= tempLowerBound && selfSource >= selfLowerBound {
            // FIXME: Figure out throwing situation
            if try !areInAscendingOrder(tempSource.pointee, selfSource.pointee) {
              lastUninitialized.moveInitialize(from: tempSource, count: 1)
              if tempSource == tempLowerBound {
                break
              }
              tempSource -= 1
              assert(tempSource >= tempLowerBound)
            } else {
              lastUninitialized.moveInitialize(from: selfSource, count: 1)
              if selfSource == selfLowerBound {
                // Done moving from the lower section, but there could still
                // be elements in the temp buffer.
                
                // Note: `tempSource` points to the last element in the temp
                // buffer, not the "past the end" position, hence the +1 here:
                let tempCount = (tempSource + 1) - tempLowerBound
                selfLowerBound.moveInitialize(from: tempLowerBound, count: tempCount)
                break
              }
              selfSource -= 1
              assert(selfSource >= selfLowerBound)
            }
            lastUninitialized -= 1
            assert(lastUninitialized >= selfLowerBound)
          }
        }
      }
    }
    
    if result == nil {
      try mergeInPlace(subrange: subrange, at: middle, by: areInAscendingOrder)
    }
  }
}

extension MutableCollection where Self: BidirectionalCollection, Element: Comparable {
  public mutating func merge(at middle: Index) {
    merge(at: middle, by: <)
  }
  
  public mutating func merge(subrange: Range<Index>, at middle: Index) {
    merge(subrange: subrange, at: middle, by: <)
  }
}

//===----------------------------------------------------------------------===//
// mergeInPlace(at:by:) / mergeInPlace(subrange:at:by:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
  public mutating func mergeInPlace(
    at middle: Index,
    by areInAscendingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    try mergeInPlace(subrange: startIndex..<endIndex, at: middle, by: areInAscendingOrder)
  }
  
  public mutating func mergeInPlace(
    subrange: Range<Index>,
    at middle: Index,
    by areInAscendingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    // If either side of `middle` is empty, there's no work to do.
    if subrange.lowerBound == middle || middle == subrange.upperBound {
      return
    }
    
    let lowerCount = distance(from: subrange.lowerBound, to: middle)
    let upperCount = distance(from: middle, to: subrange.upperBound)
    // FIXME: Insertion sort for small counts?
    guard lowerCount + upperCount > 2 else {
      if try areInAscendingOrder(self[middle], self[subrange.lowerBound]) {
        swapAt(subrange.lowerBound, middle)
      }
      return
    }
    
    let lowerPivot: Index
    let upperPivot: Index

    if lowerCount < upperCount {
      // a a b b c c d e f|a b b b c d d d e e e e e f f
      //               ^                 ^
      //           lowerPivot        upperPivot
      // (lower pivot must be strictly greater than element at upper)
      // after rotation:
      // a a b b c c d|a b b b c d d/e f|d e e e e e f f
      //                             ^
      //                         newMiddle
      upperPivot = index(middle, offsetBy: upperCount / 2)
      // FIXME: Binary search instead of linear? Require random access?
      lowerPivot = try self[subrange.lowerBound..<middle].startOfSuffix(
        while: { try areInAscendingOrder(self[upperPivot], $0) })
    } else {
      // a b b b c d d d e e e e e f f|a a b b c c d e f
      //             ^                             ^
      //         lowerPivot                    upperPivot
      // (upper pivot must be first element equal or greater than lower)
      // after rotation:
      // a b b b c d|a a b b c c/d d e e e e e f f|d e f
      //                        ^
      //                    newMiddle
      lowerPivot = index(subrange.lowerBound, offsetBy: lowerCount / 2)
      // FIXME: Binary search instead of linear? Require random access?
      upperPivot = try self[middle..<subrange.upperBound].endOfPrefix(
        while: { try areInAscendingOrder($0, self[lowerPivot]) })
    }

    let newMiddle = self.rotate(subrange: lowerPivot..<upperPivot, toStartAt: middle)
    try self.mergeInPlace(
      subrange: subrange.lowerBound..<newMiddle,
      at: lowerPivot,
      by: areInAscendingOrder)
    try self.mergeInPlace(
      subrange: newMiddle..<subrange.upperBound,
      at: upperPivot,
      by: areInAscendingOrder)
  }
}

extension MutableCollection where Self: BidirectionalCollection, Element: Comparable {
  public mutating func mergeInPlace(at middle: Index) {
    mergeInPlace(at: middle, by: <)
  }
  
  public mutating func mergeInPlace(
    subrange: Range<Index>,
    at middle: Index
  ) {
    mergeInPlace(subrange: subrange, at: middle, by: <)
  }
}
