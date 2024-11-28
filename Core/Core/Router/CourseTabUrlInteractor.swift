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
import Combine

public final class CourseTabUrlInteractor {

    private struct TabModel {
        let id: String
        let htmlUrl: String
    }

    private var enabledTabsPerCourse: [Context: [String]] = [:]
    private var subscriptions = Set<AnyCancellable>()

    public init() { }

    public func setupTabSubscription() {
        let useCase = LocalUseCase<Tab>(scope: .all)
        ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .sink { [weak self] tabs in
                self?.updateEnabledTabs(with: tabs)
            }
            .store(in: &subscriptions)
    }

    public func clearEnabledTabs() {
        enabledTabsPerCourse = [:]
    }

    /// Returns `true` if `url` is not a course tab URL OR it is but it's not in the list of enabled course tab URLs.
    public func isAllowedUrl(_ url: URL) -> Bool {
        // if url doesn't match ""/courses/:courseID/*" for the known courses -> it's not a tab, allow it
        guard let context = Context(url: url), let enabledTabs = enabledTabsPerCourse[context] else {
            return true
        }

        let relativePath = String(url.relativePath.trimmingPrefix("/api/v1"))

        // if url doesn't even match known tab path formats -> it's not a tab, allow it
        guard isKnownPathFormat(relativePath) else {
            return true
        }

        // it's a tab, if it matches any of the enabled tabs allow it, otherwise block it
        return enabledTabs.contains(relativePath)
    }

    /// Expects relative paths, with "/api/v1" already stripped
    private func isKnownPathFormat(_ path: String) -> Bool {
        let parts = path.split(separator: "/").map { String($0) }
        return CourseTabFormat.allCases.contains {
            $0.isMatch(for: parts)
        }
    }

    private func updateEnabledTabs(with tabs: [Tab]) {
        let tabsPerContext = Dictionary(grouping: tabs, by: { $0.context })

        let tabModelsPerCourse: [Context: [TabModel]] = tabsPerContext.mapValues { tabArray in
            tabArray.compactMap { tab in
                guard tab.context.contextType == .course, let htmlURL = tab.htmlURL else { return nil }

                return TabModel(id: tab.id, htmlUrl: htmlURL.absoluteString)
            }
        }

        tabModelsPerCourse.forEach { context, tabs in
            let tabPaths = pathsForTabs(tabs, context: context)
            enabledTabsPerCourse[context] = tabPaths
        }
    }

    private func pathsForTabs(_ tabs: [TabModel], context: Context) -> [String] {
        // adding backend-provided paths from `html_url`
        var tabPaths = tabs.map {
            logPathFormatIfUnknown(for: $0)
            return $0.htmlUrl
        }

        // Adding extra paths for some tabs besides the ones from `html_url`.
        // Some have counterparts defined in `routes`, used only for in-app navigation or they are just legacy.
        // Some have related paths and they should be enabled/disabled together.
        tabs.forEach { tab in
            switch tab.id {
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

        return tabPaths
    }

    private func logPathFormatIfUnknown(for tab: TabModel) {
        guard tab.id != "home" && !isKnownPathFormat(tab.htmlUrl) else { return }

        RemoteLogger.shared.logError(
            name: "Unexpected Course Tab path format",
            reason: "tab.id: \(tab.id), tab.html_url: \(tab.htmlUrl), baseUrl: \(Analytics.analyticsBaseUrl)"
        )
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
            return parts.count == 4 && parts[2] == "assignments" && parts[3] == "syllabus"

        case .frontPage:
            // example: "/courses/42/pages/front_page"
            return parts.count == 4 && parts[2] == "pages" && parts[3] == "front_page"

        case .externalToolTab:
            // example: "/courses/42/external_tools/1234"
            return parts.count == 4 && parts[2] == "external_tools"
        }
    }
}
