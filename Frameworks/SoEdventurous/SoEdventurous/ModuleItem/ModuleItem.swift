//
//  ModuleItem.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

public class ModuleItem: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var moduleID: String
    @NSManaged internal (set) public var position: Int
    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var indent: Int

    public enum Content {
        case File(id: String)
        case Page(url: NSURL)
        case Discussion(id: String)
        case Assignment(id: String)
        case Quiz(id: String)
        case SubHeader
        case ExternalURL(url: NSURL)
        case ExternalTool(id: String, url: NSURL)

        var type: String {
            switch self {
            case .File(_): return "File"
            case .Page(_): return "Page"
            case .Discussion(_): return "Discussion"
            case .Assignment(_): return "Assignment"
            case .Quiz(_): return "Quiz"
            case .SubHeader: return "SubHeader"
            case .ExternalURL(_): return "ExternalUrl"
            case .ExternalTool(_): return "ExternalTool"
            }
        }
    }
    @NSManaged private var contentType: String
    @NSManaged private var contentID: String?
    @NSManaged private var pageURL: String?
    @NSManaged private var externalURL: String?
    internal (set) public var content: Content? {
        get {
            switch contentType {
            case "File":
                guard let contentID = contentID else { return nil }
                return .File(id: contentID)
            case "Page":
                guard let pageURLStr = pageURL, pageURL = NSURL(string: pageURLStr) else { return nil }
                return .Page(url: pageURL)
            case "Discussion":
                guard let contentID = contentID else { return nil }
                return .Discussion(id: contentID)
            case "Assignment":
                guard let contentID = contentID else { return nil }
                return .Assignment(id: contentID)
            case "Quiz":
                guard let contentID = contentID else { return nil }
                return .Quiz(id: contentID)
            case "SubHeader": return .SubHeader
            case "ExternalUrl":
                guard let urlStr = externalURL, externalURL = NSURL(string: urlStr) else { return nil }
                return .ExternalURL(url: externalURL)
            case "ExternalTool":
                guard let contentID = contentID else { return nil }
                guard let urlStr = externalURL, externalURL = NSURL(string: urlStr) else { return nil }
                return .ExternalTool(id: contentID, url: externalURL)
            default: return nil
            }
        }
        set {
            if let newValue = newValue {
                contentType = newValue.type

                switch newValue {
                case .File(let fileID):
                    contentID = fileID
                    pageURL = nil
                    externalURL = nil
                case .Page(let pageURL):
                    contentID = nil
                    self.pageURL = pageURL.absoluteString
                    externalURL = nil
                case .Discussion(let discussionID):
                    contentID = discussionID
                    pageURL = nil
                    externalURL = nil
                case .Assignment(let assignmentID):
                    contentID = assignmentID
                    pageURL = nil
                    externalURL = nil
                case .Quiz(let quizID):
                    contentID = quizID
                    pageURL = nil
                    externalURL = nil
                case .SubHeader:
                    contentID = nil
                    pageURL = nil
                    externalURL = nil
                case .ExternalURL(let url):
                    contentID = nil
                    pageURL = nil
                    externalURL = url.absoluteString
                case .ExternalTool(let toolID, let toolURL):
                    contentID = toolID
                    pageURL = nil
                    externalURL = toolURL.absoluteString
                }
            } else {
                contentType = ""
                contentID = nil
                pageURL = nil
                externalURL = nil
            }
        }
    }

    public enum CompletionRequirement: String {
        case MustView = "must_view"
        case MustSubmit = "must_submit"
        case MustContribute = "must_contribute"
        case MinScore = "min_score"
        case MarkDone = "must_mark_done"
    }
    @NSManaged private var primitiveCompletionRequirement: String
    internal (set) public var completionRequirement: CompletionRequirement {
        get {
            willAccessValueForKey("completionRequirement")
            guard let value = CompletionRequirement(rawValue: primitiveCompletionRequirement) else { fatalError("invalid completion requirement value") }
            didAccessValueForKey("completionRequirement")
            return value
        }
        set {
            willChangeValueForKey("completionRequirement")
            primitiveCompletionRequirement = newValue.rawValue
            didChangeValueForKey("completionRequirement")
        }
    }
    @NSManaged internal (set) public var minScore: NSNumber?
    @NSManaged internal (set) public var completed: Bool
}


import Marshal

extension ModuleItem: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        let moduleID: String = try json.stringID("module_id")
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "moduleID", moduleID)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id          = try json.stringID("id")
        moduleID    = try json.stringID("module_id")
        position    = try json <| "position" ?? 1
        title       = try json <| "title" ?? ""
        indent      = try json <| "indent" ?? 0

        if let completionRequirementJSON: JSONObject = try json <| "completion_requirement" {
            completionRequirement = CompletionRequirement(rawValue: try completionRequirementJSON <| "type")!
            minScore = try completionRequirementJSON <| "min_score"
            completed = try completionRequirementJSON <| "completed" ?? false
        }

        contentType = try json <| "type"
        contentID   = try json <| "content_id"
        pageURL     = try json <| "page_url"
        externalURL = try json <| "external_url"
    }
}
