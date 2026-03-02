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

import Observation

protocol ProgressStatusProvidable {
    var name: String { get }
    var status: ProgressStatus { get }
}

@Observable
final class PaginatedDataSource<Item> {
    // MARK: - Outputs

   var visibleItems: [Item] = []
    private(set) var isSeeMoreVisible: Bool = false

    // MARK: - Private

    private var allItems: [Item] = []
    private var pages: [[Item]] = []
    private var pageSize: Int
    var currentPage: Int = 0 {
        didSet {
            updateSeeMoreVisibility()
        }
    }

    // MARK: - Init

    init(
        items: [Item],
        pageSize: Int = 10
    ) {
        self.pageSize = pageSize
        self.setItems(items)
    }

    func setItems(_ items: [Item], currentPage: Int = 0) {
        self.allItems = items
        self.apply(items: allItems, currentPage: currentPage)
    }

    func apply(items: [Item], currentPage: Int = 0) {
        self.pages = items.chunked(into: pageSize)
        self.currentPage = currentPage
        self.visibleItems = pages.first ?? []
        updateSeeMoreVisibility()
    }

    func seeMore() {
        guard currentPage + 1 < pages.count else { return }
        currentPage += 1
        visibleItems.append(contentsOf: pages[currentPage])
    }

    private func updateSeeMoreVisibility() {
        isSeeMoreVisible = currentPage < pages.count - 1
    }
}

extension PaginatedDataSource where Item: ProgressStatusProvidable {
    func applyFilters(query: String, status: OptionModel) {
        let filteredByStatus = filterBy(status: ProgressStatus(rawValue: status.id))

        guard !query.isEmpty else {
            apply(items: filteredByStatus)
            return
        }

        let searched = filteredByStatus.filter { item in
            item.name.localizedCaseInsensitiveContains(query)
        }

        apply(items: searched)
    }

    private func filterBy(status: ProgressStatus) -> [Item] {
        switch status {
        case .all:
            return allItems
        case .completed:
            return allItems.filter { $0.status == .completed }
        case .notStarted:
            return allItems.filter { $0.status == .notStarted }
        case .inProgress:
            return allItems.filter { $0.status == .inProgress }
        }
    }
}

extension PaginatedDataSource where Item: PaginatedDataSourceSearchable {
    func search(query: String) {
        guard query.isNotEmpty else {
            apply(items: allItems)
            return
        }

        let searched = allItems.filter { item in
            item.name.localizedCaseInsensitiveContains(query)
        }
        apply(items: searched)
    }
}

protocol PaginatedDataSourceSearchable {
    var name: String { get }
}
