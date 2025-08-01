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

import UIKit

public enum MessageDetailsAssembly {

    public static func makeViewController(
        conversationID: String,
        allowArchive: Bool,
        env: AppEnvironment
    ) -> UIViewController {
        let interactor = MessageDetailsInteractorLive(env: env, conversationID: conversationID)
        let viewModel = MessageDetailsViewModel(
            interactor: interactor,
            myID: env.currentSession?.userID ?? "",
            allowArchive: allowArchive,
            env: env
        )
        let view = MessageDetailsView(model: viewModel)
        return CoreHostingController(view, env: env)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment,
                                   subject: String,
                                   messages: [ConversationMessage])
    -> MessageDetailsView {
        let interactor = MessageDetailsInteractorPreview(env: env, subject: subject, messages: messages)
        let viewModel = MessageDetailsViewModel(
            interactor: interactor,
            myID: env.currentSession?.userID ?? "",
            allowArchive: true,
            env: env
        )
        return MessageDetailsView(model: viewModel)
    }

#endif
}
