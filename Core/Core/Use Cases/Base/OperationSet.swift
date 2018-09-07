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

public class OperationSet: AsyncOperation {
    private let internalQueue = OperationQueue()
    private lazy var finishOperation = {
        return BlockOperation { [weak self] in
            self?.finish()
        }
    }()

    public init(operations: [Operation] = []) {
        super.init()
        internalQueue.isSuspended = true
        internalQueue.addOperation(finishOperation)
        addOperations(operations)
    }

    override public func execute() {
        internalQueue.isSuspended = false
    }

    func addOperation(_ operation: Operation) {
        finishOperation.addDependency(operation)
        internalQueue.addOperation(operation)
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
    }

    func addOperations(_ operations: [Operation]) {
        for operation in operations {
            addOperation(operation)
        }
    }

    public func addSequence(_ operations: [Operation]) {
        var operations = operations
        addOperations(operations)
        while operations.count > 1 {
            if let operation = operations.popLast(), let dependency = operations.last {
                operation.addDependency(dependency)
            }
        }
    }
}
