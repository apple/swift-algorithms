import Algorithms
import XCTest

class PadTests: XCTestCase {
  func testPaddingStart() {
    XCTAssertEqual("12345".paddingStart(with: "0", toCount: 10), "0000012345")
    XCTAssertEqual("12345".paddingStart(with: "0", toCount: 5), "12345")
    XCTAssertEqual("12345".paddingStart(with: "0", toCount: 4), "12345")
    XCTAssertEqual("12345".paddingStart(with: "0", toCount: 0), "12345")
    XCTAssertEqual("12345".paddingStart(with: "0", toCount: -1), "12345")

    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingStart(with: UInt8.zero, toCount: 8),
      [0, 0, 0, 0, 0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingStart(with: UInt8.zero, toCount: 4),
      [0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingStart(with: UInt8.zero, toCount: 2),
      [0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingStart(with: UInt8.zero, toCount: 0),
      [0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingStart(with: UInt8.zero, toCount: -1),
      [0xde, 0xad, 0xbe, 0xef])
  }

  func testPadStart() {
    var str1 = "12345"
    str1.padStart(with: "0", toCount: 10)
    XCTAssertEqual(str1, "0000012345")

    var str2 = "12345"
    str2.padStart(with: "0", toCount: 5)
    XCTAssertEqual(str2, "12345")

    var str3 = "12345"
    str3.padStart(with: "0", toCount: 4)
    XCTAssertEqual(str3, "12345")

    var str4 = "12345"
    str4.padStart(with: "0", toCount: 0)
    XCTAssertEqual(str4, "12345")

    var str5 = "12345"
    str5.padStart(with: "0", toCount: -1)
    XCTAssertEqual(str5, "12345")

    var data1: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data1.padStart(with: 0, toCount: 8)
    XCTAssertEqual(data1, [0, 0, 0, 0, 0xde, 0xad, 0xbe, 0xef])

    var data2: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data2.padStart(with: 0, toCount: 4)
    XCTAssertEqual(data2, [0xde, 0xad, 0xbe, 0xef])

    var data3: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data3.padStart(with: 0, toCount: 2)
    XCTAssertEqual(data3, [0xde, 0xad, 0xbe, 0xef])

    var data4: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data4.padStart(with: 0, toCount: 0)
    XCTAssertEqual(data4, [0xde, 0xad, 0xbe, 0xef])

    var data5: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data5.padStart(with: 0, toCount: -1)
    XCTAssertEqual(data5, [0xde, 0xad, 0xbe, 0xef])
  }

  func testPaddingEnd() {
    XCTAssertEqual("12345".paddingEnd(with: "0", toCount: 10), "1234500000")
    XCTAssertEqual("12345".paddingEnd(with: "0", toCount: 5), "12345")
    XCTAssertEqual("12345".paddingEnd(with: "0", toCount: 4), "12345")
    XCTAssertEqual("12345".paddingEnd(with: "0", toCount: 0), "12345")
    XCTAssertEqual("12345".paddingEnd(with: "0", toCount: -1), "12345")

    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingEnd(with: UInt8.zero, toCount: 8),
      [0xde, 0xad, 0xbe, 0xef, 0, 0, 0, 0])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingEnd(with: UInt8.zero, toCount: 4),
      [0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingEnd(with: UInt8.zero, toCount: 2),
      [0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingEnd(with: UInt8.zero, toCount: 0),
      [0xde, 0xad, 0xbe, 0xef])
    XCTAssertEqual(
      [0xde, 0xad, 0xbe, 0xef].paddingEnd(with: UInt8.zero, toCount: -1),
      [0xde, 0xad, 0xbe, 0xef])
  }

  func testPadEnd() {
    var str1 = "12345"
    str1.padEnd(with: "0", toCount: 10)
    XCTAssertEqual(str1, "1234500000")

    var str2 = "12345"
    str2.padEnd(with: "0", toCount: 5)
    XCTAssertEqual(str2, "12345")

    var str3 = "12345"
    str3.padEnd(with: "0", toCount: 4)
    XCTAssertEqual(str3, "12345")

    var str4 = "12345"
    str4.padEnd(with: "0", toCount: 0)
    XCTAssertEqual(str4, "12345")

    var str5 = "12345"
    str5.padEnd(with: "0", toCount: -1)
    XCTAssertEqual(str5, "12345")

    var data1: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data1.padEnd(with: 0, toCount: 8)
    XCTAssertEqual(data1, [0xde, 0xad, 0xbe, 0xef, 0, 0, 0, 0])

    var data2: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data2.padEnd(with: 0, toCount: 4)
    XCTAssertEqual(data2, [0xde, 0xad, 0xbe, 0xef])

    var data3: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data3.padEnd(with: 0, toCount: 2)
    XCTAssertEqual(data3, [0xde, 0xad, 0xbe, 0xef])

    var data4: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data4.padEnd(with: 0, toCount: 0)
    XCTAssertEqual(data4, [0xde, 0xad, 0xbe, 0xef])

    var data5: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    data5.padEnd(with: 0, toCount: -1)
    XCTAssertEqual(data5, [0xde, 0xad, 0xbe, 0xef])
  }
}
