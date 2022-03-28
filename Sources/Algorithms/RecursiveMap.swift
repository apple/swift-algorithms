//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
    /// Returns a sequence containing the original sequence followed by recursive mapped sequence.
    ///
    /// ```
    /// struct Node {
    ///     var id: Int
    ///     var children: [Node] = []
    /// }
    /// let tree = [
    ///     Node(id: 1, children: [
    ///         Node(id: 3),
    ///         Node(id: 4, children: [
    ///             Node(id: 6),
    ///         ]),
    ///         Node(id: 5),
    ///     ]),
    ///     Node(id: 2),
    /// ]
    /// for node in tree.recursiveMap({ $0.children }) {
    ///     print(node.id)
    /// }
    /// // 1
    /// // 2
    /// // 3
    /// // 4
    /// // 5
    /// // 6
    /// ```
    ///
    /// - Parameters:
    ///   - transform: A closure that map the element to new sequence.
    /// - Returns: A sequence of the original sequence followed by recursive mapped sequence.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func recursiveMap<S>(_ transform: @escaping (Element) -> S) -> RecursiveMapSequence<Self, S> {
        return RecursiveMapSequence(self, transform)
    }
}

public struct RecursiveMapSequence<Base: Sequence, Transformed: Sequence>: Sequence where Base.Element == Transformed.Element {
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let transform: (Base.Element) -> Transformed
    
    @inlinable
    init(_ base: Base, _ transform: @escaping (Base.Element) -> Transformed) {
        self.base = base
        self.transform = transform
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(base, transform)
    }
}

extension RecursiveMapSequence {
    
    public struct Iterator: IteratorProtocol {
        
        @usableFromInline
        var base: Base.Iterator?
        
        @usableFromInline
        var mapped: ArraySlice<Transformed> = []
        
        @usableFromInline
        var mapped_iterator: Transformed.Iterator?
        
        @usableFromInline
        var transform: (Base.Element) -> Transformed
        
        @inlinable
        init(_ base: Base, _ transform: @escaping (Base.Element) -> Transformed) {
            self.base = base.makeIterator()
            self.transform = transform
        }
        
        @inlinable
        public mutating func next() -> Base.Element? {
            
            if self.base != nil {
                
                if let element = self.base?.next() {
                    mapped.append(transform(element))
                    return element
                }
                
                self.base = nil
                self.mapped_iterator = mapped.popFirst()?.makeIterator()
            }
            
            while self.mapped_iterator != nil {
                
                if let element = self.mapped_iterator?.next() {
                    mapped.append(transform(element))
                    return element
                }
                
                self.mapped_iterator = mapped.popFirst()?.makeIterator()
            }
            
            return nil
        }
    }
}

extension RecursiveMapSequence: LazySequenceProtocol where Base: LazySequenceProtocol { }
