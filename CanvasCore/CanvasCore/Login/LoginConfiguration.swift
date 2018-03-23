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

public class LoginConfiguration: NSObject, CanvasKeymasterDelegate {
    
    public init(mobileVerifyName: String, logo: UIImage, fullLogo: UIImage) {
        self.appNameForMobileVerify = mobileVerifyName
        self.logoForDomainPicker = logo
        self.fullLogoForDomainPicker = fullLogo
    }
    
  public let logFileManager: DDLogFileManagerDefault = {
    let logsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("InstructureLog")
    return DDLogFileManagerDefault(logsDirectory: logsDirectory)
  }()

  public var appNameForMobileVerify: String
  public let logoForDomainPicker: UIImage
  public let fullLogoForDomainPicker: UIImage
    
  public var backgroundViewForDomainPicker: UIView {
    let view = UIView()
    view.backgroundColor = UIColor(white: 1.0, alpha: 1)
    return view
  }

  public var logFilePath: String? {
    return logFileManager.sortedLogFilePaths.first
  }
}
