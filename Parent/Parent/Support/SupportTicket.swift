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
    
    

import UIKit

import DeviceKit

import CanvasCore

public enum ImpactLevel: String {
    case Comment, NotUrgent, WorkaroundPossible, Blocking, Emergency, None

    public static func impacts() -> [ImpactLevel] {
        return [Comment, NotUrgent, WorkaroundPossible, Blocking, Emergency]
    }

    public static func impactFromDescription(_ description: String) -> ImpactLevel? {
        return impacts().filter {
            return $0.description() == description
            }.first
    }

    public func description() -> String {
        switch self {
        case .Comment:
            return NSLocalizedString("Casual question or suggestion", tableName: "Localizable", bundle: .parent, value: "", comment: "Cancel the question/suggestion form")
        case .NotUrgent:
            return NSLocalizedString("I need help but it's not urgent", tableName: "Localizable", bundle: .parent, value: "", comment: "Status level for issue being reported")
        case .WorkaroundPossible:
            return NSLocalizedString("Something is broken but I can work around it", tableName: "Localizable", bundle: .parent, value: "", comment: "Status level for issue being reported")
        case .Blocking:
            return NSLocalizedString("I can't get things done until fixed", tableName: "Localizable", bundle: .parent, value: "", comment: "Status level for issue being reported")
        case .Emergency:
            return NSLocalizedString("Extremely critical emergency", tableName: "Localizable", bundle: .parent, value: "", comment: "Status level for issue being reported")
        case .None:
            return NSLocalizedString("Choose One", tableName: "Localizable", bundle: .parent, value: "", comment: "title for status selection field")
        }
    }

    public func fieldValue() -> String {
        switch self {
        case .Comment:
            return "just_a_comment"
        case .NotUrgent:
            return "not_urgent"
        case .WorkaroundPossible:
            return "workaround_possible"
        case .Blocking:
            return "blocks_what_i_need_to_do"
        case .Emergency:
            return "extreme_critical_emergency"
        case .None:
            return ""
        }
    }
}

public enum SupportTicketType {
    case problem, featureRequest

    public func description() -> String {
        switch self {
        case .problem:
            return NSLocalizedString("Describe your problem", tableName: "Localizable", bundle: .parent, value: "", comment: "Title for field")
        case .featureRequest:
            return NSLocalizedString("What can we do better?", tableName: "Localizable", bundle: .parent, value: "", comment: "Title for field")
        }
    }

}

open class SupportTicket {

    open let requesterName: String
    open let requesterUsername: String
    open let requesterEmail: String
    open let requesterDomain: URL
    open let subject: String
    open let body: String

    open let impact: ImpactLevel
    open let type: SupportTicketType
    open let logFilePath: String?

    //intentionally not localizing this area since this is what support will see and our support staff is only expected to read English
    init(requesterName: String = "Unknown User", requesterUsername: String = "Unknown User", requesterEmail: String = "unknown_user@test.com", requesterDomain: URL = URL(string: "https://canvas.instructure.com")!, subject: String = "N/A", body: String = "N/A", impact: ImpactLevel = .None, type: SupportTicketType = .featureRequest, logFilePath: String? = nil) {
        self.requesterName = requesterName
        self.requesterUsername = requesterUsername
        self.requesterEmail = requesterEmail
        self.requesterDomain = requesterDomain
        self.subject = subject
        self.body = body

        self.impact = impact
        self.type = type
        self.logFilePath = logFilePath
    }

    init(session: Session, subject: String = "N/A", body: String = "N/A", impact: ImpactLevel = .None, type: SupportTicketType = .featureRequest) {
        self.requesterName = session.user.sortableName ?? "Unknown User"
        self.requesterUsername = session.user.loginID ?? "Unknown User Name"
        self.requesterEmail = session.user.email ?? "unknown_user@test.com"
        self.requesterDomain = session.baseURL
        self.subject = subject
        self.body = body

        self.impact = impact
        self.type = type
        self.logFilePath = session.logFilePath()?.absoluteString
    }

    func dictionaryValue() -> [String: Any] {
        return [
            "error": [
                "subject"                   : subject,
                "url"                       : requesterDomain.absoluteString,
                "email"                     : requesterEmail,
                "comments"                  : body,
                "user_percieved_severity"   : self.impact.fieldValue(),
                "http_env"                  : environmentBody()
            ]
        ]
    }

    fileprivate func environmentBody() -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        let domainString = requesterDomain.absoluteString

        if Secrets.featureEnabled(.protectedUserInformation, domain: domainString) == false {
            dictionary["User"] = requesterUsername
            dictionary["Email"] = requesterEmail
        }

        let device = Device()
        dictionary["Hostname"] = domainString
        dictionary["App Version"] = appVersionString()
        dictionary["Platform"] = device.description
        dictionary["OS Version"] = UIDevice.current.systemVersion
        dictionary["user_log"] = log()

        return dictionary
    }

    fileprivate func appVersionString() -> String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let appBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
            fatalError("")
        }
        return "\(version) (\(appBundle))"
    }

    fileprivate func log() -> String {
        let emptyLogString = "EMPTY LOG"
        guard let filePath = logFilePath, let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return emptyLogString }

        let logData = String(data: data, encoding: String.Encoding.utf8)
        guard let stringsByLine = logData?.components(separatedBy: CharacterSet.newlines) else { return emptyLogString }

        var logString = "------------\nLog\n------------\n\n:"
        for lineNum in 0..<stringsByLine.count {
            if lineNum > 150 { break }

            logString.append(stringsByLine[lineNum])
        }

        return logString
    }

}
