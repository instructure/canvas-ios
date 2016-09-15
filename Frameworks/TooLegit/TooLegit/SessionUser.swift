//
//  User.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 6/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import SoLazy
import Kingfisher

// this is in `AuthKit` so the `Session` can have a `currentUser`
public class SessionUser: NSObject {
    public let id: String
    public let loginID: String?
    public let name: String
    public let sortableName: String?
    public let email: String?
    public let avatarURL: NSURL?
    
    public init(id: String, name: String, loginID: String? = nil, sortableName: String? = nil, email: String? = nil, avatarURL: NSURL? = nil) {
        self.id = id
        self.loginID = loginID
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.sortableName = sortableName
    }

    public func getAvatarImage(completion: (image: UIImage?, error: NSError?)->Void) {
        guard let url = avatarURL else { completion(image: nil, error: NSError(subdomain: "TooLegit", description: NSLocalizedString("User has no valid avatar image url", comment: "Error message if we can't pull the avatar image"))); return }
        KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            completion(image: image, error: error)
        }
    }
}


// MARK: JSON

extension SessionUser {
    public class func fromJSON(json: AnyObject?) -> SessionUser? {
        if let
            data = json as? [String: AnyObject],
            id = data["id"] as? String,
            name = data["name"] as? String {
                let sortableName = data["sortable_name"] as? String
                let loginID = data["login_id"] as? String
                let avatarURL = (data["avatar_url"] as? String).flatMap { NSURL(string: $0) }
                let email = data["primary_email"] as? String // Optional
                
                return SessionUser(id: id, name: name, loginID: loginID, sortableName: sortableName, email: email, avatarURL: avatarURL)
        }
        return nil
    }

    public func JSONDictionary() -> [String : AnyObject] {
        var dictionary = [String : AnyObject]()
        dictionary["avatar_url"] = avatarURL?.absoluteString ?? ""
        dictionary["id"] = id
        dictionary["login_id"] = loginID
        dictionary["name"] = name
        dictionary["primary_email"] = email
        dictionary["sortable_name"] = sortableName
        return dictionary
    }
}