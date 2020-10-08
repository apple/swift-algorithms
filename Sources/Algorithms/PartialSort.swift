import Foundation

private final class Heap<T> {

    typealias Comparator = (T,T) -> Bool

    private var elements: [T]
    private let priority: Comparator

    init<S: Sequence>(elements: S, priority: @escaping Comparator) where S.Element == T {
        self.priority = priority
        self.elements = Array(elements)
        if elements.isEmpty == false {
            for i in stride(from: (count / 2) - 1, to: -1, by: -1) {
                siftDown(i)
            }
        }
    }

    private func leftChildIndex(of index: Int) -> Int {
        return (2 * index) + 1
    }

    private func rightChild(of index: Int) -> Int {
        return (2 * index) + 2
    }

    private func parentIndex(of index: Int) -> Int {
        return (index - 1) / 2
    }

    private func isHigherPriority(_ a: Int, _ b: Int) -> Bool {
        return priority(elements[a], elements[b])
    }

    private func highestPriorityIndex(of index: Int) -> Int {
        let left = highestPriorityIndex(of: index, and: leftChildIndex(of: index))
        let right = highestPriorityIndex(of: index, and: rightChild(of: index))
        return highestPriorityIndex(of: left, and: right)
    }

    private func highestPriorityIndex(of parent: Int, and child: Int) -> Int {
        guard child < elements.count else {
            return parent
        }
        guard isHigherPriority(child, parent) else {
            return parent
        }
        return child
    }

    func dequeue() -> T? {
        guard elements.count > 0 else {
            return nil
        }
        elements.swapAt(0, elements.count - 1)
        let element = elements.popLast()
        siftDown(0)
        return element
    }

    private func siftDown(_ i: Int) {
        let indexToSwap = highestPriorityIndex(of: i)
        guard indexToSwap != i else {
            return
        }
        elements.swapAt(indexToSwap, i)
        siftDown(indexToSwap)
    }
}

extension Collection {
    func partiallySorted(_ count: Int, by: @escaping (Element, Element) -> Bool) -> [Element] {
        assert(count >= 0 && count < self.count, "Are you crazy?")
        let heap = Heap<Element>(elements: self, priority: by)
        return [Element](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0..<count {
              buffer[i] = heap.dequeue()!
            }
            initializedCount = count
        }
    }
}

extension Collection where Element: Comparable {
    func partiallySorted(_ count: Int) -> [Element] {
      return partiallySorted(count, by: <)
    }
}
