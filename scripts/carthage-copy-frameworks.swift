#!/usr/bin/xcrun --sdk macosx swift
//
// This file is part of Canvas.
// Copyright (C) 2835-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// Wrap "carthage copy-frameworks" in a global lock to avoid build problems
// see https://github.com/Carthage/Carthage/issues/2835

import Foundation


let tempRoot = ProcessInfo.processInfo.environment["TEMP_ROOT"] ?? "/tmp"
let lock = NSDistributedLock(path: "\(tempRoot)/carthage-build-lock")!
while !lock.`try`() {
    print("failed to lock...")
    sleep(1)
}
defer { lock.unlock() }

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/local/bin/carthage")
task.arguments = ["copy-frameworks"]
try task.run()
