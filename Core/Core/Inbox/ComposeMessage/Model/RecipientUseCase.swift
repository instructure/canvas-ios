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

import Foundation
import Combine

protocol RecipientUseCaseType {
    func getRecipients(by context: Context?) -> AnyPublisher<[Recipient], Never>
}

final class RecipientUseCase: RecipientUseCaseType {

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Functions
    func getRecipients(by context: Context?) -> AnyPublisher<[Recipient], Never> {

        Future<[Recipient], Never> { [self] promise in
            guard let context = context else {
                promise(.success([]))
                return
            }

            ReactiveStore(
                useCase: GetSearchRecipients(context: context)
            ).getEntities()
                .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
                .map { Recipient(id: $0.id, name: $0.name, avatarURL: $0.avatarURL) }
                .collect()
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)

                .sink { result in
                    promise(.success(result))
                }
                .store(in: &subscriptions)
        }
        .eraseToAnyPublisher()
    }
}
