import Algorithms
import XCTest

class PaddedTests: XCTestCase {
  func testPrefixPaddedForwardCollection() {
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 10), "0000012345")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 6), "012345")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 5), "12345")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 4), "12345")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 0), "12345")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: -1), "12345")
  }

  func testPrefixPaddedBiDirectionalCollection() {
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 10).reversed(), "5432100000")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 6).reversed(), "543210")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 5).reversed(), "54321")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 4).reversed(), "54321")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: 0).reversed(), "54321")
    XCTAssertEqualSequences("12345".prefixPadded(with: "0", toCount: -1).reversed(), "54321")
  }

  func testPrefixPaddedIndexTraversals() {
    validateIndexTraversals(
      [0xde, 0xad, 0xbe, 0xef].prefixPadded(with: UInt8.zero, toCount: 16),
      [0xde, 0xad, 0xbe, 0xef].prefixPadded(with: UInt8.zero, toCount: 4),
      [0xde, 0xad, 0xbe, 0xef].prefixPadded(with: UInt8.zero, toCount: 2),
      [0xde, 0xad, 0xbe, 0xef].prefixPadded(with: UInt8.zero, toCount: 0),
      [0xde, 0xad, 0xbe, 0xef].prefixPadded(with: UInt8.zero, toCount: -1)
    )

    validateIndexTraversals(
      "12345".prefixPadded(with: "0", toCount: 10),
      "12345".prefixPadded(with: "0", toCount: 5),
      "12345".prefixPadded(with: "0", toCount: 4),
      "12345".prefixPadded(with: "0", toCount: 0),
      "12345".prefixPadded(with: "0", toCount: -1)
    )
  }

  func testPrefixPaddedIndexOffsetAcrossBoundary() {
    let c = "12345".prefixPadded(with: "0", toCount: 10)

    do {
      let i = c.index(c.startIndex, offsetBy: 5, limitedBy: c.startIndex)
      XCTAssertNil(i)
    }

    do {
      let i = c.index(c.startIndex, offsetBy: 6)
      let j = c.index(i, offsetBy: -2)
      XCTAssertEqual(c[j], "0")
    }

    do {
      let i = c.index(c.startIndex, offsetBy: 5)
      let j = c.index(i, offsetBy: -1, limitedBy: i)
      XCTAssertNil(j)
    }
  }

  func testSuffixPaddedForwardCollection() {
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 10), "1234500000")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 6), "123450")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 5), "12345")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 4), "12345")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 0), "12345")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: -1), "12345")
  }

  func testSuffixPaddedBiDirectionalCollection() {
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 10).reversed(), "0000054321")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 6).reversed(), "054321")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 5).reversed(), "54321")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 4).reversed(), "54321")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: 0).reversed(), "54321")
    XCTAssertEqualSequences("12345".suffixPadded(with: "0", toCount: -1).reversed(), "54321")
  }

  func testSuffixPaddedIndexTraversals() {
    validateIndexTraversals(
      [0xde, 0xad, 0xbe, 0xef].suffixPadded(with: UInt8.zero, toCount: 16),
      [0xde, 0xad, 0xbe, 0xef].suffixPadded(with: UInt8.zero, toCount: 4),
      [0xde, 0xad, 0xbe, 0xef].suffixPadded(with: UInt8.zero, toCount: 2),
      [0xde, 0xad, 0xbe, 0xef].suffixPadded(with: UInt8.zero, toCount: 0),
      [0xde, 0xad, 0xbe, 0xef].suffixPadded(with: UInt8.zero, toCount: -1)
    )

    validateIndexTraversals(
      "12345".suffixPadded(with: "0", toCount: 10),
      "12345".suffixPadded(with: "0", toCount: 5),
      "12345".suffixPadded(with: "0", toCount: 4),
      "12345".suffixPadded(with: "0", toCount: 0),
      "12345".suffixPadded(with: "0", toCount: -1)
    )
  }

  func testSuffixPaddedIndexOffsetAcrossBoundary() {
    let c = "12345".suffixPadded(with: "0", toCount: 10)

    do {
      let i = c.index(c.startIndex, offsetBy: 5, limitedBy: c.startIndex)
      XCTAssertNil(i)
    }

    do {
      let i = c.index(c.startIndex, offsetBy: 6)
      let j = c.index(i, offsetBy: -2)
      XCTAssertEqual(c[j], "5")
    }

    do {
      let i = c.index(c.startIndex, offsetBy: 5)
      let j = c.index(i, offsetBy: -1, limitedBy: i)
      XCTAssertNil(j)
    }
  }
}
