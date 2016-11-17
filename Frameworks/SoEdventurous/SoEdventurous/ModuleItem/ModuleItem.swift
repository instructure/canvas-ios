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
import CoreData
import SoPersistent
import SoIconic
import TooLegit

public class ModuleItem: NSManagedObject, LockableModel {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var moduleID: String
    @NSManaged internal (set) public var courseID: String // This is not in the json, but set in the refresher
    @NSManaged internal (set) public var position: Float
    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var indent: Int
    @NSManaged internal (set) public var url: String?

    // LockableModel
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var canView: Bool

    public enum ContentType: String {
        case file = "File"
        case page = "Page"
        case discussion = "Discussion"
        case assignment = "Assignment"
        case quiz = "Quiz"
        case subHeader = "SubHeader"
        case externalURL = "ExternalUrl"
        case externalTool = "ExternalTool"
        case masteryPaths = "MasteryPaths"
    }

    public enum Content {
        case File(id: String)
        case Page(url: NSURL)
        case Discussion(id: String)
        case Assignment(id: String)
        case Quiz(id: String)
        case SubHeader
        case ExternalURL(url: NSURL)
        case ExternalTool(id: String, url: NSURL)
        case MasteryPaths

        var type: ContentType {
            switch self {
            case .File(_): return .file
            case .Page(_): return .page
            case .Discussion(_): return .discussion
            case .Assignment(_): return .assignment
            case .Quiz(_): return .quiz
            case .SubHeader: return .subHeader
            case .ExternalURL(_): return .externalURL
            case .ExternalTool(_): return .externalTool
            case .MasteryPaths: return .masteryPaths
            }
        }
    }
    @NSManaged private var primitiveContentType: String
    internal (set) public var contentType: ContentType {
        get {
            willAccessValueForKey("contentType")
            let value = ContentType(rawValue: primitiveContentType)!
            didAccessValueForKey("contentType")
            return value
        }
        set {
            willChangeValueForKey("contentType")
            primitiveContentType = newValue.rawValue
            didChangeValueForKey("contentType")
        }
    }
    @NSManaged private var contentID: String?
    @NSManaged private var pageURL: String?
    @NSManaged private var externalURL: String?
    internal (set) public var content: Content? {
        get {
            switch contentType {
            case .file:
                guard let contentID = contentID else { return nil }
                return .File(id: contentID)
            case .page:
                guard let pageURLStr = pageURL, pageURL = NSURL(string: pageURLStr) else { return nil }
                return .Page(url: pageURL)
            case .discussion:
                guard let contentID = contentID else { return nil }
                return .Discussion(id: contentID)
            case .assignment:
                guard let contentID = contentID else { return nil }
                return .Assignment(id: contentID)
            case .quiz:
                guard let contentID = contentID else { return nil }
                return .Quiz(id: contentID)
            case .subHeader: return .SubHeader
            case .externalURL:
                guard let urlStr = externalURL, externalURL = NSURL(string: urlStr) else { return nil }
                return .ExternalURL(url: externalURL)
            case .externalTool:
                guard let contentID = contentID else { return nil }
                guard let urlStr = externalURL, externalURL = NSURL(string: urlStr) else { return nil }
                return .ExternalTool(id: contentID, url: externalURL)
            case .masteryPaths: return .MasteryPaths
            }
        }
        set {
            contentID = nil
            pageURL = nil
            externalURL = nil
            if let newValue = newValue {
                contentType = newValue.type

                switch newValue {
                case .File(let fileID):
                    contentID = fileID
                case .Page(let pageURL):
                    self.pageURL = pageURL.absoluteString
                case .Discussion(let discussionID):
                    contentID = discussionID
                case .Assignment(let assignmentID):
                    contentID = assignmentID
                case .Quiz(let quizID):
                    contentID = quizID
                case .SubHeader, .MasteryPaths:
                    break
                case .ExternalURL(let url):
                    externalURL = url.absoluteString
                case .ExternalTool(let toolID, let toolURL):
                    contentID = toolID
                    externalURL = toolURL.absoluteString
                }
            }
        }
    }

    public enum CompletionRequirement: String {
        case MustView = "must_view"
        case MustSubmit = "must_submit"
        case MustContribute = "must_contribute"
        case MinScore = "min_score"
        case MarkDone = "must_mark_done"

        // custom, for mastery paths
        case MustChoose = "must_choose"
    }
    @NSManaged private var primitiveCompletionRequirement: String?
    internal (set) public var completionRequirement: CompletionRequirement? {
        
        get {
            willAccessValueForKey("completionRequirement")
            let value = primitiveCompletionRequirement.flatMap(CompletionRequirement.init)
            didAccessValueForKey("completionRequirement")
            return value
        }
        set {
            willChangeValueForKey("completionRequirement")
            primitiveCompletionRequirement = newValue?.rawValue
            didChangeValueForKey("completionRequirement")
        }
    }
    @NSManaged internal (set) public var minScore: NSNumber?
    @NSManaged internal (set) public var completed: Bool
}


import Marshal

