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
    /// Returns a sequence containing the original sequence and the recursive mapped sequence.
    /// The order of ouput elements affects by the traversal option.
    ///
    /// ```
    /// struct Node {
    ///     var id: Int
    ///     var children: [Node] = []
    /// }
    /// let tree = [
    ///     Node(id: 1, children: [
    ///         Node(id: 2),
    ///         Node(id: 3, children: [
    ///             Node(id: 4),
    ///         ]),
    ///         Node(id: 5),
    ///     ]),
    ///     Node(id: 6),
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
    ///   - option: Traversal option. This option affects the element order of the output sequence. default depth-first.
    ///   - transform: A closure that map the element to new sequence.
    /// - Returns: A sequence of the original sequence followed by recursive mapped sequence.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func recursiveMap<S>(
        option: RecursiveMapSequence<Self, S>.TraversalOption = .depthFirst,
        _ transform: @escaping (Element) -> S
    ) -> RecursiveMapSequence<Self, S> {
        return RecursiveMapSequence(self, option, transform)
    }
}

/// A sequence containing the original sequence and the recursive mapped sequence.
/// The order of ouput elements affects by the traversal option.
public struct RecursiveMapSequence<Base: Sequence, Transformed: Sequence>: Sequence where Base.Element == Transformed.Element {
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let option: TraversalOption
    
    @usableFromInline
    let transform: (Base.Element) -> Transformed
    
    @inlinable
    init(
        _ base: Base,
        _ option: TraversalOption,
        _ transform: @escaping (Base.Element) -> Transformed
    ) {
        self.base = base
        self.option = option
        self.transform = transform
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(base, option, transform)
    }
}

extension RecursiveMapSequence {
    
    /// Traversal option. This option affects the element order of the output sequence.
    public enum TraversalOption {
        
        /// The algorithm will go down first and produce the resulting path.
        case depthFirst
        
        /// The algorithm will go through the previous sequence first and chaining all the occurring sequences.
        case breadthFirst
        
    }
    
    public struct Iterator: IteratorProtocol {
        
        @usableFromInline
        var base: Base.Iterator?
        
        @usableFromInline
        let option: TraversalOption
        
        @usableFromInline
        var mapped: ArraySlice<Transformed.Iterator> = []
        
        @usableFromInline
        var mapped_iterator: Transformed.Iterator?
        
        @usableFromInline
        let transform: (Base.Element) -> Transformed
        
        @inlinable
        init(
            _ base: Base,
            _ option: TraversalOption,
            _ transform: @escaping (Base.Element) -> Transformed
        ) {
            self.base = base.makeIterator()
            self.option = option
            self.transform = transform
        }
        
        @inlinable
        public mutating func next() -> Base.Element? {
            
            switch option {
                
            case .depthFirst:
                
                while self.mapped_iterator != nil {
                    
                    if let element = self.mapped_iterator!.next() {
                        mapped.append(self.mapped_iterator!)
                        self.mapped_iterator = transform(element).makeIterator()
                        return element
                    }
                    
                    self.mapped_iterator = mapped.popLast()
                }
                
                if self.base != nil {
                    
                    if let element = self.base!.next() {
                        self.mapped_iterator = transform(element).makeIterator()
                        return element
                    }
                    
                    self.base = nil
                }
                
                return nil
                
            case .breadthFirst:
                
                if self.base != nil {
                    
                    if let element = self.base!.next() {
                        mapped.append(transform(element).makeIterator())
                        return element
                    }
                    
                    self.base = nil
                    self.mapped_iterator = mapped.popFirst()
                }
                
                while self.mapped_iterator != nil {
                    
                    if let element = self.mapped_iterator!.next() {
                        mapped.append(transform(element).makeIterator())
                        return element
                    }
                    
                    self.mapped_iterator = mapped.popFirst()
                }
                
                return nil
            }
        }
    }
}

extension RecursiveMapSequence: LazySequenceProtocol where Base: LazySequenceProtocol { }
