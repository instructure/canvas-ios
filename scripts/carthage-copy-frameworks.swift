#!/usr/bin/xcrun --sdk macosx swift

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
