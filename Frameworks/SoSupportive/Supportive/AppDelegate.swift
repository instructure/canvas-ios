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
    
    

import UIKit
import SoSupportive
import TooLegit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)


        let user = SessionUser(id: "1",
                               name: "Brandon",
                               loginID: "bt",
                               sortableName: "Pluim, Brandon",
                               avatarURL: URL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
        let session = Session(baseURL: URL(string: "https://mobiledev.instructure.com")!,
                       user: user,
                       token: "1~JC6sxZ9lNeVJloM6TOhW3pKZUsHIVTA8qwyC3wFNs67ZFsKeaYnkOTtNfdpAeuWN")

        let vc = SupportTicketViewController.new(session, type: .featureRequest)
        let navController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navController

        window?.makeKeyAndVisible()
        return true
    }

}

