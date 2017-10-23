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
    case email = "email"
    case sms = "sms"
    case chat = "chat"
    case twitter = "twitter"
    case yo = "yo"
    case push = "push"
    
    var description: String {
        switch self {
        case .email:
            return NSLocalizedString("Email", tableName: "Localizable", bundle: .core, value: "", comment: "Description for email communication channel")
        case .sms:
            return NSLocalizedString("SMS", tableName: "Localizable", bundle: .core, value: "", comment: "Description for SMS communication channel")
        case .chat:
            return NSLocalizedString("Chat", tableName: "Localizable", bundle: .core, value: "", comment: "Description for Chat communication channel")
        case .twitter:
            return NSLocalizedString("Twitter", tableName: "Localizable", bundle: .core, value: "", comment: "Description for Twitter communication channel")
        case .yo:
            return NSLocalizedString("Yo", tableName: "Localizable", bundle: .core, value: "", comment: "Description for Yo communication channel")
        case .push:
            return NSLocalizedString("Push Notifications", tableName: "Localizable", bundle: .core, value: "", comment: "Description for Push Notification channel")
        }
    }
}

enum CommunicationChannelWorkflowState: String {
    case active = "active"
    case unconfirmed = "unconfirmed"
}


public enum DisplayGroup: String, CustomStringConvertible {
    case courseActivities = "Course Activities"
    case discussions = "Discussions"
    case conversations = "Conversations"
    case scheduling = "Scheduling"
    case groups = "Groups"
    
    public var description: String {
        switch self {
        case .courseActivities:
            return NSLocalizedString("Course Activities", tableName: "Localizable", bundle: .core, value: "", comment: "Notification display name for course activities group")
        case .discussions:
            return NSLocalizedString("Discussions", tableName: "Localizable", bundle: .core, value: "", comment: "Notification display name for discussions group")
        case .conversations:
            return NSLocalizedString("Conversations", tableName: "Localizable", bundle: .core, value: "", comment: "Notification display name for conversations group")
        case .scheduling:
            return NSLocalizedString("Scheduling", tableName: "Localizable", bundle: .core, value: "", comment: "Notification display name for scheduling group")
        case .groups:
            return NSLocalizedString("Groups", tableName: "Localizable", bundle: .core, value: "", comment: "Notification display name for groups group")
        }
    }
}

public typealias GroupItem = (name: String, items: [NotificationPreference])

open class CommunicationChannel {
    var address: String
    var id: String
    var position: String
    var type: CommunicationChannelType
    var userID: String
    var workflowState: CommunicationChannelWorkflowState
    
    var preferencesDataSource = Array<(displayGroup: DisplayGroup, groupItems: Array<GroupItem>?)>()
    
    open class func create(_ dictionary: [String: Any]) -> CommunicationChannel? {
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
    
    fileprivate init(address: String, id: String, position: String, type: CommunicationChannelType, userID: String, workflowState: CommunicationChannelWorkflowState) {
        
        self.address = address
        self.id = id
        self.position = position
        self.type = type
        self.userID = userID
        self.workflowState = workflowState
    }
    
    func createNotificationPreferencesGroups(_ notificationPreferences: Array<NotificationPreference>) {

        // Not currently mapping the following
        // ADMIN:           registration, summaries, other, migration, alert
        //                  Including admin would require another level because the heading is not representative of
        //                  a single 'category' like the other headings are.  It has multiple 'category's which is
        //                  completely different than the data model for the others and would require rework
        // DEPRECATED:      reminder
        // NOT SUPPORTED:   recording_ready
        let pairingMap: Dictionary<String, (itemName: String, groupName: DisplayGroup)> = [
            // Course Activities
            "course_content":               ("Course Content", .courseActivities),
            "files":                        ("Files", .courseActivities),
            "all_submissions":              ("All Submissions", .courseActivities),
            "submission_comment":           ("Submission Comment", .courseActivities),
            "announcement":                 ("Announcement", .courseActivities),
            "announcement_created_by_you":  ("Announcement Created By You", .courseActivities),
            "grading":                      ("Grading", .courseActivities),
            "due_date":                     ("Due Date", .courseActivities),
            "late_grading":                 ("Late Grading", .courseActivities),
            "invitation":                   ("Invitation", .courseActivities),
            "grading_policies":             ("Grading Policies", .courseActivities),
            // Discussions
            "discussion_entry":             ("Discussion Post", .discussions),
            "discussion":                   ("Discussion", .discussions),
            // Conversations
            "added_to_conversation":        ("Added To Conversation", .conversations),
            "conversation_message":         ("Conversation Message", .conversations),
            "conversation_created":         ("Conversation Created By Me", .conversations),
            // Scheduling
            "appointment_availability":     ("Appointment Availability", .scheduling),
            "appointment_signups":          ("Appointment Signups", .scheduling),
            // DEPENDENCY: Complete the bottom two items after this web ticket has been completed
            // https://instructure.atlassian.net/browse/CNVS-3369
            // TODO: Update "appointment_cancelations" -> "appointment_cancellations"
            // TODO: Update "Appointment Cancelations" -> "Appointment Cancellations"
            "appointment_cancelations":     ("Appointment Cancellations", .scheduling),
            "student_appointment_signups":  ("Student Appointment Signups", .scheduling),
            "calendar":                     ("Calendar", .scheduling),
            // Groups
            "membership_update":            ("Membership Update", .groups)
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
            (.courseActivities, displayMapping[DisplayGroup.courseActivities.rawValue]),
            (.discussions,      displayMapping[DisplayGroup.discussions.rawValue]),
            (.conversations,    displayMapping[DisplayGroup.conversations.rawValue]),
            (.scheduling,       displayMapping[DisplayGroup.scheduling.rawValue]),
            (.groups,           displayMapping[DisplayGroup.groups.rawValue]),
        ]
    }
}
