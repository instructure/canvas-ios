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

import HorizonUI
import Foundation

struct ProgramCardModel: Identifiable {
    let id = UUID().uuidString
    let courseName: String
    let isEnrolled: Bool
    let isSelfEnrolled: Bool
    let isRequired: Bool
    let isLocked: Bool
    let estimatedTime: String?
    let dueDate: String?
    let status: HorizonUI.ProgramCard.Status
    var index = 0

    static var mocks: [Self] = [

        ProgramCardModel(
            courseName: "Completed iOS Architecture",
            isEnrolled: true,
            isSelfEnrolled: false,
            isRequired: true,
            isLocked: true,
            estimatedTime: "4h",
            dueDate: "Jul 30",
            status: .completed
        ),
        ProgramCardModel(
            courseName: "Introduction to SwiftUI",
            isEnrolled: false,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "3h",
            dueDate: "Aug 12",
            status: .completed
        ),

        ProgramCardModel(
            courseName: "Optional Deep Dive into Combine",
            isEnrolled: true,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "1.5 hours",
            dueDate: "20/10/2025 - 20/10/2026",
            status: .inProgress(completionPercent: 0.4)
        ),

        ProgramCardModel(
            courseName: "Course Name Dolor Sit Amet",
            isEnrolled: true,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .locked
        ),
        ProgramCardModel(
            courseName: "Course Name Dolor Sit Amet",
            isEnrolled: false,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .locked
        ),

        ProgramCardModel(
            courseName: "Course Name Dolor Sit Amet",
            isEnrolled: false,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .locked
        )
    ]

    static var mocks2: [Self] = [
        ProgramCardModel(
            courseName: "Completed iOS Architecture",
            isEnrolled: true,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: true,
            estimatedTime: "4h",
            dueDate: "Jul 30",
            status: .active
        ),
        ProgramCardModel(
            courseName: "Introduction to SwiftUI",
            isEnrolled: false,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "3h",
            dueDate: "Aug 12",
            status: .active
        ),

        ProgramCardModel(
            courseName: "Optional Deep Dive into Combine",
            isEnrolled: false,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .active
        ),

        ProgramCardModel(
            courseName: "Course Name Dolor Sit Amet",
            isEnrolled: true,
            isSelfEnrolled: false,
            isRequired: false,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .active
        ),
        ProgramCardModel(
            courseName: "Course Name Dolor Sit Amet",
            isEnrolled: true,
            isSelfEnrolled: false,
            isRequired: false,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .active
        ),

        ProgramCardModel(
            courseName: "Course Name Dolor Sit Amet",
            isEnrolled: false,
            isSelfEnrolled: true,
            isRequired: true,
            isLocked: false,
            estimatedTime: "1.5h",
            dueDate: "Aug 20",
            status: .locked
        )
    ]
}
