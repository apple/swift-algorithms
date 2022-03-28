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

import XCTest
import Algorithms

final class RecursiveMapTests: XCTestCase {
    
    func testRecursiveMap() {
        
        struct Dir: Hashable {
            
            var id: UUID = UUID()
            
            var parent: UUID?
            
            var name: String
            
        }
        
        struct Path: Hashable {
            
            var id: UUID
            
            var path: String
            
        }
        
        var list: [Dir] = []
        list.append(Dir(name: "root"))
        list.append(Dir(parent: list[0].id, name: "images"))
        list.append(Dir(parent: list[0].id, name: "Users"))
        list.append(Dir(parent: list[2].id, name: "Susan"))
        list.append(Dir(parent: list[3].id, name: "Desktop"))
        list.append(Dir(parent: list[1].id, name: "test.jpg"))
        
        let answer = [
            Path(id: list[0].id, path: "/root"),
            Path(id: list[1].id, path: "/root/images"),
            Path(id: list[2].id, path: "/root/Users"),
            Path(id: list[5].id, path: "/root/images/test.jpg"),
            Path(id: list[3].id, path: "/root/Users/Susan"),
            Path(id: list[4].id, path: "/root/Users/Susan/Desktop"),
        ]
        
        let result = list.lazy.compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .recursiveMap { parent in list.lazy.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        XCTAssertEqualSequences(result, answer)
    }
    
    func testRecursiveMap2() {
        
        struct Node {
            
            var id: Int
            
            var children: [Node] = []
        }
        
        let tree = [
            Node(id: 1, children: [
                Node(id: 3),
                Node(id: 4, children: [
                    Node(id: 6),
                ]),
                Node(id: 5),
            ]),
            Node(id: 2),
        ]
        
        let nodes = tree.recursiveMap { $0.children }
        
        XCTAssertEqualSequences(nodes.map { $0.id }, 1...6)
    }
    
}
