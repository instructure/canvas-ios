//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import SwiftUI

public enum FileUploadNotificationCardViewState: Equatable, Identifiable {
    case uploading(progress: Float)
    case done

    public var id: String {
        switch self {
        case .uploading(let progress): return "\(progress))"
        case .done: return "done"
        }
    }
}

final class FileUploadNotificationCardViewModel: ObservableObject {
    // MARK: - Inputs

    public private(set) lazy var cardDidTap: AnyPublisher<UIAlertController, Never> = cardDidTapSubject.eraseToAnyPublisher()

    // MARK: - Outputs

    @Published public private(set) var isVisible = false
    @Published public private(set) var state: FileUploadNotificationCardViewState = .uploading(progress: 0)

    // MARK: - Private properties
    
    private var progress: Float = 0
    private let cardDidTapSubject = PassthroughSubject<UIAlertController, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        unowned let unownedSelf = self

        Timer.publish(every: 0.01, on: .main, in: .default)
            .autoconnect()
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .map { _ in
                unownedSelf.isVisible = true
                unownedSelf.progress += 0.1 / 40

                guard unownedSelf.progress <= 1 else {
                    return .done
                }

                return FileUploadNotificationCardViewState.uploading(
                    progress: unownedSelf.progress
                )
            }
            .assign(to: \.state, on: self)
            .store(in: &subscriptions)

        $state
            .filter { $0 == .done }
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .sink { _ in
                unownedSelf.isVisible = false
                unownedSelf.subscriptions.removeAll()
            }
            .store(in: &subscriptions)
    }
}
