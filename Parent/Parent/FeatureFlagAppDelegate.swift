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

import UIKit
import CanvasCore

protocol AppDelegateProtocol: UIApplicationDelegate {
    var window: UIWindow? { get set }
}

@UIApplicationMain
class FeatureFlagAppDelegate: UIResponder, AppDelegateProtocol {
    var realAppDelegate: AppDelegateProtocol!
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if realAppDelegate == nil {
            #if DEBUG
            realAppDelegate = ParentAppDelegate()
            #else
            realAppDelegate = AppDelegate()
            #endif

            realAppDelegate.window = window
        }
        
        UIApplication.shared.delegate = realAppDelegate
        return realAppDelegate.application!(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
