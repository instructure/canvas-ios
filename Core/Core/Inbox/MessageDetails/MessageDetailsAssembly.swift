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

public enum MessageDetailsAssembly {

    public static func makeViewController(env: AppEnvironment,
                                          conversationID: String) -> UIViewController {
        let interactor = MessageDetailsInteractorLive(env: env, conversationID: conversationID)
        let viewModel = MessageDetailsViewModel(router: env.router, interactor: interactor, myID: env.currentSession?.userID ?? "")
        let view = MessageDetailsView(model: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment,
                                   subject: String,
                                   messages: [ConversationMessage])
    -> MessageDetailsView {
        let interactor = MessageDetailsInteractorPreview(env: env, subject: subject, messages: messages)
        let viewModel = MessageDetailsViewModel(router: env.router, interactor: interactor, myID: env.currentSession?.userID ?? "")
        return MessageDetailsView(model: viewModel)
    }

#endif
}
