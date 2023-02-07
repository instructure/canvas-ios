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

public class LoginUsePolicy {

    public static func checkAcceptablePolicy(from controller: UIViewController? = nil, cancelled: (() -> Void)? = nil) {

        let env = AppEnvironment.shared

        let request = GetWebSessionRequest(to: env.api.baseURL.appendingPathComponent("users/self"))
        env.api.makeRequest(request) { data, _, error in performUIUpdate {

            if let error = error {
                (controller as? ErrorViewController)?.showAlert(title: nil, message: error.localizedDescription)
                return
            }

            if data?.requires_terms_acceptance == true {
                let usePolicyViewModel = LoginUsePolicyViewModel(cancelled: cancelled)
                let usePolicyView = LoginUsePolicyView(viewModel: usePolicyViewModel)
                guard let viewController = controller ?? env.topViewController else { return }
                env.router.show(CoreHostingController(usePolicyView),
                                from: viewController,
                                options: .modal(.formSheet, isDismissable: false, embedInNav: true))
            }
        } }
    }

    public static func acceptUsePolicy(_ callback: @escaping (Result<Void, Error>) -> Void) {
        AppEnvironment.shared.api.makeRequest(PutUserAcceptedTermsRequest(hasAccepted: true)) { _, _, error in performUIUpdate {
            if let error = error {
                return callback(.failure(error))
            }
            callback(.success(()))
        } }
    }
}
