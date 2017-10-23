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
    
    

import Foundation

import Kingfisher

// this is in `AuthKit` so the `Session` can have a `currentUser`
open class SessionUser: NSObject {
    open let id: String
    open let loginID: String?
    open let name: String
    open let sortableName: String?
    open let email: String?
    open let avatarURL: URL?
    
    public init(id: String, name: String, loginID: String? = nil, sortableName: String? = nil, email: String? = nil, avatarURL: URL? = nil) {
        self.id = id
        self.loginID = loginID
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.sortableName = sortableName
    }

    open func getAvatarImage(_ completion: @escaping (UIImage?, NSError?)->Void) {
        guard let url = avatarURL else { completion(nil, NSError(subdomain: "TooLegit", description: NSLocalizedString("User has no valid avatar image url", tableName: "Localizable", bundle: .core, value: "", comment: "Error message if we can't pull the avatar image"))); return }
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            completion(image, error)
        }
    }
}


// MARK: JSON

extension SessionUser {
    public class func fromJSON(_ json: Any?) -> SessionUser? {
        if let
            data = json as? [String: AnyObject],
            let id = data["id"] as? String,
            let name = data["name"] as? String {
                let sortableName = data["sortable_name"] as? String
                let loginID = data["login_id"] as? String
                let avatarURL = (data["avatar_url"] as? String).flatMap { URL(string: $0) }
                let email = data["primary_email"] as? String // Optional
                
                return SessionUser(id: id, name: name, loginID: loginID, sortableName: sortableName, email: email, avatarURL: avatarURL)
        }
        return nil
    }

    public func JSONDictionary() -> [String : Any] {
        var dictionary = [String : Any]()
        dictionary["avatar_url"] = avatarURL?.absoluteString ?? ""
        dictionary["id"] = id
        dictionary["login_id"] = loginID
        dictionary["name"] = name
        dictionary["primary_email"] = email
        dictionary["sortable_name"] = sortableName
        return dictionary
    }
}
