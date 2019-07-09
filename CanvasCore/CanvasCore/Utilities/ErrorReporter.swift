//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
