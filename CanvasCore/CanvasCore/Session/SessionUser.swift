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
