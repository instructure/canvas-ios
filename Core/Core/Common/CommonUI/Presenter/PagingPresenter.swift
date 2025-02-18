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

import UIKit
import Combine

public protocol PagingViewController: UIViewController {
    associatedtype Page: PageModel

    func isMoreRow(at indexPath: IndexPath) -> Bool
    func loadNextPage()
}

public protocol PageModel {
    var nextCursor: String? { get }
}

public class PagingPresenter<Controller: PagingViewController> {

    public var hasMore: Bool { endCursor != nil }
    public var isLoadingMore: Bool { isLoadingMoreSubject.value }
    public var isLoadingMorePublisher: AnyPublisher<Bool, Never> {
        isLoadingMoreSubject.eraseToAnyPublisher()
    }

    private var endCursor: String?
    private var isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private var loadedCursor: String?
    private unowned let controller: Controller

    public init(controller: Controller) {
        self.controller = controller
    }

    public func onPageLoaded(_ page: Controller.Page) {
        endCursor = page.nextCursor
        isLoadingMoreSubject.send(false)
    }

    public func onPageLoadingFailed() {
        isLoadingMoreSubject.send(false)
    }

    public func willDisplayRow(at indexPath: IndexPath) {
        guard controller.isMoreRow(at: indexPath), isLoadingMoreSubject.value == false else { return }
        guard let endCursor, endCursor != loadedCursor else { return }
        loadMore()
    }

    public func willSelectRow(at indexPath: IndexPath) {
        guard controller.isMoreRow(at: indexPath), isLoadingMoreSubject.value == false else { return }
        loadMore()
    }

    private func loadMore() {
        guard let endCursor else { return }

        loadedCursor = endCursor
        isLoadingMoreSubject.send(true)

        controller.loadNextPage()
    }
}
