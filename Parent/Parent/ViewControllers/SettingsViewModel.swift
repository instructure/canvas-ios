//
//  SettingsViewModel.swift
//  Parent
//
//  Created by Brandon Pluim on 1/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import TooLegit
import Result

class SettingsViewModel {
    var objects: [User] = []
    let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    // ---------------------------------------------
    // MARK: - Header Fields
    // ---------------------------------------------
    func fetchAvatar(completion: (Result<UIImage, NSError>)->Void) {
        // Fetch the avatar, then return it.  Simple and easy
    }
    
    func nameText() -> String {
        return session.user.name
    }
    
    func emailText() -> String {
        return session.user.email ?? ""
    }
    
    // ---------------------------------------------
    // MARK: - Observee Based Fields
    // ---------------------------------------------
    func fetchObservees(completion: Result<[User], NSError>->Void) {
//        let request: Request<[User]> = Request(auth: session.auth, method: .GET, path: "api/v1/users/self/observees", parameters: ["include": "avatar_url"], parseResponse: { json in
//            if let json = json as? [AnyObject] {
//                var users = [User]()
//                for jsonObj in json {
//                    if let user = User.fromJSON(jsonObj) {
//                        users.append(user)
//                    }
//                }
//                return Result(value: users)
//            }
//            
//            return Result(error: NSError(domain: "ConversationKit.Recipient+Requests.findRecipients", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse recipient search json."]))
//        })
//        makeRequest(request, completed: { result in
//            if let observees = result.value {
//                self.objects = observees.content
//                completion(Result(value: self.objects))
//            } else if let error = result.error {
//                completion(Result(error: error))
//            }
//        })
    }
    
}