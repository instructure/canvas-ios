//
//  ErrorHandler.swift
//  Teacher
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import SoLazy

public protocol ErrorHandler {
    func handle(error: NSError, from source: UIViewController?)
}

struct ReportErrorHandler: ErrorHandler {
    func handle(error: NSError, from source: UIViewController?) {
        error.report(true, alertUserFrom: source)
    }
}
