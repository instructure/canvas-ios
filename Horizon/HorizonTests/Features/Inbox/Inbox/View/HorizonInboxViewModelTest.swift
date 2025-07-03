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

import Combine
import CombineExt
import Core
import CoreData
import Testing
import SwiftUI

@testable import Horizon

final class MockAnnouncementsInteractor: AnnouncementsInteractor {
    var messages = CurrentValueRelay<[Announcement]>([])
    var state = CurrentValueRelay<StoreState>(.data)
}

final class MockInboxMessageInteractor: InboxMessageInteractor {
    var state = CurrentValueSubject<StoreState, Never>(.data)
    var messages = CurrentValueSubject<[InboxMessageListItem], Never>([])
    var courses = CurrentValueSubject<[InboxCourse], Never>([])
    var hasNextPage = CurrentValueSubject<Bool, Never>(false)
    var isParentApp: Bool = false

    func refresh() -> Future<Void, Never> { Future { $0(.success(())) } }
    func setContext(_ context: Context?) -> Future<Void, Never> { Future { $0(.success(())) } }
    func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> { Future { $0(.success(())) } }
    func updateState(message: InboxMessageListItem, state: ConversationWorkflowState) -> Future<Void, Never> { Future { $0(.success(())) } }
    func loadNextPage() -> Future<Void, Never> { Future { $0(.success(())) } }
}

final class MockRouter: Router {
    init() {
        super.init(routes: [])
    }

    private func addAnnouncements(to messageRows: [HorizonInboxViewModel.MessageRowViewModel]) -> [HorizonInboxViewModel.MessageRowViewModel] {
        []
    }
}

@Suite("Given the HorizonInboxViewModel")
class HorizonInboxViewModelTest {
    var viewModel: HorizonInboxViewModel!
    var mockAnnouncements: MockAnnouncementsInteractor!
    var mockInbox: MockInboxMessageInteractor!
    var mockRouter: MockRouter!

    init() {
        mockAnnouncements = MockAnnouncementsInteractor()
        mockInbox = MockInboxMessageInteractor()
        mockRouter = MockRouter()
        viewModel = HorizonInboxViewModel(
            userID: "1",
            api: API(),
            router: mockRouter,
            inboxMessageInteractor: mockInbox,
            announcementsInteractor: mockAnnouncements
        )
    }

    @Test("Initial filter title is All Messages")
    func testInitialFilterTitleIsAllMessages() {
        assert(viewModel.filterTitle == "All Messages")
    }

    @Test("Filter title change updates filter")
    func testFilterTitleChangeUpdatesFilter() {
        viewModel.filterTitle = "Unread"
        assert(viewModel.filterTitle == "Unread")
    }

    @Test("isSearchDisabled is true for Announcements")
    func testIsSearchDisabledForAnnouncements() {
        viewModel.filterTitle = "Announcements"
        assert(viewModel.isSearchDisabled)
    }

    @Test("addAnnouncements adds announcement row when shown")
    func testAddAnnouncementsWhenShown() {
        let announcement = Announcement(author: "A", courseName: nil, date: Date(), id: "a1", isAccountAnnouncement: true, title: "Test")
        mockAnnouncements.messages.accept([announcement])
        let result = viewModel.addAnnouncements(to: [])
        assert(result.contains { $0.isAnnouncement })
    }

    @Test("addAnnouncements does not add announcement row when not shown")
    func testAddAnnouncementsWhenNotShown() {
        viewModel.filterTitle = "Sent"
        let announcement = Announcement(author: "A", courseName: nil, date: Date(), id: "a1", isAccountAnnouncement: true, title: "Test")
        mockAnnouncements.messages.accept([announcement])
        let result = viewModel.addAnnouncements(to: [])
        assert(!result.contains { $0.isAnnouncement })
    }

    @Test("MessageRowViewModel properties for announcement")
    func testMessageRowViewModelProperties() {
        let date = Date()
        let announcement = Announcement(author: "A", courseName: nil, date: date, id: "a1", isAccountAnnouncement: true, title: "Ann")
        let row = HorizonInboxViewModel.MessageRowViewModel(announcement: announcement, inboxMessageListItem: nil)
        assert(row.title == "Ann")
        assert(row.date == date)
        assert(row.isAnnouncement)
    }

    @Test("viewMessage routes to correct path for message")
    func testViewMessageRoutesToCorrectPath() {
        let item = InboxMessageListItem(id: "m1", title: "Msg", participantName: "User", isUnread: false, dateRaw: Date())
        let controller = WeakViewController()
        viewModel.viewMessage(announcement: nil, inboxMessageListItem: item, viewController: controller)
        assert(mockRouter.lastRoute == "/conversations/m1")
    }

    @Test("viewMessage routes to correct path for announcement")
    func testViewMessageRoutesToAnnouncement() {
        let announcement = Announcement(author: "A", courseName: nil, date: Date(), id: "a1", isAccountAnnouncement: true, title: "Ann")
        let controller = WeakViewController()
        viewModel.viewMessage(announcement: announcement, inboxMessageListItem: nil, viewController: controller)
        assert(mockRouter.lastRoute == "/announcements/a1")
    }
}
