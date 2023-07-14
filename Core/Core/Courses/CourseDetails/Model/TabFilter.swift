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

extension Array where Element == Tab {
    private var mobileSupportedTabs: [TabName] { [.assignments, .quizzes, .discussions, .announcements, .people, .pages, .files, .modules, .syllabus] }

    func filteredTabsForCourseHome(isStudent: Bool) -> [Tab] {
        var tabs = self

        if isStudent {
            tabs = tabs.filter { $0.hidden != true }
        } else {
            tabs = tabs.filter {
                if $0.id.contains("external_tool") {
                    return $0.hidden != true
                } else {
                    return mobileSupportedTabs.contains($0.name)
                }
            }
        }
        tabs.sort(by: { $0.position < $1.position })

        return tabs
    }

    func offlineSupportedTabs(isStudent: Bool = true) -> [Tab] {
        filteredTabsForCourseHome(isStudent: isStudent)
            .filter { TabName.OfflineSyncableTabs.contains($0.name) }
    }

    func isFilesTabEnabled() -> Bool {
        contains { $0.name == .files }
    }
}
