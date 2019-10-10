//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation

@dynamicCallable
public class Throttle {
    public var delay: TimeInterval
    public let queue: DispatchQueue
    private var workItem: DispatchWorkItem?

    public init(delay: Double = 0.002, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    public func dynamicallyCall(withArguments args: [() -> Void]) {
        execute(args[0])
    }

    public func execute(_ block: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: block)
        if delay == 0 {
            queue.async(execute: workItem!)
        } else {
            queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }

    public func notify(execute block: @escaping () -> Void) {
        workItem?.notify(queue: queue, execute: block)
    }
}
