//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
@testable import Core
import UIKit

public class MiniCanvasState {
    public var courses: [MiniCourse] = []
    public var enrollments: [APIEnrollment] = []
    public var students: [APIUser]
    public var teachers: [APIUser]
    public var observers: [APIUser]
    public var selfId: String
    public var brandVariables = APIBrandVariables.make()
    public var unreadCount: UInt = 3
    public var accountNotifications: [APIAccountNotification]
    public var customColors: [String: String] = [:]
    public var liveConferences: [APIConference] = []
    public var folders: [String: MiniFolder] = [:]
    public var files: [String: MiniFile] = [:]
    public var todos: [APITodo] = []

    public let idGenerator = IDGenerator()
    public let baseUrl: URL

    public class IDGenerator: Encodable {
        private var nextID: Int = 10

        public func next<I: ExpressibleByIntegerLiteral>() -> I where I.IntegerLiteralType == Int {
            defer { nextID += 1 }
            return I.init(integerLiteral: nextID)
        }
    }

    init(baseUrl: URL) {
        self.baseUrl = baseUrl

        students = [
            APIUser.makeUser(role: "Student", id: idGenerator.next()),
            APIUser.makeUser(role: "Student", id: idGenerator.next()),
            APIUser.makeUser(role: "Student", id: idGenerator.next())
        ]

        teachers = [APIUser.makeUser(role: "Teacher", id: idGenerator.next())]
        observers = [APIUser.makeUser(role: "Parent", id: idGenerator.next())]
        accountNotifications = [.make(id: idGenerator.next())]

        selfId = students[0].id.value

        [
            APICourse.make(id: nextId(), name: "Course One", course_code: "C1", workflow_state: .available, enrollments: []),
            APICourse.make(id: nextId(), name: "Course Two (unpublished)", course_code: "C2", workflow_state: .unpublished, enrollments: []),
            APICourse.make(id: nextId(), name: "Course Three (completed)", course_code: "C3", workflow_state: .completed, enrollments: [])
        ].forEach { MiniCourse.create($0, populatingState: self) }
    }
}

extension MiniCanvasState {
    public func enroll(_ user: APIUser, intoCourse course: MiniCourse, as role: String, observing: APIUser? = nil) {
        let enrollment = APIEnrollment.make(
            id: nextId().value,
            course_id: course.id,
            type: role,
            user_id: user.id.value,
            associated_user_id: observing?.id.value,
            role: role,
            user: user,
            observed_user: observing
        )
        enrollments.append(enrollment)
        course.api.enrollments = course.api.enrollments ?? []
        course.api.enrollments?.append(enrollment)
    }

    public func course(byId id: String?) -> MiniCourse? {
        courses.first { $0.id == id }
    }
    public func assignment(byId id: String?) -> MiniAssignment? {
        courses.lazy.compactMap({ $0.assignment(byId: id) }).first
    }
    public var allUsers: [APIUser] { students + teachers + observers }
    public func user(byId id: String) -> APIUser? {
        allUsers.first { $0.id.value == id }
    }

    public var selfUser: APIUser { user(byId: selfId)! }

    public func userEnrollments(forId id: String? = nil, state: Set<EnrollmentState> = []) -> [APIEnrollment] {
        enrollments.filter { $0.user_id.value == id ?? selfId && (state.isEmpty || state.contains($0.enrollment_state)) }
    }

    public func nextId() -> ID {
        idGenerator.next()
    }

    public func colorForId(id: String) -> String {
        let phi: CGFloat = (1 + sqrt(5)) / 2
        // multiply by a very irrational value so that colors are distant
        let color = UIColor(hue: CGFloat(Int(id) ?? 0) * phi, saturation: 1, brightness: 0.75, alpha: 1)
        return color.hexString
    }

    @discardableResult
    public func addDocument(name: String, contents: Data) -> MiniFile {
        let file = addFile(name: name, contents: contents, type: "image/pdf", mimeClass: "pdf")
        file.api.url = APIURL(rawValue: baseUrl.appendingPathComponent("files/\(file.id)"))
        file.api.preview_url = APIURL(rawValue: baseUrl.appendingPathComponent("documents/\(file.id)/preview"))
        file.api.thumbnail_url = APIURL(rawValue: baseUrl.appendingPathComponent("files/\(file.id)"))
        return file
    }

    @discardableResult
    public func addFile(name: String, contents: Data, type: String = "image/png", mimeClass: String = "image") -> MiniFile {
        let id = nextId()
        let file = MiniFile(APIFile.make(
            id: id,
            display_name: name,
            filename: name,
            contentType: type,
            size: contents.count,
            mime_class: mimeClass
        ), contents: contents, baseURL: baseUrl)
        files[id.value] = file
        return file
    }
}
