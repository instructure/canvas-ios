//
//  LoginConfiguration.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import CanvasKeymaster
import CocoaLumberjack

class LoginConfiguration: NSObject, CanvasKeymasterDelegate {
    static let sharedConfiguration = LoginConfiguration()
    
    let logFileManager: DDLogFileManagerDefault = {
        let logsDirectory = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString).stringByAppendingPathComponent("InstructureLog")
        return DDLogFileManagerDefault(logsDirectory: logsDirectory)
    }()
    
    var appNameForMobileVerify: String! {
        return "iCanvas"
    }
    
    var backgroundViewForDomainPicker: UIView! {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return view
    }
    
    var logoForDomainPicker: UIImage! {
        return UIImage(named: "login_logo")
    }
    
    var logFilePath: String! {
        return logFileManager.sortedLogFilePaths()[0] as! String
    }
}