//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

// The client that wishes to use the error reporter will set a block of this type on
// the shared error reporter
public typealias ErrorReporterBlock = (NSError, [String: AnyObject]?) -> ()

open class ErrorReporter {
    
    open static let sharedErrorReporter = ErrorReporter()
    
    /// The app that wishes to use this reporter *must* set this block
    fileprivate var reportBlock: ErrorReporterBlock?
    
    /// The error paramteter is an optional for ease of use
    /// This allows errors to be reported without checking for the optional
    /// nil errors will be ignored
    open func reportError(_ error: NSError?) {
        guard let err = error else { return }
        self.reportBlock?(err, nil)
    }
    
    open static func setErrorHandler(_ handler: @escaping ErrorReporterBlock) {
        ErrorReporter.sharedErrorReporter.reportBlock = handler
    }
}
