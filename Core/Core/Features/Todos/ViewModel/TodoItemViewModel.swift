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

import SwiftUI
import Combine

public class TodoItemViewModel: Identifiable, Equatable, Comparable, ObservableObject {

    public enum MarkDoneState: Equatable {
        case notDone
        case loading
        case done
    }

    /// This is the view identity that might change. Don't use this for business logic.
    public private(set) var id: String = UUID.string
    public let type: PlannableType
    public let date: Date
    public let dateText: String

    public let title: String
    public let subtitle: String?
    public let contextName: String
    public let htmlURL: URL?

    public let color: Color
    public let icon: Image

    public let plannableId: String
    public let plannableType: String
    public var overrideId: String?

    @Published public var markDoneState: MarkDoneState = .notDone

    public init?(_ plannable: Plannable, course: Course? = nil) {
        guard let date = plannable.date else { return nil }

        self.plannableId = plannable.id
        self.type = plannable.plannableType
        self.date = date
        self.dateText = date.timeOnlyString

        self.title = plannable.title ?? ""
        self.subtitle = plannable.discussionCheckpointStep?.text

        // Use course-based contextName if course is provided, otherwise use plannable context
        self.contextName = Self.contextName(
            isCourseNameNickname: course?.hasNickName ?? false,
            courseName: course?.name,
            courseCode: course?.courseCode,
            fallback: plannable.contextNameUserFacing ?? ""
        )

        self.htmlURL = plannable.htmlURL

        self.color = plannable.color.asColor
        self.icon = plannable.icon.asImage

        self.plannableType = plannable.typeRaw
        self.overrideId = plannable.plannerOverrideId
        self.markDoneState = plannable.isMarkedComplete ? .done : .notDone
    }

    public init(
        plannableId: String,
        type: PlannableType,
        date: Date,
        title: String,
        subtitle: String?,
        contextName: String,
        htmlURL: URL?,
        color: Color,
        icon: Image,
        plannableType: String = "assignment",
        overrideId: String? = nil
    ) {
        self.plannableId = plannableId
        self.type = type
        self.date = date
        self.dateText = date.timeOnlyString

        self.title = title
        self.subtitle = subtitle
        self.contextName = contextName
        self.htmlURL = htmlURL

        self.color = color
        self.icon = icon

        self.plannableType = plannableType
        self.overrideId = overrideId
    }

    /// Resets the view identity to force SwiftUI to recreate the view.
    /// This is necessary when an item is restored after being marked as done to ensure
    /// the view is fully re-created. Without this, SwiftUI reuses the old
    /// view instance where the swipe gesture is already in the fully swiped state.
    public func resetViewIdentity() {
        id = UUID.string
    }

    public var markAsDoneAccessibilityLabel: String? {
        switch markDoneState {
        case .notDone:
            return String(localized: "Mark as done", bundle: .core)
        case .loading:
            return nil
        case .done:
            return String(localized: "Mark as not done", bundle: .core)
        }
    }

    /// Helper function to determine the context name for a Todo item.
    /// - Parameters:
    ///   - isCourseNameNickname: Whether the course name is a user-given nickname.
    ///   - courseName: The course name (which may be a nickname if isCourseNameNickname is true).
    ///   - courseCode: The course code.
    ///   - fallback: Fallback value if no course data is available.
    /// - Returns: The appropriate context name.
    public static func contextName(
        isCourseNameNickname: Bool,
        courseName: String?,
        courseCode: String?,
        fallback: String = ""
    ) -> String {
        if isCourseNameNickname {
            return courseName ?? fallback
        } else {
            return courseCode ?? courseName ?? fallback
        }
    }

    // MARK: - Equatable

    public static func == (lhs: TodoItemViewModel, rhs: TodoItemViewModel) -> Bool {
        lhs.plannableId == rhs.plannableId &&
        lhs.type == rhs.type &&
        lhs.date == rhs.date &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.contextName == rhs.contextName &&
        lhs.htmlURL == rhs.htmlURL &&
        lhs.color == rhs.color &&
        lhs.markDoneState == rhs.markDoneState
    }

    // MARK: - Comparable

    public static func < (lhs: TodoItemViewModel, rhs: TodoItemViewModel) -> Bool {
        lhs.date < rhs.date
    }
}

#if DEBUG

// MARK: Preview & Testing

extension TodoItemViewModel {

    public static func make(
        plannableId: String = "1",
        type: PlannableType = .assignment,
        date: Date = Clock.now,
        title: String = "Calculate how far the Millennium Falcon actually traveled in less than 12 parsecs",
        subtitle: String? = "This is a longer subtitle that should be truncated in compact mode",
        contextName: String = "FORC 101 or something longer to even show it in two lines",
        htmlURL: URL? = nil,
        color: Color = .red,
        icon: Image = .assignmentLine,
        plannableType: String = "assignment",
        overrideId: String? = nil
    ) -> TodoItemViewModel {
        TodoItemViewModel(
            plannableId: plannableId,
            type: type,
            date: date,
            title: title,
            subtitle: subtitle,
            contextName: contextName,
            htmlURL: htmlURL,
            color: color,
            icon: icon,
            plannableType: plannableType,
            overrideId: overrideId
        )
    }

    public static func makeShortText(
        plannableId: String = "1",
        type: PlannableType = .assignment,
        date: Date = Clock.now,
        title: String = "Quiz 1",
        subtitle: String? = "Due today",
        contextName: String = "Math 101",
        htmlURL: URL? = nil,
        color: Color = .blue,
        icon: Image = .quizLine
    ) -> TodoItemViewModel {
        TodoItemViewModel(
            plannableId: plannableId,
            type: type,
            date: date,
            title: title,
            subtitle: subtitle,
            contextName: contextName,
            htmlURL: htmlURL,
            color: color,
            icon: icon
        )
    }

    public static func makeLongText(
        plannableId: String = "1",
        type: PlannableType = .assignment,
        date: Date = Clock.now,
        title: String = "Complete comprehensive reading assignment covering advanced mathematical concepts and theoretical applications",
        subtitle: String? = "Read chapters 5-7 including all exercises, supplementary materials, and prepare detailed notes for the upcoming examination period",
        contextName: String = "Advanced Mathematics and Theoretical Applications - Professor Johnson",
        htmlURL: URL? = nil,
        color: Color = .green,
        icon: Image = .assignmentLine
    ) -> TodoItemViewModel {
        TodoItemViewModel(
            plannableId: plannableId,
            type: type,
            date: date,
            title: title,
            subtitle: subtitle,
            contextName: contextName,
            htmlURL: htmlURL,
            color: color,
            icon: icon
        )
    }
}

#endif
