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

/// A `Sequence` over a breadth-first traversal of a tree. It can be created
/// from any type of element and a closure that returns the child elements,
/// given a parent element.
public struct BreadthFirstTreeSequence<T> {
  /// The root of the tree, or `nil` if the tree is empty.
  public let root: T?
  
  /// A closure that returns the child elements of an element in the tree
  public let children: (T) -> [T]
  
  /// Initializes a generic breadth-first tree sequence with a given root and a
  /// closure that can get the child elements in the sequence
  /// - Parameters:
  ///   - root: The first element in the sequence, or `nil` if the sequence is
  ///   empty.
  ///   - children: A closure that returns the children of an element in the
  ///   tree
  @inlinable
  public init(root: T?, children: @escaping (T) -> [T]) {
    self.root = root
    self.children = children
  }
}

extension BreadthFirstTreeSequence: Sequence {
  /// An iterator over a `BreadthFirstTreeSequence` sequence.
  public struct Iterator: IteratorProtocol {
    /// The current level of elements currently being iterated through
    // TODO: Use an index/iterator or a double-ended queue for performance
    @usableFromInline
    internal var elements: [T]
    
    /// The items that have already been iterated through but may have children
    /// to iterate through later.
    // TODO: Use an index/iterator or a double-ended queue for performance
    @usableFromInline
    internal var subsequentLevelElements: [T]
    
    /// A closure that returns the child elements of an element in the tree
    @usableFromInline
    internal var children: (T) -> [T]
    
    @inlinable
    public mutating func next() -> T? {
      // We iterate through `elements` first. If `elements` is empty, we pull
      // the next (first) item in the `subsequentLevelElements` FIFO queue, get
      // its children and iterate through those.
      if let element = self.elements.first {
        // We have elements in `elements`. Return the first one and remove it
        // from the FIFO queue.
        self.elements.removeFirst()
        self.subsequentLevelElements.append(element)
        return element
      } else {
        if let element = self.subsequentLevelElements.first {
          // We don’t have any elements in `elements`. Grab the next element in
          // `subsequentLevelElements` and move its children into `elements`.
          self.subsequentLevelElements.removeFirst()
          let children = self.children(element)
          self.elements = children
          return self.next()
        } else {
          // We don’t have any elements left in `elements` nor
          // `subsequentLevelElements` to iterate through. We’re done iterating
          // through the whole tree.
          return nil
        }
      }
    }
    
    @usableFromInline
    internal init(root: T?, children: @escaping (T) -> [T]) {
      if let element = root {
        self.elements = [element]
      } else {
        self.elements = []
      }
      self.subsequentLevelElements = []
      
      self.children = children
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    return Iterator(root: self.root, children: self.children)
  }
}

extension BreadthFirstTreeSequence {
  /// A Boolean value indicating whether the sequence is empty.
  @inlinable
  public var isEmpty: Bool {
    return (self.root == nil)
  }
}
