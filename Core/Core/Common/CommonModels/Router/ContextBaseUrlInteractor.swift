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

import Foundation
import Combine

/// This interactor purpose is to extract base URLs for courses. We use these base URLs for API calls in case a course is on a different host compared to the the one used to log in. Only applies to Courses & Groups.
public final class ContextBaseUrlInteractor {

    private struct TabModel {
        let id: String
        let htmlUrl: String
        let apiBaseUrlHost: String?
    }

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

    // MARK: Base URL Overrides

    public var baseURLHostOverrides: Set<String> {
        Set(baseURLHostOverridesPerCourse.values)
    }

    public func baseUrlHostOverride(for url: URLComponents) -> String? {
        guard let context = Context(path: url.path) else { return nil }

        // Check if it is internal link in a course
        if url.path.hasSuffix(context.pathComponent) { return nil }

        return baseURLHostOverridesPerCourse.first(where: {
            return $0.key.isEquivalent(to: context)
        })?.value
    }

    public func contextShardID(for url: URLComponents) -> String? {
        let pathContext = Context(path: url.path)

        if let pathContext,
           pathContext.contextType == .course || pathContext.contextType == .group,
           let shardID = pathContext.id.shardID {
            return shardID
        }

        if let urlHost = url.host {

            let overrideContexts = baseURLHostOverridesPerCourse
                .filter { $0.value == urlHost } // It's possible to have multiple contexts with the same `value`
                .map { $0.key }

            if let shardID = overrideContexts.compactMap(\.id.shardID).first {
                return shardID
            }
        }

        if let pathContext {

            let overrideContexts = baseURLHostOverridesPerCourse
                .filter { $0.key.isEquivalent(to: pathContext) } // It's possible to have multiple equivalent contexts
                .map { $0.key }

            if let shardID = overrideContexts.compactMap(\.id.shardID).first {
                return shardID
            }
        }

        return nil
    }
}
