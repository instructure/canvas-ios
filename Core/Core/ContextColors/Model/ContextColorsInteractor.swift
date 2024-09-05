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

    /// Returns the context's color from the cache.
    func contextColor(_ context: Context) -> UIColor

    /// Publishes a value when a context's color changes in the cache. Doesn't directly fetch from the API. Useful on screen working with multiple contexts.
    func observeContextColorChanges() -> AnyPublisher<Void, Never>

    /// Publishes the context's color when it changes in the cache. Doesn't directly fetch from the API.
    func observeContextColor(
        _ context: Context
    ) -> AnyPublisher<UIColor, Never>

    /// Refreshes the color database from the API and publishes changes via the observation.
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never>
}

public class ContextColorsInteractorLive: ContextColorsInteractor {
    private var colorMapCache = CurrentValueSubject<[Context: UIColor], Never>([:])
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        observeContextColorChangesInDatabase()
    }

    public func contextColor(_ context: Context) -> UIColor {
        colorMapCache.value[context] ?? UIColor.defaultContextColor
    }

    public func observeContextColorChanges(
    ) -> AnyPublisher<Void, Never> {
        colorMapCache
            .removeDuplicates()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func observeContextColor(
        _ context: Context
    ) -> AnyPublisher<UIColor, Never> {
        colorMapCache
            .map { colors -> UIColor in
                colors[context] ?? UIColor.defaultContextColor
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        let useCase = GetCDContextColorsUseCase()
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .mapToVoid()
            .ignoreFailure(completeImmediately: true)
    }

    private func observeContextColorChangesInDatabase() {
        let useCase = LocalUseCase<CDContextColor>(scope: .all)
        ReactiveStore(useCase: useCase)
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .sink { [weak colorMapCache] contextColors in
                var colorMap: [Context: UIColor] = [:]

                for contextColor in contextColors {
                    guard let context = Context(canvasContextID: contextColor.canvasContextID),
                          let color = UIColor(hexString: contextColor.contextColorHex)
                    else {
                        continue
                    }

                    colorMap[context] = color.ensureContrast(against: .backgroundLightest)
                }

                colorMapCache?.send(colorMap)
            }
            .store(in: &subscriptions)
    }
}
