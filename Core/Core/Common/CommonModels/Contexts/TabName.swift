//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

// These are the currently supported tabs on mobile
public enum TabName: String, Codable {
    case assignments
    case quizzes
    case discussions
    case announcements
    case people
    case pages
    case files
    case modules
    case syllabus
    case collaborations
    case conferences
    case outcomes
    case custom
    case grades
    case search
    case additionalContent
}

public enum SyncTab: CaseIterable {
    case assignments
    case pages
    case files
    case grades
    case syllabus
    case conferences
    case announcements
    case people
    case quizzes
    case discussions
    case modules
    case studio
    case additionalContent

    init?(name: TabName) {
        switch name {
        case .assignments:
            self = .assignments
        case .pages:
            self = .pages
        case .files:
            self = .files
        case .grades:
            self = .grades
        case .syllabus:
            self = .syllabus
        case .conferences:
            self = .conferences
        case .announcements:
            self = .announcements
        case .people:
            self = .people
        case .quizzes:
            self = .quizzes
        case .discussions:
            self = .discussions
        case .modules:
            self = .modules
        case .additionalContent:
            self = .additionalContent
        case .collaborations, .outcomes, .custom, .search:
            return nil
        }
    }

    public static let offlineSyncableTabs: [SyncTab] = [
        .assignments,
        .pages,
        .files,
        .grades,
        .syllabus,
        .conferences,
        .announcements,
        .people,
        .quizzes,
        .discussions,
        .modules
    ]

    var tabName: TabName? {
        switch self {
        case .assignments: .assignments
        case .pages: .pages
        case .files: .files
        case .grades: .grades
        case .syllabus: .syllabus
        case .conferences: .conferences
        case .announcements: .announcements
        case .people: .people
        case .quizzes: .quizzes
        case .discussions: .discussions
        case .modules: .modules
        case .studio: nil
        case .additionalContent: .additionalContent
        }
    }
}
