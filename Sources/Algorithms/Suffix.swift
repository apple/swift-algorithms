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
// Suffix(while:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  @inlinable
  public __consuming func Suffix(while predicate: (Element) throws -> Bool
  ) rethrows -> [Element] {
   var result = ContiguousArray<Element>()
   self.reverse()
    for element in self {
      guard try predicate(element) else {
        break
      }
      result.append(element)
    }
    result.reverse()
    return Array(result)
  }
}
