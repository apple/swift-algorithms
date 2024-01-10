//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020-2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// PartitionMapResult2
//===----------------------------------------------------------------------===//

// `PartitionMapResult` Types are needed because of current generic limitations.
// It is separated into public struct and internal enum. Such design has benefits
// in comparison to plain enum:
// - prevent its usage as a general purpose Either / OneOf Type – there are no
// public properties which makes it useless outside
// the library anywhere except with `partitionMap()` function.
// - allows to rename `first`, `second` and `third` without source breakage .
// If something more suitable will be found then old static initializers can be
// deprecated with introducing new ones.

public struct PartitionMapResult2<A, B> {
  @usableFromInline
  internal let oneOf: _PartitionMapResult2<A, B>
  
  @usableFromInline
  internal init(oneOf: _PartitionMapResult2<A, B>) { self.oneOf = oneOf }
  
  @inlinable
  public static func first(_ value: A) -> Self {
    Self(oneOf: .first(value))
  }
  
  @inlinable
  public static func second(_ value: B) -> Self {
    Self(oneOf: .second(value))
  }
}

@usableFromInline
internal enum _PartitionMapResult2<A, B> {
  case first(A)
  case second(B)
}

//===----------------------------------------------------------------------===//
// PartitionMapResult3
//===----------------------------------------------------------------------===//

public struct PartitionMapResult3<A, B, C> {
  @usableFromInline
  internal let oneOf: _PartitionMapResult3<A, B, C>
  
  @usableFromInline
  internal init(oneOf: _PartitionMapResult3<A, B, C>) {
    self.oneOf = oneOf
  }
  
  @inlinable
  public static func first(_ value: A) -> Self {
    Self(oneOf: .first(value))
  }
  
  @inlinable
  public static func second(_ value: B) -> Self {
    Self(oneOf: .second(value))
  }
  
  @inlinable
  public static func third(_ value: C) -> Self {
    Self(oneOf: .third(value))
  }
}

@usableFromInline
internal enum _PartitionMapResult3<A, B, C> {
  case first(A)
  case second(B)
  case third(C)
}

//===----------------------------------------------------------------------===//
// partitionMap()
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Allows to separate elements into distinct groups while applying a transformation to each element
  ///
  /// This method do the same as `partitioned(by:)` but with an added map step baked in for
  /// ergonomic reasons.
  ///
  /// The `partitionMap` applies the given closure to each element of the collection and divides the
  /// results into two groups based on the transformation's output.
  /// The closure returns a `PartitionMapResult`, which indicates whether the result should be
  /// included in the first group or in the second.
  ///
  /// In this example, `partitionMap(_:)` is used to separate an array  of `any Error` elements into
  /// two arrays while also transforming the type from
  /// `any Error` to `URLSessionError` for the first group.
  /// ```
  /// func handle(errors: [any Error]) {
  ///   let (recoverableErrors, unrecoverableErrors) = errors
  ///     .partitionMap { error -> PartitionMapResult2<URLSessionError, any Error> in
  ///       switch error {
  ///       case let urlError as URLSessionError: return .first(urlError)
  ///       default: return .second(error)
  ///       }
  ///     }
  ///   // recoverableErrors Type is Array<URLSessionError>
  ///   // unrecoverableErrors Type is Array<any Error>
  ///  }
  /// ```
  ///
  /// - Parameters:
  ///   - transform: A mapping closure. `transform` accepts an element of this sequence as its
  ///   parameter and returns a `PartitionMapResult` with a transformed value, representing
  ///   membership to either the first or second group with elements of the original or of a different type.
  ///
  /// - Returns: Two arrays, with elements from the first or second group appropriately.
  ///
  /// - Throws: Rethrows any errors produced by the `transform` closure.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func partitionMap<A, B>(
    _ transform: (Element) throws -> PartitionMapResult2<A, B>
  ) rethrows -> ([A], [B]) {
    var groupA: [A] = []
    var groupB: [B] = []
    
    for element in self {
      switch try transform(element).oneOf {
      case .first(let a): groupA.append(a)
      case .second(let b): groupB.append(b)
      }
    }
    
    return (groupA, groupB)
  }
  
  /// Allows to separate elements into distinct groups while applying a transformation to each element
  ///
  /// This method do the same as `partitioned(by:)` but with an added map step baked in for
  /// ergonomic reasons.
  ///
  /// The `partitionMap` applies the given closure to each element of the collection and divides the
  /// results into distinct groups based on the transformation's output.
  /// The closure returns a `PartitionMapResult`, which indicates whether the result should be
  /// included in the first , second or third group.
  ///
  /// In this example, `partitionMap(_:)` is used to separate an array  of `any Error` elements into
  /// three arrays while also transforming the type from
  /// `any Error` to `URLSessionError` for the first and second groups.
  /// ```
  /// func handle(errors: [any Error]) {
  ///   let (recoverableErrors, unrecoverableErrors, unknownErrors) = errors
  ///     .partitionMap { error -> PartitionMapResult3<URLSessionError, any Error> in
  ///       switch error {
  ///       case let urlError as URLSessionError:
  ///         return recoverableURLErrorCodes.contains(urlError.code) ? .first(urlError) : .second(urlError)
  ///       default:
  ///         return .third(error)
  ///       }
  ///     }
  ///   // recoverableErrors Type is Array<URLSessionError>
  ///   // unrecoverableErrors Type is Array<URLSessionError>
  ///   // unknownErrors Type is Array<any Error>
  ///  }
  /// ```
  ///
  /// - Parameters:
  ///   - transform: A mapping closure. `transform` accepts an element of this sequence as its
  ///   parameter and returns a `PartitionMapResult` with a transformed value, representing
  ///   membership to either first, second or third group with elements of the original or of a different type.
  ///
  /// - Returns: Three arrays, with elements from the first, second or third group appropriately.
  ///
  /// - Throws: Rethrows any errors produced by the `transform` closure.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func partitionMap<A, B, C>(
    _ transform: (Element) throws -> PartitionMapResult3<A, B, C>
  ) rethrows -> ([A], [B], [C]) {
    var groupA: [A] = []
    var groupB: [B] = []
    var groupC: [C] = []
    
    for element in self {
      switch try transform(element).oneOf {
      case .first(let a): groupA.append(a)
      case .second(let b): groupB.append(b)
      case .third(let c): groupC.append(c)
      }
    }
    
    return (groupA, groupB, groupC)
  }
}
