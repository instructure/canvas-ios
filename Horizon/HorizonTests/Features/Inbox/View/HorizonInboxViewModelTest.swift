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
import Core
import CoreData
import Testing
import SwiftUI

@testable import Horizon

@Suite("Given the HorizonInboxViewModel") class HorizonInboxViewModelTest {
    let addressBookInteractor = AddressBookInteractorMock()
    let routerMock = RouterMock()
    var viewModel: HorizonInboxViewModel!

    init() {
        viewModel = HorizonInboxViewModel(addressBookInteractor: addressBookInteractor, router: routerMock)
    }

    @Test("When the view model is initialized, Then recipients is called once") func testThenRecipientsCalledOnce() {
        #expect(addressBookInteractor.recipientsCallCount == 1)
    }
    @Test("When the view model is initialized, Then the number of personOptions is 3") func testThenPersonOptionsCount() {
        #expect(viewModel.personOptions.count == 3)
    }
    @Test("When goBack is called, Then the router pop function is called once") func testThenGoBackCalledOnce() {
        viewModel.goBack(WeakViewController())

        #expect(routerMock.popCallCount == 1)
    }
}

class RouterMock: Router {
    var popCallCount = 0

    init() {
        super.init(routes: [])
    }

    override
    func pop(from: UIViewController) {
        popCallCount += 1
    }
}

class AddressBookInteractorMock: AddressbookInteractor {
    var recipientsCallCount = 0

    var state: CurrentValueSubject<StoreState, Never> {
        CurrentValueSubject(.data)
    }
    var recipients: CurrentValueSubject<[SearchRecipient], Never> {
        recipientsCallCount += 1
        return CurrentValueSubject([
            SearchRecipient.make(in: dataStore.viewContext),
            SearchRecipient.make(),
            SearchRecipient.make()
        ])
    }
    var canSelectAllRecipient: CurrentValueSubject<Bool, Never> {
        CurrentValueSubject(false)
    }

    func refresh() -> Future<Void, Never> {
        Future { promise in
            promise(.success(()))
        }
    }
}
