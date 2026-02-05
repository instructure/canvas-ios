//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

enum ProgressStatus: Int, CaseIterable {
    case all
    case notStarted
    case inProgress
    case completed

    init(progress: Double) {
        switch progress {
        case 100.0:
            self = .completed
        case 0.0:
            self = .notStarted
        default:
            self = .inProgress
        }
    }

    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .all
        case 1: self = .notStarted
        case 2: self = .inProgress
        default: self = .completed
        }
    }

    func title(for context: String) -> String {
        switch self {
        case .all: context
        case .notStarted: String(localized: "Not started", bundle: .horizon)
        case .inProgress: String(localized: "In progress", bundle: .horizon)
        case .completed: String(localized: "Completed", bundle: .horizon)
        }
    }

    static var courses: [OptionModel] {
        ProgressStatus.allCases.map { OptionModel(id: $0.rawValue, name: $0.title(for: String(localized: "All courses"))) }
    }

    static var programs: [OptionModel] {
        ProgressStatus.allCases.map { OptionModel(id: $0.rawValue, name: $0.title(for: String(localized: "All programs"))) }
    }

    static var firsCourseOption: OptionModel { .init(id: ProgressStatus.all.rawValue, name: String(localized: "All courses")) }
    static var firsProgramOption: OptionModel { .init(id: ProgressStatus.all.rawValue, name: String(localized: "All programs")) }
}
