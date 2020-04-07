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


//	https://bugs.swift.org/browse/SR-12403 
//	with upgrade of xcode 11.4 (swift 5.2), ran into this bug and had to 
//	use compiled version of script

import Foundation
import Darwin

class FileLock {
    let path: String
    let fd: Int32

    init?(path: String) {
        self.path = path
        fd = open(path, O_CREAT | O_RDWR, 0o666)
        if fd < 0 {
            return nil
        }
    }

    deinit {
        unlock()
        close(fd)
    }
}

extension FileLock: NSLocking {
    func tryLock() -> Bool {
        return flock(fd, LOCK_EX | LOCK_NB) == 0
    }

    func lock() {
        lock(timeout: 60)
    }

    func lock(timeout: TimeInterval) {
        let deadline = Date() + timeout
        var locked = tryLock()
        while Date() < deadline, !locked {
            sleep(1)
            locked = tryLock()
        }
        if !locked {
            print("error: Failed to lock \(path) after \(timeout) seconds, aborting")
            exit(1)
        }
    }

    func unlock() {
        flock(fd, LOCK_UN)
    }
}

let tempRoot = ProcessInfo.processInfo.environment["TEMP_ROOT"] ?? "/tmp"
let lock = FileLock(path: "\(tempRoot)/carthage-build-lock")!
lock.lock()

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/local/bin/carthage")
task.arguments = ["copy-frameworks"]
task.launch()
task.waitUntilExit()

lock.unlock()
exit(task.terminationStatus)
