//
//  ErrorReporter.swift
//  SoLazy
//
//  Created by Layne Moseley on 10/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//
//  A simple reporting class that allows clients to specify exactly how they want to 
//  get errors reported externally

import Foundation

// The client that wishes to use the error reporter will set a block of this type on
// the shared error reporter
public typealias ErrorReporterBlock = (NSError, [String: AnyObject]?) -> ()

public class ErrorReporter {
    
    public static let sharedErrorReporter = ErrorReporter()
    
    /// The app that wishes to use this reporter *must* set this block
    private var reportBlock: ErrorReporterBlock?
    
    /// The error paramteter is an optional for ease of use
    /// This allows errors to be reported without checking for the optional
    /// nil errors will be ignored
    public func reportError(error: NSError?) {
        guard let err = error else { return }
        self.reportBlock?(err, nil)
    }
    
    public static func setErrorHandler(handler: ErrorReporterBlock) {
        ErrorReporter.sharedErrorReporter.reportBlock = handler
    }
}