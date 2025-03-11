//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

// https://canvas.instructure.com/doc/api/error_reports.html#method.errors.create
struct PostErrorReportRequest: APIRequestable {
    typealias Response = APINoContent

    struct Body: Encodable {
        let error: Error
    }
    struct Error: Encodable {
        let category: String?
        let code: Int?
        let comments: String?
        let description: String?
        let email: String?
        let http_env: [String: String]?
        let message: String?
        let subject: String
        let url: URL?
        let user_perceived_severity: Severity?
    }
    enum Severity: String, CaseIterable, Equatable, Encodable {
        case just_a_comment, not_urgent, workaround_possible, blocks_what_i_need_to_do, extreme_critical_emergency
    }

    let method = APIMethod.post
    let path = "error_reports"
    let body: Body?

    init(error: NSError? = nil, email: String? = nil, subject: String, impact: Int, comments: String = "") {
        var comments = comments + "\n\n\n-----------------------------------"
        var email = email
        var http_env: [String: String] = [:]
        var subject = subject
        if let session = AppEnvironment.shared.currentSession {
            email = email ?? session.userEmail
            subject = "\(subject) [\(session.baseURL.absoluteString)]"
            if Locale.current.region?.identifier != "CA" {
                comments += "\nUser: \(session.userID)"
                comments += "\nEmail: \(email ?? "")"
                http_env["User"] = session.userID
                http_env["Email"] = session.userEmail
            }
            comments += "\nHostname: \(session.baseURL.absoluteString)"
            http_env["Hostname"] = session.baseURL.absoluteString
        }
        let version = String(format: "%@ (%@)",
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        )
        comments += "\nApp Version: \(version)"
        comments += "\nPlatform: \(UIDevice.current.model)"
        comments += "\nOS Version: \(UIDevice.current.systemVersion)"
        http_env["App Version"] = version
        http_env["Platform"] = UIDevice.current.model
        http_env["OS Version"] = UIDevice.current.systemVersion

        if let info = error?.userInfo {
            for (key, value) in info {
                if let string = value as? String, key != NSLocalizedDescriptionKey, key != NSLocalizedFailureReasonErrorKey {
                    comments += "\n\(key): \(string)"
                    http_env[key] = string
                }
            }
        }

        let enabledFeatures = ExperimentalFeature.allCases.filter({ $0.isEnabled })
        if enabledFeatures.count > 0 {
            comments += "\nEnabled Features: "
            comments += enabledFeatures.map({ $0.rawValue }).joined(separator: ", ")
        }

        comments += "\n-----------------------------------"

        body = Body(error: Error(
            category: error?.domain,
            code: error?.code,
            comments: comments,
            description: error?.localizedFailureReason != nil ? error?.localizedDescription : nil,
            email: email,
            http_env: http_env,
            message: error?.localizedFailureReason ?? error?.localizedDescription,
            subject: subject,
            url: AppEnvironment.shared.currentSession?.baseURL,
            user_perceived_severity: impact >= 0 && impact < Severity.allCases.count
                ? Severity.allCases[impact]
                : .just_a_comment
        ))
    }
}
