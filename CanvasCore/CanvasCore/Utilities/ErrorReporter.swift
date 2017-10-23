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
    
    

import UIKit

// Error that occurred, and the reporting view controller
public typealias ErrorReporterBlock = (NSError, UIViewController?) -> ()

public class ErrorReporter {
    
    private static let sharedErrorReporter = ErrorReporter()
    
    /// The app that wishes to use this reporter *must* set this block
    private var reportBlock: ErrorReporterBlock?
    
    /// The error paramteter is an optional for ease of use
    /// This allows errors to be reported without checking for the optional
    /// nil errors will be ignored
    public static func reportError(_ error: NSError?, from reportingViewController: UIViewController? = nil) {
        guard let err = error else { return }
        sharedErrorReporter.reportBlock?(err, reportingViewController)
    }
    
    public static func setErrorHandler(_ handler: @escaping ErrorReporterBlock) {
        sharedErrorReporter.reportBlock = handler
    }
}
