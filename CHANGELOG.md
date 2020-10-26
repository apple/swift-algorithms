# CHANGELOG

<!-- 
Add new items at the end of the relevant section under **Unreleased**.
-->

This project follows semantic versioning. While still in major version `0`,
source-stability is only guaranteed within minor versions (e.g. between
`0.0.3` and `0.0.4`). If you want to guard against potentially source-breaking
package updates, you can specify your package dependency using
`.upToNextMinor(from: "0.0.1")` as the requirement.

## [Unreleased]

### Additions

- The `sortedEndIndex(by:)` and `sortedEndIndex()` methods check when a collection stops being sorted.  The `rampedEndIndex(by:)` and `rampedEndIndex()` methods are variants that check for strict increases in rank, instead of non-decreases.
- The `sortedRange(for: by:)` and `sortedRange(for:)` methods perform a binary
  search for a value within an already-sorted collection.  To optimize time in
  some circumstances, an isolated phase of the binary-search procedure can be
  done via the `someSortedPosition(of: by:)`, `lowerSortedBound(around: by:)`,
  and `upperSortedBound(around: by:)` methods, each of which has a
  defaulted-comparison overload (`someSortedPosition(of:)`,
  `lowerSortedBound(around:)`, and `upperSortedBound(around:)`).

---

## [0.0.2] - 2020-10-23

### Changes

- The `rotate(at:)` method has been updated to `rotate(toStartAt:)`, with the
  old name deprecated.
- The `chained(with:)` method has been changed to the free function
  `chain(_:_:)`, with the old version deprecated.
- `Algorithms` now uses `RealModule` from the `swift-numerics` package for its
  cross-platform elementary functions.
- Sequence/collection wrapper types, like `Permutations` and `Indexed`, now
  have conformance to the lazy protocols, so that any following operations
  maintain their laziness.

### Fixes

- Swift Algorithms now builds under SwiftPM on Windows.
- A wide variety of errors, misspellings, and ommissions in the documentation
  and guides have been fixed. 
- Index/distance calculations for the `Product2` and `Chain` types have been
  corrected.
- Calling `stablePartition(subrange:by:)` now correctly uses the subrange's
  length instead of the whole collection.

The 0.0.2 release includes contributions from [AustinConlon], [egorzhdan],
[IanKeen], [iSame7], [karwa], [kylemacomber], [natecook1000], [nordicio],
[pmtao], [schlagelk], [stephentyrone], and [timvermeulen]. Thank you!

## [0.0.1] - 2020-10-07

- **Swift Algorithms** initial release.

---

This changelog's format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

<!-- Link references for releases -->

[Unreleased]: https://github.com/apple/swift-algorithms/compare/0.0.2...HEAD
[0.0.2]: https://github.com/apple/swift-algorithms/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/apple/swift-algorithms/releases/tag/0.0.1

<!-- Link references for pull requests -->

<!-- Link references for contributors -->

[AustinConlon]: https://github.com/apple/swift-algorithms/commits?author=AustinConlon
[egorzhdan]: https://github.com/apple/swift-algorithms/commits?author=egorzhdan
[IanKeen]: https://github.com/apple/swift-algorithms/commits?author=IanKeen
[iSame7]: https://github.com/apple/swift-algorithms/commits?author=iSame7
[karwa]: https://github.com/apple/swift-algorithms/commits?author=karwa
[kylemacomber]: https://github.com/apple/swift-algorithms/commits?author=kylemacomber
[natecook1000]: https://github.com/apple/swift-algorithms/commits?author=natecook1000
[nordicio]: https://github.com/apple/swift-algorithms/commits?author=nordicio
[pmtao]: https://github.com/apple/swift-algorithms/commits?author=pmtao
[schlagelk]: https://github.com/apple/swift-algorithms/commits?author=schlagelk
[stephentyrone]: https://github.com/apple/swift-algorithms/commits?author=stephentyrone
[timvermeulen]: https://github.com/apple/swift-algorithms/commits?author=timvermeulen
