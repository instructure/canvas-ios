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

    // MARK: Dashboard widget config
    let config: DashboardWidgetConfig
    let isFullWidth = true
    let isEditable = false
    var layoutIdentifier: AnyHashable {
        struct Identifier: Hashable {
            let state: InstUI.ScreenState
            let greetingCount: Int
            let messageCount: Int
        }

        return Identifier(state: state, greetingCount: greeting.count, messageCount: message.count)
    }

    // MARK: Outputs
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var greeting = ""
    private(set) var message = ""

    // MARK: Private properties
    private var subscriptions = Set<AnyCancellable>()
    private var periodProvider: DayPeriodProvider
    private let interactor: HelloWidgetInteractor
    private var shortName: String?

    init(
        environment: AppEnvironment = .shared,
        dayPeriodProvider: DayPeriodProvider = .init(),
        interactor: HelloWidgetInteractor = HelloWidgetInteractorLive(),
        config: DashboardWidgetConfig,
    ) {
        self.periodProvider = dayPeriodProvider
        self.config = config
        self.interactor = interactor

        interactor.getShortName(ignoreCache: false)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
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

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getShortName(ignoreCache: ignoreCache)
            .handleEvents(
                receiveOutput: { [weak self] shortName in
                    guard let self else { return }

                    self.periodProvider = .init(date: Clock.now)
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

    func makeView() -> HelloWidgetView {
        HelloWidgetView(viewModel: self)
    }

    // MARK: Private methods
    private func subscribeToNotification() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                if self.periodProvider.current != DayPeriodProvider.period(of: Core.Clock.now) {
                    self.periodProvider = .init(date: Core.Clock.now)
                    self.updateGreetingAndMessage()
                }
            }
            .store(in: &subscriptions)
    }

    private func updateGreetingAndMessage() {
        self.message = self.dayPeriodMessage()
        self.greeting = self.dayPeriodGreeting()
        self.state = .data
    }

    private func dayPeriodGreeting() -> String {
        if let shortName, shortName.isNotEmptyOrBlank() {
            switch periodProvider.current {
            case .morning: .init(localized: "Good morning \(shortName)!", bundle: .student)
            case .afternoon: .init(localized: "Good afternoon \(shortName)!", bundle: .student)
            case .evening: .init(localized: "Good evening \(shortName)!", bundle: .student)
            case .night: .init(localized: "Good night \(shortName)!", bundle: .student)
            }
        } else {
            switch periodProvider.current {
            case .morning: .init(localized: "Good morning!", bundle: .student)
            case .afternoon: .init(localized: "Good afternoon!", bundle: .student)
            case .evening: .init(localized: "Good evening!", bundle: .student)
            case .night: .init(localized: "Good night!", bundle: .student)
            }
        }
    }

    private func dayPeriodMessage() -> String {
        let periodMessages = switch periodProvider.current {
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
