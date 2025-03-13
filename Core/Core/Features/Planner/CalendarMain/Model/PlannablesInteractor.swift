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

import Combine
import Foundation

public protocol PlannablesInteractor: AnyObject {
    var state: CurrentValueSubject<StoreState, Never> { get }
    var events: CurrentValueSubject<[Plannable], Never> { get }
    func setup(startDate: Date, endDate: Date, contextCodes: [String])
}

public class PlannablesInteractorLive: PlannablesInteractor {
    public var state: CurrentValueSubject<StoreState, Never>
    public var events: CurrentValueSubject<[Plannable], Never>
    private var store: Store<GetPlannables>?

    private var subscriptions = Set<AnyCancellable>()
    private let studentID: String?
    private let env: AppEnvironment

    init(studentID: String?, env: AppEnvironment = .shared) {
        self.studentID = studentID
        self.env = env
        self.events = CurrentValueSubject<[Plannable], Never>([])
        self.state = CurrentValueSubject<StoreState, Never>(.empty)
    }

    public func setup(startDate: Date, endDate: Date, contextCodes: [String]) {
        if let prevUseCase = store?.useCase,
           prevUseCase.startDate == startDate,
           prevUseCase.endDate == endDate,
           prevUseCase.contextCodes == contextCodes {
            return
        }

        let useCase = GetPlannables(
            startDate: startDate,
            endDate: endDate,
            contextCodes: contextCodes
        )

        store = env.subscribe(useCase)
        store?
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        store?
            .allObjects
            .subscribe(events)
            .store(in: &subscriptions)

        store?.exhaust(force: true)
    }
}
