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
import Core
import Combine
import UIKit

@Observable
final class HelloWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = HelloWidgetView

    let config: DashboardWidgetConfig
    let isFullWidth = true
    let isEditable = false
    let isHiddenInEmptyState = true

    var layoutIdentifier: [AnyHashable] {
        [state, greeting.count, message.count]
    }

    // MARK: Outputs
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var greeting: String = ""
    private(set) var message: String = ""

    // MARK: Private properties
    private var shortName: String?
    private let interactor: HelloWidgetInteractor
    private var dayPeriodProvider: DayPeriodProvider
    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: HelloWidgetInteractor,
        dayPeriodProvider: DayPeriodProvider
    ) {
        self.config = config
        self.dayPeriodProvider = dayPeriodProvider
        self.interactor = interactor

        interactor.getShortName(ignoreCache: false)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if completion.isFailure {
                        self?.state = .error
                    }
                },
                receiveValue: { [weak self] shortName in
                    self?.shortName = shortName
                    self?.updateGreetingAndMessage()
                }
            )
            .store(in: &subscriptions)

        subscribeToNotification()
    }

    func makeView() -> HelloWidgetView {
        HelloWidgetView(viewModel: self)
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getShortName(ignoreCache: ignoreCache)
            .handleEvents(
                receiveOutput: { [weak self] shortName in
                    guard let self else { return }

                    self.dayPeriodProvider = .init(date: Clock.now)
                    self.shortName = shortName
                    self.updateGreetingAndMessage()
                }, receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.state = .error
                    }
                }
            )
            .mapToVoid()
            .replaceError(with: ())
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }

    // MARK: Private methods

    private func subscribeToNotification() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                guard let self else { return }

                if self.dayPeriodProvider.current != DayPeriodProvider.period(of: Core.Clock.now) {
                    self.dayPeriodProvider = .init(date: Core.Clock.now)
                    self.updateGreetingAndMessage()
                }
            }
            .store(in: &subscriptions)
    }

    private func updateGreetingAndMessage() {
        greeting = dayPeriodGreeting()
        message = dayPeriodMessage()
        state = .data
    }

    private func dayPeriodGreeting() -> String {
        if let shortName, shortName.isNotEmptyOrBlank() {
            switch dayPeriodProvider.current {
            case .morning: .init(localized: "Good morning \(shortName)!", bundle: .student)
            case .afternoon: .init(localized: "Good afternoon \(shortName)!", bundle: .student)
            case .evening: .init(localized: "Good evening \(shortName)!", bundle: .student)
            case .night: .init(localized: "Good night \(shortName)!", bundle: .student)
            }
        } else {
            switch dayPeriodProvider.current {
            case .morning: .init(localized: "Good morning!", bundle: .student)
            case .afternoon: .init(localized: "Good afternoon!", bundle: .student)
            case .evening: .init(localized: "Good evening!", bundle: .student)
            case .night: .init(localized: "Good night!", bundle: .student)
            }
        }
    }

    private func dayPeriodMessage() -> String {
        let periodMessages = switch dayPeriodProvider.current {
        case .morning: Self.morning
        case .afternoon: Self.afternoon
        case .evening: Self.evening
        case .night: Self.night
        }

        guard let message = (Self.generic.union(periodMessages)).randomElement() else {
            // arrays are empty, will not happen
            return ""
        }
        return message
    }
}
