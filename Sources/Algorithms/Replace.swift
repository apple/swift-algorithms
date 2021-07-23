//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// replacingOccurrences(of:with:)
//===----------------------------------------------------------------------===//

extension RangeReplaceableCollection {
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max,
    by areEquivalent: (Element, Target.Element) throws -> Bool
  ) rethrows -> Self where Replacement.Element == Element {
    precondition(maxReplacements >= 0)
    precondition(!target.isEmpty)
    
    var index = subrange.lowerBound
    var result = Self()
    result.append(contentsOf: self[..<index])
    var numberOfReplacements = 0
    
    while numberOfReplacements != maxReplacements,
          let range = try self[index..<subrange.upperBound]
            .firstRange(of: target, by: areEquivalent)
    {
      result.append(contentsOf: self[index..<range.lowerBound])
      result.append(contentsOf: replacement)
      index = range.upperBound
      numberOfReplacements += 1
    }
    
    result.append(contentsOf: self[index...])
    return result
  }
  
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    maxReplacements: Int = .max,
    by areEquivalent: (Element, Target.Element) throws -> Bool
  ) rethrows -> Self where Replacement.Element == Element {
    try replacingOccurrences(
      of: target,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements,
      by: areEquivalent)
  }
}

extension RangeReplaceableCollection where Element: Equatable {
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    subrange: Range<Index>,
    maxReplacements: Int = .max
  ) -> Self where Target.Element == Element, Replacement.Element == Element {
    replacingOccurrences(
      of: target,
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements,
      by: ==)
  }
  
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> Self where Target.Element == Element, Replacement.Element == Element {
    replacingOccurrences(
      of: target,
      with: replacement,
      subrange: startIndex..<endIndex,
      maxReplacements: maxReplacements)
  }
}

//===----------------------------------------------------------------------===//
// lazy.replacingOccurrences(of:with:)
//===----------------------------------------------------------------------===//

extension LazyCollectionProtocol {
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    subrange: Range<Elements.Index>,
    maxReplacements: Int = .max,
    by areEquivalent: @escaping (Element, Target.Element) -> Bool
  ) -> LazyCollection<
    Chain2<
      Elements.SubSequence,
      Chain2<
        JoinedByCollection<
          SplitCollection<Elements.SubSequence, Target>,
          Replacement
        >,
        Elements.SubSequence
      >
    >
  > where Replacement.Element == Element {
    let replaced = elements[subrange].lazy.split(
      separator: target,
      maxSplits: maxReplacements,
      omittingEmptySubsequences: false,
      by: areEquivalent)
      .elements
      .joined(by: replacement)
    
    return chain(
      elements[..<subrange.lowerBound],
      chain(replaced, elements[subrange.upperBound...])
    ).lazy
  }
  
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    maxReplacements: Int = .max,
    by areEquivalent: @escaping (Element, Target.Element) -> Bool
  ) -> JoinedByCollection<
         LazyCollection<SplitCollection<Elements, Target>>, Replacement>
    where Replacement.Element == Element
  {
    split(
      separator: target,
      maxSplits: maxReplacements,
      omittingEmptySubsequences: false,
      by: areEquivalent)
      .joined(by: replacement)
  }
}

extension LazyCollectionProtocol where Element: Equatable {
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    subrange: Range<Elements.Index>,
    maxReplacements: Int = .max
  ) -> LazyCollection<
    Chain2<
      Elements.SubSequence,
      Chain2<
        JoinedByCollection<
          SplitCollection<Elements.SubSequence, Target>,
          Replacement
        >,
        Elements.SubSequence
      >
    >
  > where Target.Element == Element, Replacement.Element == Element {
    replacingOccurrences(
      of: target,
      with: replacement,
      subrange: subrange,
      maxReplacements: maxReplacements,
      by: ==)
  }
  
  @inlinable
  public func replacingOccurrences<Target: Collection, Replacement: Collection>(
    of target: Target,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) -> JoinedByCollection<
         LazyCollection<SplitCollection<Elements, Target>>, Replacement>
    where Target.Element == Element, Replacement.Element == Element
  {
    split(
      separator: target,
      maxSplits: maxReplacements,
      omittingEmptySubsequences: false)
      .joined(by: replacement)
  }
}

//===----------------------------------------------------------------------===//
// replaceOccurrences(of:with:)
//===----------------------------------------------------------------------===//

extension RangeReplaceableCollection {
  @inlinable
  public mutating func replaceOccurrences<
    Target: Collection,
    Replacement: Collection
  >(
    of target: Target,
    with replacement: Replacement,
    maxReplacements: Int = .max,
    by areEquivalent: (Element, Target.Element) throws -> Bool
  ) rethrows where Replacement.Element == Element {
    self = try replacingOccurrences(
      of: target,
      with: replacement,
      maxReplacements: maxReplacements,
      by: areEquivalent)
  }
}

extension RangeReplaceableCollection where Element: Equatable {
  @inlinable
  public mutating func replaceOccurrences<
    Target: Collection,
    Replacement: Collection
  >(
    of target: Target,
    with replacement: Replacement,
    maxReplacements: Int = .max
  ) where Target.Element == Element, Replacement.Element == Element {
    replaceOccurrences(
      of: target,
      with: replacement,
      maxReplacements: maxReplacements,
      by: ==)
  }
}
