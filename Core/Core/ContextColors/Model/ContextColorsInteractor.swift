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

public protocol ContextColorsInteractor {
    typealias ContextID = String

    var contextColors: CurrentValueSubject<[ContextID: UIColor], Never> { get }
}

class ContextColorsInteractorLive: ContextColorsInteractor {
    let contextColors = CurrentValueSubject<[ContextID: UIColor], Never>([:])

    private let k5State: K5State
    private var subscriptions = Set<AnyCancellable>()

    init(k5State: K5State) {
        self.k5State = k5State
        refreshColorsFromAPI()

        let localColors = LocalUseCase<ContextColor>(scope: .all)
        ReactiveStore(useCase: localColors)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .map { [k5State] contextColors in
                var colorsByCourse: [ContextID: UIColor] = [:]

                for contextColor in contextColors {
                    colorsByCourse[contextColor.canvasContextID] = .contextColor(
                        courseColorHex: contextColor.courseColorHex,
                        contextColorHex: contextColor.contextColorHex,
                        k5State: k5State
                    )
                }

                return colorsByCourse
            }
            .sink { _ in
            } receiveValue: { [weak contextColors] colorsByCourse in
                contextColors?.send(colorsByCourse)
            }
            .store(in: &subscriptions)
    }

    /// Force refreshes colors from API. Results are published via the `courseColors` subject.
    func refresh() {
        refreshColorsFromAPI(ignoreCache: true)
    }

    private func refreshColorsFromAPI(ignoreCache: Bool = false) {
        let colorsUseCase = GetCourseColorsUseCase()
        ReactiveStore(useCase: colorsUseCase)
            .getEntities(ignoreCache: ignoreCache)
            .sink()
            .store(in: &subscriptions)
    }
}
