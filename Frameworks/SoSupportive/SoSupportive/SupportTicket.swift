//
//  SupportTicket.swift
//  Keytester
//
//  Created by Brandon Pluim on 6/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import DeviceKit
import TooLegit

public enum ImpactLevel: String {
    case Comment, NotUrgent, WorkaroundPossible, Blocking, Emergency, None

    public static func impacts() -> [ImpactLevel] {
        return [Comment, NotUrgent, WorkaroundPossible, Blocking, Emergency]
    }

    public static func impactFromDescription(description: String) -> ImpactLevel? {
        return impacts().filter {
            return $0.description() == description
            }.first
    }

    public func description() -> String {
        switch self {
        case .Comment:
            return "Casual question or suggestion"
        case .NotUrgent:
            return "I need help but it's not urgent"
        case .WorkaroundPossible:
            return "Something is broken but I can work around it"
        case .Blocking:
            return "I can't get things done until fixed"
        case .Emergency:
            return "Extremely critical emergency"
        case .None:
            return "Choose One"
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
    case Problem, FeatureRequest

    public func description() -> String {
        switch self {
        case .Problem:
            return "Describe your problem"
        case .FeatureRequest:
            return "What can we do better?"
        }
    }

}

public class SupportTicket {

    public let requesterName: String
    public let requesterUsername: String
    public let requesterEmail: String
    public let requesterDomain: NSURL
    public let subject: String
    public let body: String

    public let impact: ImpactLevel
    public let type: SupportTicketType
    public let logFilePath: String?

    init(requesterName: String = "Unknown User", requesterUsername: String = "Unknown User", requesterEmail: String = "unknown_user@test.com", requesterDomain: NSURL = NSURL(string: "https://canvas.instructure.com")!, subject: String = "N/A", body: String = "N/A", impact: ImpactLevel = .None, type: SupportTicketType = .FeatureRequest, logFilePath: String? = nil) {
        self.requesterName = requesterName ?? "Unknown User"
        self.requesterUsername = requesterUsername ?? "Unknown User Name"
        self.requesterEmail = requesterEmail
        self.requesterDomain = requesterDomain
        self.subject = subject
        self.body = body

        self.impact = impact
        self.type = type
        self.logFilePath = logFilePath
    }

    init(session: Session, subject: String = "N/A", body: String = "N/A", impact: ImpactLevel = .None, type: SupportTicketType = .FeatureRequest) {
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

    func dictionaryValue() -> Dictionary<String, AnyObject> {
        let dictionary = [
            "error": [
                "subject"                   : subject,
                "url"                       : requesterDomain.absoluteString,
                "email"                     : requesterEmail,
                "comments"                  : body,
                "user_percieved_severity"   : self.impact.fieldValue(),
                "http_env"                  : environmentBody()
            ]
        ]

        return dictionary
    }

    private func environmentBody() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        let domainString = requesterDomain.absoluteString

        // don't include user info if it's SFU
        if !domainString.hasSuffix("sfu.ca") {
            dictionary["User"] = requesterUsername
            dictionary["Email"] = requesterEmail
        }

        let device = Device()
        dictionary["Hostname"] = domainString
        dictionary["App Version"] = appVersionString()
        dictionary["Platform"] = device.description
        dictionary["OS Version"] = UIDevice.currentDevice().systemVersion
        dictionary["user_log"] = log()

        return dictionary
    }

    private func appVersionString() -> String {
        guard let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, appBundle = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String else {
            fatalError("")
        }
        return "\(version) (\(appBundle))"
    }

    private func log() -> String {
        let emptyLogString = "EMPTY LOG"
        guard let filePath = logFilePath, data = NSData(contentsOfFile: filePath) else { return emptyLogString }

        let logData = String(data: data, encoding: NSUTF8StringEncoding)
        guard let stringsByLine = logData?.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) else { return emptyLogString }

        var logString = "------------\nLog\n------------\n\n:"
        for lineNum in 0..<stringsByLine.count {
            if lineNum > 150 { break }

            logString.appendContentsOf(stringsByLine[lineNum])
        }

        return logString
    }

}
