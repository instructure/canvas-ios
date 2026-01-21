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
import Foundation
import Observation

@Observable
final class CourseInvitationsWidgetViewModel: LearnerWidgetViewModel {
    typealias ViewType = CourseInvitationsWidgetView

    let config: WidgetConfig
    var id: LearnerDashboardWidgetIdentifier { config.id }
    let isFullWidth = true
    let isEditable = false

    private(set) var invitations: [CourseInvitation] = []
    private(set) var state: InstUI.ScreenState = .loading

    var layoutIdentifier: AnyHashable {
        struct Identifier: Hashable {
            let state: InstUI.ScreenState
            let invitationCount: Int
        }
        return AnyHashable(Identifier(state: state, invitationCount: invitations.count))
    }

    private let interactor: CourseInvitationsInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(config: WidgetConfig, interactor: CourseInvitationsInteractor) {
        self.config = config
        self.interactor = interactor
    }

    func makeView() -> CourseInvitationsWidgetView {
        CourseInvitationsWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        state = .loading

        return interactor.fetchInvitations(ignoreCache: ignoreCache)
            .receive(on: DispatchQueue.main)
            .map { [weak self] invitations in
                self?.invitations = invitations
                self?.state = invitations.isEmpty ? .empty : .data
                return ()
            }
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    func acceptInvitation(id: String) {
        interactor.acceptInvitation(id: id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                }
            } receiveValue: { [weak self] _ in
                self?.invitations.removeAll { $0.id == id }
                if self?.invitations.isEmpty == true {
                    self?.state = .empty
                }
            }
            .store(in: &subscriptions)
    }

    func declineInvitation(id: String) {
        interactor.declineInvitation(id: id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                }
            } receiveValue: { [weak self] _ in
                self?.invitations.removeAll { $0.id == id }
                if self?.invitations.isEmpty == true {
                    self?.state = .empty
                }
            }
            .store(in: &subscriptions)
    }
}
