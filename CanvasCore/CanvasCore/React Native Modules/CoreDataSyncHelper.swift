//
//  AsyncActionNotification.swift
//  CanvasCore
//
//  Created by Nathan Armstrong on 12/15/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Marshal

private enum ActionType: String {
    case refreshCourses = "courses.refresh"
    case refreshCourseTabs = "courses.tabs.refresh"
    case updateCourseColor = "courses.updateColor"
    case toggleFavorite = "courses.toggleFavorite"
    case refreshGroupsForUser = "groups-for-user.refresh"
}

private struct Action {
    let type: ActionType
    let payload: JSONObject
    let result: Any

    init?(userInfo: [AnyHashable: Any]) {
        guard let payload = userInfo["payload"] as? JSONObject, let result = payload["result"], let type = userInfo["type"] as? String, let actionType = ActionType(rawValue: type) else {
            return nil
        }

        self.type = actionType
        self.payload = payload
        self.result = result
    }
}

private enum AsyncAction {
    case refreshCourses([JSONObject], JSONObject)
    case updateCourseColor(String, String)
    case toggleFavorite(String, Bool)
    case refreshCourseTabs(String, [JSONObject])
    case refreshGroupsForUser([JSONObject])
    
    init?(action: Action) {
        switch action.type {
        case .refreshCourses:
            if let result = action.result as? [JSONObject],
                result.count == 2,
                let courses: [JSONObject] = try? result[0] <| "data",
                let customColors: JSONObject = try? result[1] <| "data" {
                self = .refreshCourses(courses, customColors)
                return
            }
        case .updateCourseColor:
            if let courseID: String = try? action.payload <| "courseID",
                let color: String = try? action.payload <| "color" {
                self = .updateCourseColor(courseID, color)
                return
            }
        case .toggleFavorite:
            if let courseID: String = try? action.payload <| "courseID",
                let isFavorite: Bool = try? action.payload <| "markAsFavorite" {
                self = .toggleFavorite(courseID, isFavorite)
                return
            }
        case .refreshCourseTabs:
            if let courseID: String = try? action.payload <| "courseID",
                let result = action.result as? JSONObject,
                let tabs: [JSONObject] = try? result <| "data" {
                self = .refreshCourseTabs(courseID, tabs)
                return
            }
        case .refreshGroupsForUser:
            if let result = action.result as? JSONObject,
                let groups: [JSONObject] = try? result <| "data" {
                self = .refreshGroupsForUser(groups)
                return
            }
        }
        return nil
    }

    func sync(_ session: Session, completion: @escaping () -> Void) {
        switch self {
        case .refreshCourses(let courses, let customColors):
            do {
                let context = try session.enrollmentManagedObjectContext()
                let colors = try Enrollment.parseColors(customColors)
                Course.sync(inContext: context, jsonArray: courses) { error in
                    if (error == nil) {
                        Enrollment.writeFavoriteColors(colors, inContext: context) { _ in
                            completion()
                        }
                    } else {
                        completion()
                    }
                }
            } catch {
                completion()
            }
        case .updateCourseColor(let courseID, let hex):
            let contextID = ContextID(id: courseID, context: .course)
            guard let color = UIColor.colorFromHexString(hex) else { return completion() }
            do {
                let context = try session.enrollmentManagedObjectContext()
                Enrollment.writeFavoriteColors([contextID: color], inContext: context) { _ in
                    completion()
                }
            } catch {
                completion()
            }
        case .toggleFavorite(let courseID, let isFavorite):
            do {
                let context = try session.enrollmentManagedObjectContext()
                context.perform() {
                    do {
                        let contextID = ContextID(id: courseID, context: .course)
                        let enrollment = try Course.findOne(contextID, inContext: context)
                        enrollment?.isFavorite = isFavorite
                        try context.save()
                        completion()
                    } catch {
                        completion()
                    }
                }
            } catch {
                completion()
            }
        case .refreshCourseTabs(let courseID, let tabs):
            let contextID = ContextID(id: courseID, context: .course)
            let predicate = NSPredicate(format: "%K == %@", "rawContextID", contextID.canvasContextID)
            do {
                let context = try session.enrollmentManagedObjectContext()
                Tab.sync(predicate, inContext: context, jsonArray: tabs) { _ in
                    Enrollment.arcLTIToolID(courseID: courseID) { arcID in
                        context.perform {
                            do {
                                if let course: Course = try context.findOne(withValue: courseID, forKey: "id") {
                                    course.arcLTIToolID = arcID
                                    try context.save()
                                }
                                completion()
                            } catch {
                                completion()
                            }
                        }
                    }
                }
            } catch {
                completion()
            }
        case .refreshGroupsForUser(let groups):
            do {
                let context = try session.enrollmentManagedObjectContext()
                Group.sync(inContext: context, jsonArray: groups) { _ in
                    completion()
                }
            } catch {
                completion()
            }
        }
    }
}

public class CoreDataSyncHelper: NSObject {
    public static func syncAction(_ info: [String: Any], completion: @escaping () -> Void) {
        guard let action = Action(userInfo: info) else { return completion() }
        guard let asyncAction = AsyncAction(action: action) else { return completion() }
        guard let session = CanvasKeymaster.the().currentClient?.authSession else { return completion() }
        asyncAction.sync(session, completion: completion)
    }
}
