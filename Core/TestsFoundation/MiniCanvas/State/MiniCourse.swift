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

@testable import Core
import UIKit

public class MiniCourse {
    public var api: APICourse
    private(set) public var assignments: [MiniAssignment] = []
    public var quizzes: [MiniQuiz] = []
    public var assignmentGroups: [APIAssignmentGroup] = []
    public var tabs: [APITab]
    public var externalTools: [APIExternalTool] = []
    public var gradingPeriods: [APIGradingPeriod] = []
    public var featureFlags: [String] = []
    public var conferences: [APIConference] = []
    public var pages: [APIPage] = []
    public var courseFiles: MiniFolder?
    public var contentLicenses: [Any] = []
    public var settings: APICourseSettings = .make()
    public var discussions: [MiniDiscussion] = []

    public var id: String { api.id.value }

    public func assignment(byId id: String?) -> MiniAssignment? {
        assignments.first { $0.id == id }
    }
    public func quiz(byId id: String?) -> MiniQuiz? {
        quizzes.first { $0.id == id }
    }

    public func add(assignment: MiniAssignment, toGroupAtIndex index: Int = 0) {
        assignments.append(assignment)
        if assignmentGroups[index].assignments == nil {
            assignmentGroups[index].assignments = []
        }
        assignmentGroups[index].assignments!.append(assignment.api)
    }
    public func removeAllAssignments() {
        assignments = []
        for var group in assignmentGroups {
            group.assignments = []
        }
    }

    public static func create(_ api: APICourse, populatingState state: MiniCanvasState) {
        let course = MiniCourse(api)
        state.courses.append(course)

        func makeAssignment(name: String) -> MiniAssignment {
            MiniAssignment(APIAssignment.make(course_id: api.id, id: state.nextId(), name: name), state: state)
        }

        course.gradingPeriods = [
            .make(id: state.nextId(), title: "Grading Period 1"),
            .make(id: state.nextId(), title: "Grading Period 2")
        ]
        course.assignmentGroups = [
            .make(id: state.nextId(), name: "group 0", position: 0),
            .make(id: state.nextId(), name: "group 1", position: 1)
        ]

        course.add(assignment: makeAssignment(name: "Assignment 1"), toGroupAtIndex: 0)
        course.add(assignment: makeAssignment(name: "Assignment 2"), toGroupAtIndex: 0)
        course.add(assignment: makeAssignment(name: "Assignment 3"), toGroupAtIndex: 1)

        course.assignments[0].submissions = state.students.map { student in
            MiniSubmission(APISubmission.make(
                assignment_id: course.assignments[0].api.id.value,
                attempt: 1,
                body: "A submission from \(student.name)",
                id: state.nextId().value,
                submission_history: [],
                submission_type: .online_text_entry,
                user: student,
                user_id: student.id.value
            ))
        }

        course.createQuizAssignment(state: state)

        state.customColors["course_\(course.id)"] = state.colorForId(id: course.id)
        for student in state.students {
            state.enroll(student, intoCourse: course, as: "StudentEnrollment")
        }
        state.enroll(state.teachers[0], intoCourse: course, as: "TeacherEnrollment")
        state.enroll(state.observers[0], intoCourse: course, as: "ObserverEnrollment", observing: state.students[0])

        for i in 0...1 {
            let pageId = state.nextId()
            course.pages.append(APIPage.make(
                body: "This is a page!",
                editing_roles: "teacher",
                front_page: i == 0,
                html_url: URL(string: "/courses/\(course.id)/pages/page-\(pageId)")!,
                page_id: pageId,
                title: "Page \(pageId)",
                url: "page-\(pageId)"
            ))
        }

        let folderID = state.nextId()
        let folder = MiniFolder(APIFolder.make(
            context_type: "Course",
            context_id: course.api.id,
            folders_url: state.baseUrl.appendingPathExtension("/api/v1/folders/\(folderID)/folders"),
            files_url: state.baseUrl.appendingPathExtension("/api/v1/folders/\(folderID)/files"),
            full_name: "course files",
            id: folderID,
            name: "course files"
        ))
        state.folders[folder.id] = folder
        course.courseFiles = folder

        let file = MiniFile(
            APIFile.make(
                id: state.nextId(),
                folder_id: folderID,
                display_name: "hamburger",
                filename: "hamburger.jpg"
            ),
            contents: UIImage.hamburgerLine.pngData()!,
            baseURL: state.baseUrl
        )
        state.files[file.id] = file
        folder.fileIDs.append(file.id)

        let topicID = state.nextId()
        let topic = APIDiscussionTopic.make(
            html_url: state.baseUrl.appendingPathComponent("/course/\(course.id)/discussion_topics/\(topicID)"),
            id: topicID,
            permissions: .make(attach: true, update: true, reply: true, delete: true)
        )
        course.discussions.append(MiniDiscussion.create(topic, populatingState: state))
    }

    func createQuizAssignment(state: MiniCanvasState) {
        let assignmentId = state.nextId()
        let assignment = MiniAssignment(APIAssignment.make(
            course_id: api.id,
            id: assignmentId,
            name: "quiz assignment \(assignmentId)",
            submission_types: [ .online_quiz ]
        ), state: state)
        add(assignment: assignment, toGroupAtIndex: 0)

        let quizId: ID = state.nextId()
        let quizUrl = URL(string: "\(state.baseUrl)/courses/\(id)/quizzes/\(quizId)")!
        let quiz = MiniQuiz(APIQuiz.make(
            assignment_id: assignment.api.id,
            html_url: quizUrl,
            id: quizId,
            mobile_url: quizUrl,
            quiz_type: .assignment
        ))

        for student in state.students {
            let submissionId = state.nextId()
            let data = "A webview submission from \(student.name)".data(using: .utf8)!.base64EncodedString()
            let previewUrl = URL(string: "data:text/plain;base64,\(data)")!
            let submission = MiniSubmission(
                APISubmission.make(
                    assignment_id: assignment.api.id.value,
                    attempt: 1,
                    id: submissionId.value,
                    preview_url: previewUrl,
                    submission_history: [],
                    submission_type: .online_quiz,
                    user_id: student.id.value
                ),
                associatedQuizSubmission: APIQuizSubmission.make(
                    attempt: 1,
                    finished_at: Date(timeIntervalSince1970: 0),
                    id: state.nextId(),
                    quiz_id: api.id,
                    submission_id: submissionId,
                    user_id: student.id,
                    workflow_state: .pending_review
                )
            )
            assignment.submissions.append(submission)
            assignment.api.submission = [submission.api]
            quiz.submissions.append(submission)
        }
        quizzes.append(quiz)
    }

    public init(_ course: APICourse) {
        self.api = course
        tabs = [
            "announcements", "assignments", "discussions", "files",
            "grades", "modules", "pages", "people", "quizzes", "conferences"
        ].map { tabName in
            APITab.make(
                id: ID(tabName),
                html_url: URL(string: "/courses/\(course.id)/\(tabName)")!,
                full_url: URL(string: "/courses/\(course.id)/\(tabName)")!,
                label: "\(tabName.capitalized)"
            )
        }
    }
}
