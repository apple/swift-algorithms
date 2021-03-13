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

import XCTest
@testable import Algorithms

final class BreadthFirstSearchTests: XCTestCase {
	class Node {
		let element: String
		let children: [Node]
		
		init(element: String, children: [Node] = []) {
			self.element = element
			self.children = children
		}
	}
	
	/// Test an empty tree (no root)
	func testEmpty() {
		let s = BreadthFirstTreeSequence<Node>(root: nil, children: { $0.children })
		let elements = s.map({ $0.element })
		XCTAssertEqual(elements, [])
	}
	
	/// Test searching a tree with only a root
	func testRootOnly() {
		let r = Node(element: "1")
		
		let s = BreadthFirstTreeSequence<Node>(root: r, children: { $0.children })
		let elements = s.map({ $0.element })
		XCTAssertEqual(elements, ["1"])
	}
	
	/// Test searching a tree with two levels of depth
	func testShallow() {
		let r = Node(element: "1", children: [
			Node(element: "1.1"),
			Node(element: "1.2"),
		])
		
		let s = BreadthFirstTreeSequence<Node>(root: r, children: { $0.children })
		let elements = s.map({ $0.element })
		XCTAssertEqual(elements, [
			"1",
			"1.1",
			"1.2",
		])
	}
	
	/// Test searching a tree that varies from two to four levels of depth
	func testBreadthFirstSearch() {
		let r = Node(element: "1", children: [
			Node(element: "1.1", children: [
				Node(element: "1.1.1"),
				Node(element: "1.1.2"),
				Node(element: "1.1.3"),
			]),
			Node(element: "1.2", children: [
				Node(element: "1.2.1"),
				Node(element: "1.2.2"),
			]),
			Node(element: "1.3"),
			Node(element: "1.4", children: [
				Node(element: "1.4.1"),
			]),
			Node(element: "1.5", children: [
				Node(element: "1.5.1"),
				Node(element: "1.5.2", children: [
					Node(element: "1.5.1.1"),
					Node(element: "1.5.1.2"),
					Node(element: "1.5.1.3"),
				]),
				Node(element: "1.5.3"),
			]),
		])
		
		let s = BreadthFirstTreeSequence(root: r, children: { $0.children })
		let elements = s.map({ $0.element })
		XCTAssertEqual(elements, [
			"1",
			"1.1",
			"1.2",
			"1.3",
			"1.4",
			"1.5",
			"1.1.1",
			"1.1.2",
			"1.1.3",
			"1.2.1",
			"1.2.2",
			"1.4.1",
			"1.5.1",
			"1.5.2",
			"1.5.3",
			"1.5.1.1",
			"1.5.1.2",
			"1.5.1.3",
		])
	}
	
	/// Test that when traversing the tree, we don’t traverse further than
	/// necessary (e.g., when using `first(where:)`)
	func testLaziness() {
		let r = Node(element: "1", children: [
			Node(element: "1.1", children: [
				Node(element: "1.1.1"),
				Node(element: "1.1.2"),
				Node(element: "1.1.3"),
			]),
			Node(element: "1.2", children: [
				Node(element: "1.2.1"),
				Node(element: "1.2.2"),
			]),
			Node(element: "1.3"),
			Node(element: "1.4", children: [
				Node(element: "1.4.1"),
			]),
			Node(element: "1.5", children: [
				Node(element: "1.5.1"),
				Node(element: "1.5.2", children: [
					Node(element: "1.5.1.1"),
					Node(element: "1.5.1.2"),
					Node(element: "1.5.1.3"),
				]),
				Node(element: "1.5.3"),
			]),
		])
		
		var count: Int = 0
		let s = BreadthFirstTreeSequence(root: r, children: {
			count += 1
			return $0.children
		})
		
		// Find the first element at the third level of depth in the tree.
		let firstThirdLevelElement = s.first(where: {
			$0.element.filter({ $0 != "." }).count > 2
		})
		
		XCTAssertNotNil(firstThirdLevelElement)
		XCTAssertEqual(firstThirdLevelElement!.element, "1.1.1")
		// In order to get to this level of the tree, we only needed to call the
		// closure twice:
		//   1. To get the second level of items (from the root)
		//   2. To get the first batch of third level of items (from the first
		//      element at the second level)
		XCTAssertEqual(count, 2)
		
		count = 0
		// Find the fifth element at the third level of depth in the tree, which
		// requires calling the closure 3 times.
		let fifthThirdLevelElement = s.first(where: {
			$0.element == "1.2.2"
		})
		XCTAssertNotNil(fifthThirdLevelElement)
		XCTAssertEqual(fifthThirdLevelElement!.element, "1.2.2")
		// In order to get to this level of the tree, we only needed to call the
		// closure three times:
		//   1. To get the second level of items (from the root)
		//   2. To get the first batch of third level of items (from the first
		//      element at the second level)
		//   3. To get the second batch of third level of items (from the second
		//      element at the second level)
		XCTAssertEqual(count, 3)
	}
	
	/// Test the example in the documentation
	func testExample() {
		let tree = Node(element: "1", children: [
			Node(element: "2", children: [
				Node(element: "5", children: [
					Node(element: "9"),
					Node(element: "10"),
				]),
				Node(element: "6"),
			]),
			Node(element: "3", children: [
			]),
			Node(element: "4", children: [
				Node(element: "7", children: [
					Node(element: "11"),
					Node(element: "12"),
				]),
				Node(element: "8"),
			]),
		])
		
		let s = BreadthFirstTreeSequence(root: tree, children: { $0.children })
		let elements = s.map({ $0.element })
		XCTAssertEqual(elements, [
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8",
			"9",
			"10",
			"11",
			"12",
		])
	}
}
