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

import CombineExt

public enum AddressBookAssembly {

    public static func makeAddressbookRecipientViewController(
        env: AppEnvironment = .shared,
        recipientContext: RecipientContext,
        roleName: String,
        recipients: [Recipient],
        recipientDidSelect: PassthroughRelay<Recipient>
    ) -> UIViewController {
        let viewModel = AddressbookRecipientViewModel(router: env.router, roleName: roleName, recipients: recipients, recipientDidSelect: recipientDidSelect)
        let view = AddressbookRecipientView(model: viewModel)
        return CoreHostingController(view)
    }

    public static func makeAddressbookRoleViewController(
        env: AppEnvironment = .shared,
        recipientContext: RecipientContext,
        recipientDidSelect: PassthroughRelay<Recipient>
    ) -> UIViewController {
        let interactor = AddressbookInteractorLive(env: env, recipientContext: recipientContext)
        let viewModel = AddressbookRoleViewModel(router: env.router, recipientContext: recipientContext, interactor: interactor, recipientDidSelect: recipientDidSelect)
        let view = AddressbookRoleView(model: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment) -> AddressbookRecipientView {
        let interactor = AddressbookInteractorPreview(env: env)
        let viewModel = AddressbookRecipientViewModel(
            router: env.router,
            roleName: "Students",
            recipients: interactor.recipients.value.map { Recipient(searchRecipient: $0) },
            recipientDidSelect: PassthroughRelay<Recipient>()
        )
        return AddressbookRecipientView(model: viewModel)
    }

#endif
}
