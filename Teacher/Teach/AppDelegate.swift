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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var navigator: Navigator?

    func handleError(_ error: NSError) {
        if let vc = window?.rootViewController  {
            error.presentAlertFromViewController(vc)
        }
    }

    func didLogin(_ session: Session) {
        do {
            navigator = try Navigator(session: session)
            window?.rootViewController = navigator?.rootViewController
        } catch let e as NSError {
            handleError(e)
        }
    }

    func didLogout(_ domainPicker: UIViewController) {
        window?.rootViewController = domainPicker
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: domainPicker())
        window?.makeKeyAndVisible()

        TeachBranding.apply(window!)

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

let TeachBranding = Brand(
    tintColor:UIColor(hue: 350/360.0, saturation: 1.0, brightness: 0.76, alpha: 0),
    secondaryTintColor: UIColor(hue: 205/360.0, saturation: 0.92, brightness: 0.82, alpha: 1.0),
    navBarTintColor: UIColor(hue: 229/360.0, saturation: 1.0, brightness: 0.24, alpha: 1.0),
    navForegroundColor: .white,
    tabBarTintColor: .white,
    tabsForegroundColor: UIColor(hue: 229/360.0, saturation: 1.0, brightness: 0.24, alpha: 1.0),
    logo: UIImage(named: "logo")!)