extension ModuleItem: SynchronizedModel {
    public static func parseCompletionRequirement(json: JSONObject) throws -> (completionRequirement: CompletionRequirement?, minScore: NSNumber?, completed: Bool) {
        let completedDefault = false
        guard let completionRequirementJSON: JSONObject = try json <| "completion_requirement" else {
            return (nil, nil, completedDefault)
        }

        let completionRequirement: CompletionRequirement = try completionRequirementJSON <| "type"
        let minScore: NSNumber? = try completionRequirementJSON <| "min_score"
        let completed: Bool = try completionRequirementJSON <| "completed" ?? completedDefault

        return (completionRequirement, minScore, completed)
    }

    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        let moduleID: String = try json.stringID("module_id")
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "moduleID", moduleID)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id          = try json.stringID("id")
        courseID    = try json.stringID("course_id")
        moduleID    = try json.stringID("module_id")
        position    = try json <| "position" ?? 1
        title       = try json <| "title" ?? ""
        indent      = try json <| "indent" ?? 0
        contentType = try json <| "type"
        contentID   = try json.stringID("content_id")
        pageURL     = try json <| "page_url"
        externalURL = try json <| "external_url"
        url         = try json <| "url"

        try updateCompletionRequirement(json)
        try updateMasteryPaths(json, inContext: context)
        try updateLockStatus(json)
    }

    func updateCompletionRequirement(json: JSONObject) throws {
        completionRequirement = nil
        minScore = nil
        completed = true
        (completionRequirement, minScore, completed) = try ModuleItem.parseCompletionRequirement(json)
    }

    func updateMasteryPaths(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        // We don't care to remember the details about what selection they made, so we don't store that. In the future, we can remove this requirement and filter any with a selectedSetID from the collections predicate, if we want to have this information
        if let masteryPaths: JSONObject = try json <| "mastery_paths", selectedSetID: String? = try masteryPaths.stringID("selected_set_id") where selectedSetID == nil {
            let masteryPathsItem: MasteryPathsItem = (try context.findOne(withPredicate: MasteryPathsItem.predicateForMasteryPathsItem(inModule: moduleID, fromItemWithMasteryPaths: id)) ?? MasteryPathsItem(inContext: context))
            masteryPathsItem.id = NSUUID().UUIDString
            masteryPathsItem.moduleID = moduleID
            masteryPathsItem.moduleItemID = id
            masteryPathsItem.courseID = courseID
            masteryPathsItem.position = position + 0.5 // hurray for hacks! This gets it to show in the list where it should
            masteryPathsItem.title = ""
            masteryPathsItem.indent = indent
            masteryPathsItem.contentType = .masteryPaths
            masteryPathsItem.contentID = nil
            masteryPathsItem.pageURL = nil
            masteryPathsItem.externalURL = nil
            masteryPathsItem.completionRequirement = .MustChoose
            masteryPathsItem.selectedSetID = try masteryPaths.stringID("selected_set_id")
            masteryPathsItem.lockedForUser = false
            masteryPathsItem.lockExplanation = nil
            masteryPathsItem.canView = true

            let locked: Bool = try masteryPaths <| "locked"
            masteryPathsItem.locked = locked
            masteryPathsItem.completed = !locked

            var existingAssignmentSets = masteryPathsItem.assignmentSets as! Set<MasteryPathAssignmentSet>
            let assignmentSetsJSON: [JSONObject] = try masteryPaths <| "assignment_sets"
            for assignmentSetJSON in assignmentSetsJSON {
                let assignmentSet: MasteryPathAssignmentSet = (try context.findOne(withPredicate: MasteryPathAssignmentSet.uniquePredicateForObject(assignmentSetJSON)) ?? MasteryPathAssignmentSet(inContext: context))
                try assignmentSet.updateValues(assignmentSetJSON, inContext: context)
                masteryPathsItem.addAssignmentSetObject(assignmentSet)

                existingAssignmentSets.remove(assignmentSet)
            }

            for item in existingAssignmentSets {
                item.delete(inContext: context)
            }

        } else {
            // Clear up any old ones, if they are to be found
            if let masteryPathsItems: [MasteryPathsItem] = try context.findAll(matchingPredicate: NSPredicate(format: "%K == %@", "moduleItemID", id)) {
                masteryPathsItems.forEach { $0.delete(inContext: context) }  // should cascade delete all related mastery paths stuff
            }
        }

    }
}

extension ModuleItem.Content: Equatable {}
public func ==(lhs: ModuleItem.Content, rhs: ModuleItem.Content) -> Bool {
    switch (lhs, rhs) {
    case let (.File(r), .File(l)):
        return r == l
    case let (.Page(r), .Page(l)):
        return r == l
    case let (.Discussion(r), .Discussion(l)):
        return r == l
    case let (.Assignment(r), .Assignment(l)):
        return r == l
    case let (.Quiz(r), .Quiz(l)):
        return r == l
    case (.SubHeader, .SubHeader):
        return true
    case let (.ExternalURL(r), .ExternalURL(l)):
        return r == l
    case let (.ExternalTool(r, r1), .ExternalTool(l, l1)):
        return r == l && r1 == l1
    case (.MasteryPaths, .MasteryPaths):
        return true
    default:
        return false
    }
}

