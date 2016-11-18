//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

@testable import Canvas
import TechDebt
import Nimble
import SoAutomated
import TooLegit
import CanvasKeymaster
@testable import SoEdventurous
import Result
import SoPersistent

let ignoreRouteAction: (UIViewController, NSURL) -> Void = { _ in }

private class CurrentBundle {}
let currentBundle = NSBundle(forClass: CurrentBundle.self)

func login(credentials: Credentials = .user1) -> Session {
    logoutEverybody()
    let user = User(credentials: credentials)
    let client = MockClient(user: user)
    FXKeychain.sharedCanvasKeychain().addClient(client)
    var session: Session!
    var disposable: Disposable?
    waitUntil(timeout: 2) { done in
        disposable = Session.loginSignalProducer.startWithResult {
            session = $0.value!
            done()
        }
    }
    disposable?.dispose()
    return session
}

private func logoutEverybody() {
    FXKeychain.sharedCanvasKeychain().clearKeychain()
    let fileManager = NSFileManager.defaultManager()
    guard let libURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first,
        docURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            fatalError("There were no user library search paths")
    }

    for dirURL in [libURL, docURL] {
        let files = try! fileManager.contentsOfDirectoryAtURL(dirURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)
        for file in files {
            let _ = try? fileManager.removeItemAtURL(file)
        }
    } 
}

func embedInNavigationController(viewController: UIViewController) -> UINavigationController {
    let nav = MockNavigationController()
    nav.viewControllers = [viewController]
    return nav
}

class MockNavigationController: UINavigationController {
    var _topViewController: UIViewController?

    override var topViewController: UIViewController? {
        return _topViewController
    }

    override func pushViewController(viewController: UIViewController, animated: Bool) {
        _topViewController = (viewController as? CBISplitViewController)?.master ?? viewController
    }
}

extension ManagedFactory where Self: NSManagedObject {
    static func build(options: FactoryOptions = [:], customize: (Self) -> Void = { _ in }) -> Self {
        return build(inSession: currentSession, options: options, customize: customize)
    }
}
