//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public final class CourseTabUrlInteractor {

    private var enabledTabsPerCourse: [Context: [String]] = [:]

    public init() { }

    public func setEnabledCourseTabs(_ tabs: [APITab], context: Context) {
        guard context.contextType == .course else { return }

        var tabPaths = tabs.map { $0.html_url.absoluteString }

        // Adding extra paths for some tabs besides the ones from `html_url`.
        // Some have counterparts defined in `routes`, used only for in-app navigation or they are just legacy.
        // Some have related paths and they should be enabled/disabled together.
        tabs.forEach { tab in
            switch tab.id.value {
            case "syllabus":
                // proper path from `html_url`: "course/:courseID/assignments/syllabus"
                // internal path from `routes`: "course/:courseID/syllabus"
                tabPaths.append("/\(context.pathComponent)/syllabus")
            case "discussions":
                // proper path from `html_url`: "course/:courseID/discussion_topics"
                // internal path from `routes`: "course/:courseID/discussion"
                tabPaths.append("/\(context.pathComponent)/discussions")
            case "pages":
                // proper path from `html_url`: "course/:courseID/wiki"
                // related path also disabled on web: "course/:courseID/pages"
                tabPaths.append("/\(context.pathComponent)/pages")
                // related path also disabled on web: "course/:courseID/pages/front_page"
                tabPaths.append("/\(context.pathComponent)/pages/front_page")
                // internal path from `routes`: "course/:courseID/front_page"
                tabPaths.append("/\(context.pathComponent)/front_page")
            default:
                break
            }
        }

        enabledTabsPerCourse[context] = tabPaths
    }

    public func clearEnabledCourseTabs() {
        enabledTabsPerCourse = [:]
    }

    /// Returns `true` if `url` is not a course tab URL OR it is but it's not in the list of enabled course tab URLs.
    public func isAllowedUrl(_ url: URL) -> Bool {
        // if url doesn't match ""/courses/:courseID/*" for the known courses -> it's not a tab, allow it
        guard let context = Context(url: url), let enabledTabs = enabledTabsPerCourse[context] else {
            return true
        }

        let relativePath = String(url.relativePath.trimmingPrefix("/api/v1"))
        let parts = relativePath.split(separator: "/").map { String($0) }

        // if url doesn't even match known tab path formats -> it's not a tab, allow it
        guard CourseTabFormat.allCases.contains(where: { $0.isMatch(for: parts) }) else {
            return true
        }

        // it's a tab, if it matches any of the enabled tabs allow it, otherwise block it
        return enabledTabs.contains(relativePath)
    }
}

/// Known course tab formats
private enum CourseTabFormat: CaseIterable {
    case regularTab
    case syllabusTab
    case frontPage
    case externalToolTab

    func isMatch(for parts: [String]) -> Bool {
        switch self {

        case .regularTab:
            // example: "/courses/42/grades"
            guard parts.count == 3 else { return false }

            let lastPart = parts[2]
            let internalOnlyRouteComponents = [
                "tabs",
                "activity_stream"
            ]
            // if the last part matches an internal only suffix -> it's not a tab
            return !internalOnlyRouteComponents.contains(lastPart)

        case .syllabusTab:
            // example: "/courses/42/assignments/syllabus"
            return parts.count == 4 && parts[3] == "syllabus"

        case .frontPage:
            // example: "/courses/42/pages/front_page"
            return parts.count == 4 && parts[2] == "pages" && parts[3] == "front_page"

        case .externalToolTab:
            // example: "/courses/42/external_tools/1234"
            return parts.count == 4 && parts[2] == "external_tools"
        }
    }
}
