//
// Copyright (C) 2016-present Instructure, Inc.
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
