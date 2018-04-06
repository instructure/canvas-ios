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




open class ModuleItem: NSManagedObject, LockableModel {
    @NSManaged internal (set) open var id: String
    @NSManaged internal (set) open var moduleID: String
    @NSManaged internal (set) open var courseID: String // This is not in the json, but set in the refresher
    @NSManaged internal (set) open var position: Float
    @NSManaged internal (set) open var title: String
    @NSManaged internal (set) open var indent: Int64
    @NSManaged internal (set) open var url: String?
    @NSManaged internal (set) open var htmlURL: String?

    // LockableModel
    @NSManaged open var lockedForUser: Bool
    @NSManaged open var lockExplanation: String?
    @NSManaged open var canView: Bool

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
        case file(id: String)
        case page(url: String)
        case discussion(id: String)
        case assignment(id: String)
        case quiz(id: String)
        case subHeader
        case externalURL(url: URL)
        case externalTool(id: String, url: URL)
        case masteryPaths

        var type: ContentType {
            switch self {
            case .file(_): return .file
            case .page(_): return .page
            case .discussion(_): return .discussion
            case .assignment(_): return .assignment
            case .quiz(_): return .quiz
            case .subHeader: return .subHeader
            case .externalURL(_): return .externalURL
            case .externalTool(_): return .externalTool
            case .masteryPaths: return .masteryPaths
            }
        }
    }
    @NSManaged fileprivate var primitiveContentType: String
    internal (set) open var contentType: ContentType {
        get {
            willAccessValue(forKey: "contentType")
            let value = ContentType(rawValue: primitiveContentType)!
            didAccessValue(forKey: "contentType")
            return value
        }
        set {
            willChangeValue(forKey: "contentType")
            primitiveContentType = newValue.rawValue
            didChangeValue(forKey: "contentType")
        }
    }
    @NSManaged fileprivate var contentID: String?
    @NSManaged fileprivate var pageURL: String?
    @NSManaged fileprivate var externalURL: String?
    internal (set) open var content: Content? {
        get {
            switch contentType {
            case .file:
                guard let contentID = contentID else { return nil }
                return .file(id: contentID)
            case .page:
                guard let pageURL = pageURL else { return nil }
                return .page(url: pageURL)
            case .discussion:
                guard let contentID = contentID else { return nil }
                return .discussion(id: contentID)
            case .assignment:
                guard let contentID = contentID else { return nil }
                return .assignment(id: contentID)
            case .quiz:
                guard let contentID = contentID else { return nil }
                return .quiz(id: contentID)
            case .subHeader: return .subHeader
            case .externalURL:
                guard let urlStr = self.externalURL, let externalURL = URL(string: urlStr) else { return nil }
                return .externalURL(url: externalURL)
            case .externalTool:
                guard let contentID = contentID else { return nil }
                guard let urlStr = self.externalURL, let externalURL = URL(string: urlStr) else { return nil }
                if urlStr.range(of: "chalkandwire") != nil, let htmlStr = htmlURL, let url = URL(string: htmlStr) {
                    return .externalURL(url: url)
                }
                return .externalTool(id: contentID, url: externalURL)
            case .masteryPaths: return .masteryPaths
            }
        }
        set {
            contentID = nil
            pageURL = nil
            externalURL = nil
            if let newValue = newValue {
                contentType = newValue.type

                switch newValue {
                case .file(let fileID):
                    contentID = fileID
                case .page(let pageURL):
                    self.pageURL = pageURL
                case .discussion(let discussionID):
                    contentID = discussionID
                case .assignment(let assignmentID):
                    contentID = assignmentID
                case .quiz(let quizID):
                    contentID = quizID
                case .subHeader, .masteryPaths:
                    break
                case .externalURL(let url):
                    externalURL = url.absoluteString
                case .externalTool(let toolID, let toolURL):
                    contentID = toolID
                    externalURL = toolURL.absoluteString
                }
            }
        }
    }

    public enum CompletionRequirement: String {
        case mustView = "must_view"
        case mustSubmit = "must_submit"
        case mustContribute = "must_contribute"
        case minScore = "min_score"
        case markDone = "must_mark_done"

        // custom, for mastery paths
        case mustChoose = "must_choose"
    }
    @NSManaged fileprivate var primitiveCompletionRequirement: String?
    internal (set) open var completionRequirement: CompletionRequirement? {
        
        get {
            willAccessValue(forKey: "completionRequirement")
            let value = primitiveCompletionRequirement.flatMap(CompletionRequirement.init)
            didAccessValue(forKey: "completionRequirement")
            return value
        }
        set {
            willChangeValue(forKey: "completionRequirement")
            primitiveCompletionRequirement = newValue?.rawValue
            didChangeValue(forKey: "completionRequirement")
        }
    }
    @NSManaged internal (set) open var minScore: NSNumber?
    @NSManaged internal (set) open var completed: Bool
}


