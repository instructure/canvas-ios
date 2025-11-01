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

/// This interactor purpose's to extract base URLs for courses. We use these
/// base URLs for API calls in case a course is on a different host compared
/// to the the one used to log in. Only applies to Courses & Groups.
public final class ContextBaseUrlInteractor {

    private var baseURLHostOverridesPerContext: [Context: String] = [:]
    private var tabSubscription: AnyCancellable?

    public init() { }

    public func setupTabSubscription() {
        let useCase = LocalUseCase<Tab>(scope: .all)
        tabSubscription = ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .sink { [weak self] tabs in
                self?.updateBaseUrlHosts(with: tabs)
            }
    }

    public func cancelTabSubscription() {
        tabSubscription?.cancel()
        tabSubscription = nil
    }

    // MARK: - Enabled tab list

    private func updateBaseUrlHosts(with tabs: [Tab]) {
        let contextTabs = tabs.filter {
            $0.context.contextType == .course ||
            $0.context.contextType == .group
        }

        let tabsPerContext = Dictionary(grouping: contextTabs, by: { $0.context })
        let defaultHost = AppEnvironment.shared.apiHost

        baseURLHostOverridesPerContext = tabsPerContext
            .reduce(into: [:], { partialResult, pair in
                pair.value.forEach { tab in
                    guard let apiHost = tab.apiBaseURL?.host(), apiHost != defaultHost else { return }
                    partialResult[pair.key] = apiHost
                }
            })
    }

    // MARK: Base URL Overrides

    public var baseURLHostOverrides: Set<String> {
        Set(baseURLHostOverridesPerContext.values)
    }

    public func baseUrlHostOverride(for url: URLComponents) -> String? {
        guard let context = Context(path: url.path) else { return nil }

        // Check if it is internal link in a course
        if url.path.hasSuffix(context.pathComponent) { return nil }

        return baseURLHostOverridesPerContext.first(where: {
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

            let overrideContexts = baseURLHostOverridesPerContext
                .filter { $0.value == urlHost } // It's possible to have multiple contexts with the same `value`
                .map { $0.key }

            // ShardID would be the same for all contexts sharing the same overridden host value
            if let shardID = overrideContexts.compactMap(\.id.shardID).first {
                return shardID
            }
        }

        if let pathContext {

            let overrideContexts = baseURLHostOverridesPerContext
                .filter { $0.key.isEquivalent(to: pathContext) } // It's possible to have multiple equivalent contexts
                .map { $0.key }

            if let shardID = overrideContexts.compactMap(\.id.shardID).first {
                return shardID
            }
        }

        return nil
    }
}
