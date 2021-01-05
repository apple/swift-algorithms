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
import Algorithms

final class LastIndexTests: XCTestCase {

  func testEmpty() {
    let empty = EmptyCollection<Bool>()
    XCTAssertNil(empty.lastIndexAsRange(where: { _ in true }))
    XCTAssertNil(empty.lastIndexAsRange(of: true))
  }

  func testArray() {
    let hexDigits: [Character] = Array("0123456789ABCDEF")
    XCTAssertEqual(0xF..<0x10, hexDigits.lastIndexAsRange(where: \.isLetter))
    XCTAssertEqual(0x9..<0xA,  hexDigits.lastIndexAsRange(where: \.isNumber))
    XCTAssertEqual(0xF..<0x10, hexDigits.lastIndexAsRange(of: "F"))
    XCTAssertEqual(0xE..<0xF,  hexDigits.lastIndexAsRange(of: "E"))
    XCTAssertEqual(0x9..<0xA,  hexDigits.lastIndexAsRange(of: "9"))
    XCTAssertEqual(0x1..<0x2,  hexDigits.lastIndexAsRange(of: "1"))
    XCTAssertEqual(0x0..<0x1,  hexDigits.lastIndexAsRange(of: "0"))
    XCTAssertNil(hexDigits.lastIndexAsRange(where: \.isSymbol))
    XCTAssertNil(hexDigits.lastIndexAsRange(of: "$"))
  }
}