import Marshal

extension ModuleItem: SynchronizedModel {
    public static func parseCompletionRequirement(_ json: JSONObject) throws -> (completionRequirement: CompletionRequirement?, minScore: NSNumber?, completed: Bool) {
        let completedDefault = true
        guard let completionRequirementJSON: JSONObject = try json <| "completion_requirement" else {
            return (nil, nil, completedDefault)
        }

        let completionRequirement: CompletionRequirement = try completionRequirementJSON <| "type"
        let minScore: NSNumber? = try completionRequirementJSON <| "min_score"
        let completed: Bool = (try completionRequirementJSON <| "completed") ?? completedDefault

        return (completionRequirement, minScore, completed)
    }

    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        let moduleID: String = try json.stringID("module_id")
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "moduleID", moduleID)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id          = try json.stringID("id")
        courseID    = try json.stringID("course_id")
        moduleID    = try json.stringID("module_id")
        position    = (try json <| "position") ?? 1
        title       = (try json <| "title") ?? ""
        indent      = (try json <| "indent") ?? 0
        contentType = try json <| "type"
        contentID   = try json.stringID("content_id")
        pageURL     = try json <| "page_url"
        externalURL = try json <| "external_url"
        url         = try json <| "url"
        htmlURL     = try json <| "html_url"

        try updateCompletionRequirement(json)
        try updateMasteryPaths(json, inContext: context)
        try updateLockStatus((try json <| "content_details") ?? [:])
    }

    func updateCompletionRequirement(_ json: JSONObject) throws {
        completionRequirement = nil
        minScore = nil
        completed = true
        (completionRequirement, minScore, completed) = try ModuleItem.parseCompletionRequirement(json)
    }

    func updateMasteryPaths(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        if let masteryPaths: JSONObject = try json <| "mastery_paths" {
            // We don't care to remember the details about what selection they made, so we don't store that.
            // In the future, we can remove this requirement and filter any with a selectedSetID from the
            // collections predicate, if we want to have this information
            let selectedSetID: String? = try masteryPaths.stringID("selected_set_id")
            if selectedSetID != nil {
                return
            }
            let masteryPathsItem: MasteryPathsItem = (try context.findOne(withPredicate: MasteryPathsItem.predicateForMasteryPathsItem(inModule: moduleID, fromItemWithMasteryPaths: id)) ?? MasteryPathsItem(inContext: context))
            masteryPathsItem.id = UUID().uuidString
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
            masteryPathsItem.completionRequirement = .mustChoose
            masteryPathsItem.selectedSetID = try masteryPaths.stringID("selected_set_id")
            masteryPathsItem.lockExplanation = nil

            let locked: Bool = try masteryPaths <| "locked"
            masteryPathsItem.lockedForUser = locked
            masteryPathsItem.canView = !locked
            masteryPathsItem.completed = !locked

            var existingAssignmentSets = masteryPathsItem.assignmentSets as! Set<MasteryPathAssignmentSet>
            let assignmentSetsJSON: [JSONObject] = try masteryPaths <| "assignment_sets"
            for assignmentSetJSON in assignmentSetsJSON {
                let assignmentSet: MasteryPathAssignmentSet = (try context.findOne(withPredicate: MasteryPathAssignmentSet.uniquePredicateForObject(assignmentSetJSON)) ?? MasteryPathAssignmentSet(inContext: context))
                try assignmentSet.updateValues(assignmentSetJSON, inContext: context)
                masteryPathsItem.addAssignmentSetObject(object: assignmentSet)

                existingAssignmentSets.remove(assignmentSet)
            }

            for item in existingAssignmentSets {
                item.delete(inContext: context)
            }

        } else {
            // Clear up any old ones, if they are to be found
            let masteryPathsItems: [MasteryPathsItem] = try context.findAll(matchingPredicate: NSPredicate(format: "%K == %@", "moduleItemID", id))
            masteryPathsItems.forEach { $0.delete(inContext: context) }  // should cascade delete all related mastery paths stuff
        }

    }
}

extension ModuleItem.Content: Equatable {}
public func ==(lhs: ModuleItem.Content, rhs: ModuleItem.Content) -> Bool {
    switch (lhs, rhs) {
    case let (.file(r), .file(l)):
        return r == l
    case let (.page(r), .page(l)):
        return r == l
    case let (.discussion(r), .discussion(l)):
        return r == l
    case let (.assignment(r), .assignment(l)):
        return r == l
    case let (.quiz(r), .quiz(l)):
        return r == l
    case (.subHeader, .subHeader):
        return true
    case let (.externalURL(r), .externalURL(l)):
        return r == l
    case let (.externalTool(r, r1), .externalTool(l, l1)):
        return r == l && r1 == l1
    case (.masteryPaths, .masteryPaths):
        return true
    default:
        return false
    }
}

