By submitting a pull request, you represent that you have the right to license
your contribution to Apple and the community, and agree by submitting the patch
that your contributions are licensed under the [Swift
license](https://swift.org/LICENSE.txt).

---

Before submitting the pull request, please make sure you have tested your
changes and that they follow the Swift project [guidelines for contributing
code](https://swift.org/contributing/#contributing-code).

---

For benchmarking of particular algorithms, please use the 

`algorithms-benchmark` executable target. For convenience, this target 

already imports `Algorithms`.

Example usage:

`$ swift run -c release algorithms-benchmark run <name-of-results-file> --cycles 5`

`$ swift run -c release algorithms-benchmark render <name-of-results-file> <name-of-chart-file>.png`

