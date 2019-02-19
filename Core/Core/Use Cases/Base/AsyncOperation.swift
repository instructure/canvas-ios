//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

open class AsyncOperation: Operation {
    public var errors: [Error] = []

    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case cancelled = "isCancelled"
    }

    var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
            if newValue == .cancelled {
                willChangeValue(forKey: State.finished.rawValue)
            }
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
            if state == .cancelled {
                didChangeValue(forKey: State.finished.rawValue)
            }
        }
    }

    override open var isAsynchronous: Bool {
        return true
    }

    override open var isExecuting: Bool {
        return state == .executing
    }

    override open var isFinished: Bool {
        return state == .finished || state == .cancelled
    }

    override open func start() {
        guard !isCancelled else {
            state = .cancelled
            return
        }
        state = .executing
        execute()
    }

    public func execute() {
        fatalError("unimplemented \(#function)")
    }

    public func finish() {
        state = .finished
    }

    func addError(_ error: Error?) {
        if let error = error {
            errors.append(error)
        }
    }
}
