#!/bin/bash
##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift Algorithms open source project
##
## Copyright (c) 2025 Apple Inc. and the Swift project authors
## Licensed under Apache License v2.0 with Runtime Library Exception
##
## See https://swift.org/LICENSE.txt for license information
##
##===----------------------------------------------------------------------===##

# Move to the project root
cd "$(dirname "$0")" || exit
cd ..
echo "Formatting Swift sources in $(pwd)"

# Run the format / lint commands
git ls-files -z '*.swift' | xargs -0 swift format format --parallel --in-place
git ls-files -z '*.swift' | xargs -0 swift format lint --strict --parallel
