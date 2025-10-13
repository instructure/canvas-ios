//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Horizon
import Foundation

enum HActivityStub {
    static var activity: HActivity {
        .init(
            id: "1",
            title: "New Assignment for History",
            message: "Messsage 1",
            date: Date(),
            type: .announcement,
            courseId: "123",
            isRead: true,
            announcementId: "123",
            assignmentURL: URL(string: "https://example.com"),
            htmlURL: URL(string: "https://example.com")
        )
    }

    static var activities: [HActivity] {
        [
            .init(
                id: "1",
                title: "New Assignment for History",
                message: "Message 1",
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                type: .announcement,
                courseId: "1",
                isRead: true,
                announcementId: "123",
                assignmentURL: URL(string: "https://example.com/assignment1"),
                htmlURL: URL(string: "https://example.com/announcement1")
            ),
            .init(
                id: "2",
                title: "Math Quiz Due Tomorrow",
                message: "Reminder: Quiz 3 is due tomorrow at midnight.",
                date: Date(),
                score: "10/10",
                type: .assessmentRequest,
                courseId: "2",
                isRead: false,
                announcementId: nil,
                assignmentURL: URL(string: "https://example.com/quiz3"),
                htmlURL: URL(string: "https://example.com/assignment2")
            ),
            .init(
                id: "3",
                title: "Course Update",
                message: "Syllabus updated for Biology 101.",
                date: Date.fromISO8601("2025-09-24T06:27:18Z"),
                type: .announcement,
                notificationCategory: "Grading Policies",
                courseId: "3",
                isRead: false,
                announcementId: "789-ann",
                assignmentURL: nil,
                htmlURL: URL(string: "https://example.com/biology-update")
            ),
            .init(
                id: "4",
                title: "Discussion Reply",
                message: "Someone replied to your comment in Philosophy discussion.",
                date: Date.fromISO8601("2025-07-24T06:27:18Z"),
                type: .discussion,
                notificationCategory: "Grading Policies",
                courseId: "4",
                isRead: true,
                announcementId: nil,
                assignmentURL: nil,
                htmlURL: URL(string: "https://example.com/discussion")
            ),
            .init(
                id: "5",
                title: "Graded: Chemistry Lab Report",
                message: "Your grade for Lab Report 2 has been posted.",
                date: Date(),
                type: .message,
                notificationCategory: "Due Date",
                courseId: "5",
                isRead: true,
                announcementId: nil,
                assignmentURL: URL(string: "https://example.com/lab-report"),
                htmlURL: URL(string: "https://example.com/grades")
            )
        ]
    }
}
fileprivate extension Date {
    static func fromISO8601(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)!
    }
}
