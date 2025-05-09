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

/// This interactor has two purposes
/// - Provide info on hidden tabs for routing. When routing we shouldn't allow routes for disabled tabs.
/// - Extract base URLs for courses. We use these base URLs for API calls in case a course is on a different host compared to the the one used to log in.
public final class CourseTabUrlInteractor {

    public static let blockDisabledTabUserInfoKey = "shouldBlockDisabledCourseTabKey"
    public static let allowExternalToolsInnerLinksKey = "allowExternalToolsInnerLinksKey"

    private struct TabModel {
        let id: String
        let htmlUrl: String
        let apiBaseUrlHost: String?
    }

    private var enabledTabsPerCourse: [Context: [String]] = [:]
    private var baseURLHostOverridesPerCourse: [Context: String] = [:]
    private var tabSubscription: AnyCancellable?

    public init() { }

    public func setupTabSubscription() {
        let useCase = LocalUseCase<Tab>(scope: .all)
        tabSubscription = ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .sink { [weak self] tabs in
                self?.updateEnabledTabs(with: tabs)
            }
    }

    public func cancelTabSubscription() {
        tabSubscription?.cancel()
        tabSubscription = nil
    }

    public func clearEnabledTabs() {
        enabledTabsPerCourse = [:]
    }

    // MARK: - Allow / Block URL

    /// Returns `true` if `url` is not a course tab URL OR it is but it's not in the list of enabled course tab URLs.
    public func isAllowedUrl(_ url: URL, userInfo: [String: Any]?) -> Bool {
        // if there is an override in `userInfo` -> allow url
        if let userInfo,
           let shouldBlock = userInfo[Self.blockDisabledTabUserInfoKey] as? Bool,
           shouldBlock == false {
            return true
        }

        // if url doesn't match "/courses/:courseID/*" for the known courses -> it's not a tab, allow it
        guard let context = Context(url: url), let enabledTabs = enabledTabsPerCourse[context] else {
            return true
        }

        var relativePath = String(url.relativePath.trimmingPrefix("/api/v1"))

        // handle already relative URLs without starting slash
        if relativePath.hasPrefix("course") {
            relativePath = "/" + relativePath
        }

        // if url doesn't even match known tab path formats -> it's not a tab, allow it
        guard isKnownPathFormat(relativePath) else {
            return true
        }

        // if it's a tab that can only be hidden but never disabled -> allow it
        if isHideOnlyTab(relativePath) {
            return true
        }

        if isAllowedAsExternalToolLink(relativePath, context: context, userInfo: userInfo) {
            return true
        }

        // it's a tab that may be disabled, if it matches any of the enabled tabs allow it, otherwise block it
        return enabledTabs.contains(relativePath)
    }

    /// Allows links to external tools when `allowExternalToolsInnerLinksKey` of `userInfo` is `true`.
    /// Ideally, this is needed only for links found in inner course pages.
    /// Expects relative path, with "/api/v1" already stripped,
    private func isAllowedAsExternalToolLink(
        _ relativePath: String,
        context: Context,
        userInfo: [String: Any]?
    ) -> Bool {
        guard
            let isExternalToolsAllowed = userInfo?[Self.allowExternalToolsInnerLinksKey] as? Bool,
            isExternalToolsAllowed else { return false }
        return relativePath.hasPrefix("/\(context.pathComponent)/external_tools/")
    }

    /// Expects relative paths, with "/api/v1" already stripped
    private func isKnownPathFormat(_ path: String) -> Bool {
        let parts = path.splitUsingSlash
        return CourseTabFormat.allCases.contains {
            $0.isMatch(for: parts)
        }
    }

    /// Checks for tabs which can't be disabled, only hidden.
    /// These tabs should always be allowed to visit, they are simply removed from the Course Tab list.
    private func isHideOnlyTab(_ path: String) -> Bool {
        let parts = path.splitUsingSlash
        return parts.count == 3
            && (parts[2] == "discussion_topics" || parts[2] == "grades")
    }

