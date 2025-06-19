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

enum CourseDetailsTabs: Int, CaseIterable, Identifiable {
    case overview
    case myProgress
    case scores
    case notebook
    //  case quickLinks

    var localizedString: String {
        switch self {
        case .myProgress:
            return String(localized: "My Progress", bundle: .horizon)
        case .overview:
            return String(localized: "Overview", bundle: .horizon)
        case .scores:
            return String(localized: "Scores", bundle: .horizon)
        case .notebook:
            return String(localized: "Notebook", bundle: .horizon)
        // case .quickLinks:
            // return String(localized: "Quick Links", bundle: .horizon)
        }
    }

    var id: Self {
        self
    }
}
