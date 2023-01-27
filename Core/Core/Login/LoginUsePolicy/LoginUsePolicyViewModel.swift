//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class LoginUsePolicyViewModel: ObservableObject {

    @Published public var isAccepted = false
    @Published public private(set) var errorText: String?
    @Published public var showError: Bool = false

    private let accepted: (() -> Void)?
    private let cancelled: (() -> Void)?

    init(accepted: (() -> Void)? = nil, cancelled: (() -> Void)? = nil) {
        self.accepted = accepted
        self.cancelled = cancelled
    }

    public func submitAcceptance() {
        acceptUsePolicy { result in
            switch result {
            case let .failure(error):
                self.errorText = error.localizedDescription
                self.showError = true
            case .success:
                guard let accepted = self.accepted else { return }
                accepted()
            }
        }
    }

    public func cancelAcceptance() {
        guard let cancelled = self.cancelled else { return }
        cancelled()
    }

    public func acceptUsePolicy(_ callback: @escaping (Result<Void, Error>) -> Void) {
        AppEnvironment.shared.api.makeRequest(PutUserAcceptedTermsRequest(hasAccepted: true)) { _, _, error in
            if let error = error {
                return callback(.failure(error))
            }
            callback(.success(()))
        }
    }
}
