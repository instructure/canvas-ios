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

enum CommunicationChannelType: String, CustomStringConvertible {
    case Email = "email"
    case SMS = "sms"
    case Chat = "chat"
    case Twitter = "twitter"
    case Yo = "yo"
    case Push = "push"
    
    var description: String {
        switch self {
        case .Email:
            return NSLocalizedString("Email", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Description for email communication channel")
        case .SMS:
            return NSLocalizedString("SMS", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Description for SMS communication channel")
        case .Chat:
            return NSLocalizedString("Chat", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Description for Chat communication channel")
        case .Twitter:
            return NSLocalizedString("Twitter", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Description for Twitter communication channel")
        case .Yo:
            return NSLocalizedString("Yo", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Description for Yo communication channel")
        case .Push:
            return NSLocalizedString("Push Notifications", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Description for Push Notification channel")
        }
    }
}

enum CommunicationChannelWorkflowState: String {
    case Active = "active"
    case Unconfirmed = "unconfirmed"
}


public enum DisplayGroup: String, CustomStringConvertible {
    case CourseActivities = "Course Activities"
    case Discussions = "Discussions"
    case Conversations = "Conversations"
    case Scheduling = "Scheduling"
    case Groups = "Groups"
    
    public var description: String {
        switch self {
        case CourseActivities:
            return NSLocalizedString("Course Activities", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Notification display name for course activities group")
        case Discussions:
            return NSLocalizedString("Discussions", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Notification display name for discussions group")
        case Conversations:
            return NSLocalizedString("Conversations", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Notification display name for conversations group")
        case Scheduling:
            return NSLocalizedString("Scheduling", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Notification display name for scheduling group")
        case Groups:
            return NSLocalizedString("Groups", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "Notification display name for groups group")
        }
    }
}

public typealias GroupItem = (name: String, items: [NotificationPreference])

public class CommunicationChannel {
    var address: String
    var id: String
    var position: String
    var type: CommunicationChannelType
    var userID: String
    var workflowState: CommunicationChannelWorkflowState
    
    var preferencesDataSource = Array<(displayGroup: DisplayGroup, groupItems: Array<GroupItem>?)>()
    
    public class func create(dictionary: [String: AnyObject]) -> CommunicationChannel? {
        if  let address         = dictionary["address"] as? String,
            let id              = dictionary["id"] as? Int,
            let position        = dictionary["position"] as? Int,
            let type            = dictionary["type"] as? String,
            let userID          = dictionary["user_id"] as? Int,
            let workflowState   = dictionary["workflow_state"]as? String {
                return CommunicationChannel(address: address, id: "\(id)", position: "\(position)", type: CommunicationChannelType(rawValue: type)!, userID: "\(userID)", workflowState: CommunicationChannelWorkflowState(rawValue: workflowState)!)
        } else {
            return nil
        }
    }
    
    private init(address: String, id: String, position: String, type: CommunicationChannelType, userID: String, workflowState: CommunicationChannelWorkflowState) {
        
        self.address = address
        self.id = id
        self.position = position
        self.type = type
        self.userID = userID
        self.workflowState = workflowState
    }
    
    func createNotificationPreferencesGroups(notificationPreferences: Array<NotificationPreference>) {

        // Not currently mapping the following
        // ADMIN:           registration, summaries, other, migration, alert
        //                  Including admin would require another level because the heading is not representative of
        //                  a single 'category' like the other headings are.  It has multiple 'category's which is
        //                  completely different than the data model for the others and would require rework
        // DEPRECATED:      reminder
        // NOT SUPPORTED:   recording_ready
        let pairingMap: Dictionary<String, (itemName: String, groupName: DisplayGroup)> = [
            // Course Activities
            "course_content":               ("Course Content", .CourseActivities),
            "files":                        ("Files", .CourseActivities),
            "all_submissions":              ("All Submissions", .CourseActivities),
            "submission_comment":           ("Submission Comment", .CourseActivities),
            "announcement":                 ("Announcement", .CourseActivities),
            "announcement_created_by_you":  ("Announcement Created By You", .CourseActivities),
            "grading":                      ("Grading", .CourseActivities),
            "due_date":                     ("Due Date", .CourseActivities),
            "late_grading":                 ("Late Grading", .CourseActivities),
            "invitation":                   ("Invitation", .CourseActivities),
            "grading_policies":             ("Grading Policies", .CourseActivities),
            // Discussions
            "discussion_entry":             ("Discussion Post", .Discussions),
            "discussion":                   ("Discussion", .Discussions),
            // Conversations
            "added_to_conversation":        ("Added To Conversation", .Conversations),
            "conversation_message":         ("Conversation Message", .Conversations),
            "conversation_created":         ("Conversation Created By Me", .Conversations),
            // Scheduling
            "appointment_availability":     ("Appointment Availability", .Scheduling),
            "appointment_signups":          ("Appointment Signups", .Scheduling),
            // DEPENDENCY: Complete the bottom two items after this web ticket has been completed
            // https://instructure.atlassian.net/browse/CNVS-3369
            // TODO: Update "appointment_cancelations" -> "appointment_cancellations"
            // TODO: Update "Appointment Cancelations" -> "Appointment Cancellations"
            "appointment_cancelations":     ("Appointment Cancellations", .Scheduling),
            "student_appointment_signups":  ("Student Appointment Signups", .Scheduling),
            "calendar":                     ("Calendar", .Scheduling),
            // Groups
            "membership_update":            ("Membership Update", .Groups)
        ]
        
        
        var displayMapping: Dictionary<String, Array<GroupItem>> = [
            "Course Activities": [],
            "Discussions": [],
            "Conversations": [],
            "Scheduling": [],
            "Groups": []
        ]
        
        var tempItemCategoryPairing = Dictionary<String, Array<NotificationPreference>>()
        
        for preference in notificationPreferences {
            var arr = tempItemCategoryPairing[preference.category] ?? []
            arr.append(preference)
            tempItemCategoryPairing[preference.category] = arr
        }
        
        // As of this point, you have a mapping of the api's category -> the prefs
        for (category, prefs) in tempItemCategoryPairing {
            // Here we grab the pairing info from the big map and then dump that group item into it's correct display group
            
            if  let itemName = pairingMap[category]?.itemName,
                let groupName = pairingMap[category]?.groupName {
                    let groupItem: GroupItem = (itemName, prefs)
                    displayMapping[groupName.rawValue]?.append(groupItem)
            }
        }
    
        // As of this point, you have a map where each key is the display group, and each value is the items for that big group. 
        // Each of those items in that group have subitems.
        
        preferencesDataSource = [
            (.CourseActivities, displayMapping[DisplayGroup.CourseActivities.rawValue]),
            (.Discussions,      displayMapping[DisplayGroup.Discussions.rawValue]),
            (.Conversations,    displayMapping[DisplayGroup.Conversations.rawValue]),
            (.Scheduling,       displayMapping[DisplayGroup.Scheduling.rawValue]),
            (.Groups,           displayMapping[DisplayGroup.Groups.rawValue]),
        ]
    }
}