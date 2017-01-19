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
import QuizKit
import TooLegit
import DoNotShipThis


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    let defaultSession = Session.art
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)

        let courseID = "968776"
        let quizID = "3357679"
        let baseURL = defaultSession.baseURL
        let url = baseURL/api/v1/"courses"/courseID/"quizzes"/quizID
        let v = QuizIntroViewController(session: defaultSession, quizURL: url, quizID: quizID)
        
        window?.rootViewController = UINavigationController(rootViewController:v)
        window?.makeKeyAndVisible()
        
        return true
    }
}