    // MARK: - Enabled tab list

    private func updateEnabledTabs(with tabs: [Tab]) {
        let courseTabs = tabs.filter { $0.context.contextType == .course }
        let tabsPerCourse = Dictionary(grouping: courseTabs, by: { $0.context })

        let tabModelsPerCourse: [Context: [TabModel]] = tabsPerCourse.mapValues { tabArray in
            tabArray.compactMap { tab in
                guard let htmlURL = tab.htmlURL else { return nil }
                return TabModel(
                    id: tab.id,
                    htmlUrl: htmlURL.removingQueryAndFragment().absoluteString,
                    apiBaseUrlHost: tab.apiBaseURL?.host()
                )
            }
        }

        tabModelsPerCourse.forEach { context, tabs in
            let tabPaths = pathsForTabs(tabs, context: context)
            enabledTabsPerCourse[context] = tabPaths
        }

        let defaultHost = AppEnvironment.shared.apiHost

        baseURLHostOverridesPerCourse =
            tabModelsPerCourse
            .reduce(into: [:], { partialResult, pair in
                pair.value.forEach { tab in
                    guard let apiHost = tab.apiBaseUrlHost, apiHost != defaultHost else { return }
                    partialResult[pair.key] = apiHost
                }
            })
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

    // MARK: - Unknown format logging

    private func logPathFormatIfUnknown(for tab: TabModel) {
        if isExcludedFromLogging(tab) || isKnownPathFormat(tab.htmlUrl) {
            return
        }

        RemoteLogger.shared.logError(
            name: "Unexpected Course Tab path format",
            reason: "tab.id: \(tab.id), tab.html_url: \(tab.htmlUrl), baseUrl: \(Analytics.analyticsBaseUrl)"
        )
    }

    private func isExcludedFromLogging(_ tab: TabModel) -> Bool {
        let excludedTabIDs = [
            "home", // all responses have this enabled tab, no need to log it
            "settings" // Teachers logging into Student app have this enabled tab, no need to log it
        ]
        if excludedTabIDs.contains(tab.id) {
            return true
        }

        let parts = tab.htmlUrl.splitUsingSlash

        // Exclude tabs matching the Home format: "/courses/:courseID"
        // For example K5Subject tabs: "/courses/:courseID#schedule"
        if parts.count == 2 && parts[0] == "courses" {
            return true
        }

        // Exclude tabs matching the LTI launch request format: "/courses/:courseID/lti/basic_lti_launch_request/:ltiID
        // These are not disabled at the moment, just collected here in case they need to be
        // example tab.id: "lti/message_handler_123", tab.html_url: "/courses/42/lti/basic_lti_launch_request/123?resource_link_fragment=nav"
        if parts.count == 5 && parts[2] == "lti" && parts[3] == "basic_lti_launch_request" {
            return true
        }

        return false
    }

    // MARK: Base URL Overrides

    public var baseURLHostOverrides: Set<String> {
        Set(baseURLHostOverridesPerCourse.values)
    }

    public func baseUrlHostOverride(for url: URLComponents) -> String? {
        guard let context = Context(path: url.path) else { return nil }
        return baseURLHostOverridesPerCourse.first(where: {
            return $0.key.isEquivalent(to: context)
        })?.value
    }
}

// MARK: - CourseTabFormat

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
            let nonTabRouteComponents = [
                "tabs",
                "activity_stream",
                "settings",
                "details"
            ]
            // if the last part matches a known non-tab suffix -> it's not a tab
            return !nonTabRouteComponents.contains(lastPart)

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

// MARK: - Helpers

private extension String {
    var splitUsingSlash: [String] {
        split(separator: "/").map { String($0) }
    }
}

private extension URL {
    func removingQueryAndFragment() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        components.query = nil
        components.fragment = nil

        return components.url ?? self
    }
}
