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

@available(macOS 12.0, *)
extension Collection {
  public func parallelMap<T>(
    parallelism requestedParallelism: Int? = nil,
    _ transform: @escaping (Element) async throws -> T) async throws -> [T]
  {
    let defaultParallelism = 2
    let parallelism = requestedParallelism ?? defaultParallelism

    let count = self.count
    let buffer = UnsafeMutableBufferPointer<T>.allocate(capacity: count)
    defer { buffer.deallocate() }
    
    return try await withThrowingTaskGroup(of: (Int, T).self) { group in
      var current = self.startIndex
      var submitted = 0

      func submitNext() async throws {
        group.async { [submitted, i = current] in
          let value = try await transform(self[i])
          return (submitted, value)
        }
        submitted += 1
        formIndex(after: &current)
      }

      // Submit initial tasks.
      for _ in 0..<Swift.min(parallelism, count) {
        try await submitNext()
      }

      // Store transformed elements in the buffer, submitting a new transform
      // as each one completes.
      while let (index, result) = try await group.next() {
        (buffer.baseAddress! + index).initialize(to: result)

        // If the task is cancelled, we stop submitting new transformations,
        // but don't exit yet. We need to complete all the outstanding work
        // so that we have a contiguous region of the buffer to deinitialize.
        if !Task.isCancelled && current < endIndex {
          try await submitNext()
        }
      }
      
      // Handle mid-stream cancellation here.
      if Task.isCancelled {
        buffer.baseAddress!.deinitialize(count: submitted)
        throw CancellationError()
      }

      precondition(submitted == buffer.count)
      return Array(buffer)
    }
  }
  
  public func parallelFirstIndex(
    parallelism requestedParallelism: Int? = nil,
    where predicate: @escaping (Element) async throws -> Bool) async throws -> Index?
  {
    let defaultParallelism = 2
    let parallelism = requestedParallelism ?? defaultParallelism
    var found: Index?
    
    return try await withThrowingTaskGroup(of: Index?.self) { group in
      var current = self.startIndex

      func submitNext() async throws {
        group.async { [i = current] in
          try await predicate(self[i]) ? i : nil
        }
        formIndex(after: &current)
      }

      // Submit initial tasks.
      for _ in 0..<Swift.min(parallelism, count) {
        try await submitNext()
      }

      // Capture results until a success is found.
      while case let .some(index) = try await group.next() {
        if index != nil {
          found = index
          break
        }
        if Task.isCancelled { return nil }
        if current < endIndex {
          try await submitNext()
        }
      }
      
      // Capture outstanding results, looking for an earlier index that may
      // have finished after the first success.
      while case let .some(index) = try await group.next() {
        if let index = index, index < found! {
          found = index
        }
        if Task.isCancelled { return nil }
      }
      
      return found
    }
  }
}
