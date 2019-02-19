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

import Foundation
import SafariServices

public class LTITools {

    let env: AppEnvironment
    let context: Context
    let id: String?
    let url: URL?
    let launchType: GetSessionlessLaunchURLRequest.LaunchType?
    let assignmentID: String?
    let moduleItemID: String?

    public init(env: AppEnvironment, context: Context, id: String?, url: URL?, launchType: GetSessionlessLaunchURLRequest.LaunchType?, assignmentID: String?, moduleItemID: String?) {
        self.env = env
        self.context = context
        self.id = id
        self.url = url
        self.launchType = launchType
        self.assignmentID = assignmentID
        self.moduleItemID = moduleItemID
    }

    public func presentToolInSFSafariViewController(from: UIViewController, animated: Bool, completionHandler: ((Bool) -> Void)?) {
        getSessionlessLaunchURL { (url) in
            DispatchQueue.main.async {
                guard let url = url else {
                    completionHandler?(false)
                    return
                }
                from.present(SFSafariViewController(url: url), animated: true, completion: {
                    completionHandler?(true)
                })
            }
        }
    }

    func getSessionlessLaunchURL(completionBlock: @escaping (URL?) -> Void) {
        let getSessionlessLaunchURL = GetSessionlessLaunchURL(api: env.api, context: context, id: id, url: url, launchType: launchType, assignmentID: assignmentID, moduleItemID: moduleItemID)
        getSessionlessLaunchURL.completionBlock = { [weak getSessionlessLaunchURL] in
            guard let op = getSessionlessLaunchURL, let url = op.response?.url else {
                completionBlock(nil)
                return
            }
            if !op.errors.isEmpty {
                completionBlock(nil)
                return
            }
            completionBlock(url)
        }

        env.queue.addOperation(getSessionlessLaunchURL)
    }
}
