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

public enum ComposeMessageAssembly {

    public static func makeNewMessageViewController(env: AppEnvironment = .shared) -> UIViewController {
        let interactor = ComposeMessageInteractorLive()
        let viewModel = ComposeMessageViewModel(router: env.router, interactor: interactor)
        let view = ComposeMessageView(model: viewModel)
        return CoreHostingController(view)
    }

    public static func makeReplyMessageViewController(env: AppEnvironment = .shared, conversation: Conversation, author: String? = nil) -> UIViewController {
        let interactor = ReplyMessageInteractorLive()
        let viewModel = ComposeMessageViewModel(router: env.router, conversation: conversation, author: author, interactor: interactor)
        let view = ComposeMessageView(model: viewModel)
        return CoreHostingController(view)
    }

    public static func makeComposeMessageViewControllerFromParameters(env: AppEnvironment = .shared, queryItems: [URLQueryItem]) -> UIViewController {
        print(queryItems)
        let interactor = ComposeMessageInteractorLive()
        let viewModel = ComposeMessageViewModel(router: env.router, options: ComposeMessageOptions(), interactor: interactor)
        let view = ComposeMessageView(model: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment)
    -> ComposeMessageView {
        let interactor = ComposeMessageInteractorPreview()
        let viewModel = ComposeMessageViewModel(router: env.router, interactor: interactor)
        return ComposeMessageView(model: viewModel)
    }

#endif
}
