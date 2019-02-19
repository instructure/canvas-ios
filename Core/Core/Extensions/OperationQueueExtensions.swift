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

public typealias ErrorHandler = (Error?) -> Void

extension OperationQueue {
    public func addOperationWithErrorHandling(_ group: OperationSet, sendErrorsTo view: ErrorViewController?) {
        addOperation(group, errorHandler: { error in
            if let error = error {
                view?.showError(error)
            }
        })
    }

    public func addOperation(_ operation: AsyncOperation, errorHandler: ErrorHandler? = nil) {
        let errorOperation = BlockOperation { [weak operation] in
            errorHandler?(operation?.errors.first)
        }
        errorOperation.addDependency(operation)
        addOperations([operation, errorOperation], waitUntilFinished: false)
    }
}
