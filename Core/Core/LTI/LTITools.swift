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

    public init(
        env: AppEnvironment = .shared,
        context: Context = ContextModel(.account, id: "self"),
        id: String? = nil,
        url: URL? = nil,
        launchType: GetSessionlessLaunchURLRequest.LaunchType? = nil,
        assignmentID: String? = nil,
        moduleItemID: String? = nil
    ) {
        self.env = env
        self.context = context
        self.id = id
        self.url = url
        self.launchType = launchType
        self.assignmentID = assignmentID
        self.moduleItemID = moduleItemID
    }

    public convenience init?(env: AppEnvironment = .shared, link: URL?) {
        guard
            let retrieve = link, retrieve.host == env.api.baseURL.host,
            retrieve.path.hasSuffix("/external_tools/retrieve"),
            let query = URLComponents.parse(retrieve).queryItems,
            let value = query.first(where: { $0.name == "url" })?.value,
            let url = URL(string: value)
        else { return nil }
        self.init(env: env, url: url)
    }

    public func presentToolInSFSafariViewController(from: UIViewController, animated: Bool, completionHandler: ((Bool) -> Void)? = nil) {
        getSessionlessLaunchURL { (url) in
            guard let url = url else {
                completionHandler?(false)
                return
            }
            from.present(SFSafariViewController(url: url), animated: true, completion: {
                completionHandler?(true)
            })
        }
    }

    public func getSessionlessLaunchURL(completionBlock: @escaping (URL?) -> Void) {
        let request = GetSessionlessLaunchURLRequest(context: context, id: id, url: url, assignmentID: assignmentID, moduleItemID: moduleItemID, launchType: launchType)
        env.api.makeRequest(request) { response, _, _ in
            DispatchQueue.main.async { completionBlock(response?.url) }
        }
    }
}
