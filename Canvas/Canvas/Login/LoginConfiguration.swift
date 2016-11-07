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