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

    public static let OfflineSyncableTabs: [TabName] = [
        .assignments,
        .pages,
        .files,
        .grades,
        .syllabus,
        .conferences,
        .announcements,
        .quizzes,
        .discussions,
    ]
}
