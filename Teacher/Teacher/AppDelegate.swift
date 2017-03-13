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
import Keymaster
import TooLegit
import SoPretty
import TeacherKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?

    func didLogin(_ session: Session) {
        TEnv.replaceCurrentEnvironment(session: session)
        TEnv.try(in: window?.rootViewController) {
            self.window?.rootViewController = try rootLoggedInViewController()
        }
    }
    
    func didLogout(_ domainPicker: UIViewController) {
        window?.rootViewController = domainPicker
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        TEnv.replaceCurrentEnvironment(router: .teacher)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: domainPicker())
        window?.makeKeyAndVisible()
        
        Brand.teacherKit.apply(window!)
        
        
        return true
    }
    
    func domainPicker() -> SelectDomainViewController {
        let domainPicker = SelectDomainViewController.new()
        domainPicker.dataSource = LoginConfiguration()
        domainPicker.allowMultipleUsers = true
        domainPicker.useMobileVerify = true
        domainPicker.pickedSessionAction = { [weak self] session in
            DispatchQueue.main.async {
                self?.didLogin(session)
            }
        }
        
        return domainPicker
    }
}
