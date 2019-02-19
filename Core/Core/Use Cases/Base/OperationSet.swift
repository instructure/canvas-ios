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

open class OperationSet: AsyncOperation {
    private let internalQueue = OperationQueue()
    private lazy var finishOperation = {
        return BlockOperation { [weak self] in
            self?.finish()
        }
    }()

    public init(operations: [Operation] = []) {
        super.init()
        internalQueue.isSuspended = true
        addOperations(operations)
        internalQueue.addOperation(finishOperation)
    }

    public init(sequence: [Operation]) {
        super.init()
        addSequence(sequence)
    }

    override public func execute() {
        internalQueue.isSuspended = false
    }

    public func addOperation(_ operation: Operation) {
        finishOperation.addDependency(operation)
        if let async = operation as? AsyncOperation {
            let trackErrors = BlockOperation { [weak self, weak async] in
                if let errors = async?.errors {
                    for error in errors {
                        self?.addError(error)
                    }
                }
            }
            trackErrors.addDependency(operation)
            internalQueue.addOperation(trackErrors)
        }
        internalQueue.addOperation(operation)
    }

    public func addOperations(_ operations: [Operation]) {
        for operation in operations {
            addOperation(operation)
        }
    }

    public func addSequence(_ operations: [Operation]) {
        for (i, operation) in operations.enumerated() {
            guard i > 0 else { continue }
            operation.addDependency(operations[i - 1])
        }
        addOperations(operations)
    }
}
