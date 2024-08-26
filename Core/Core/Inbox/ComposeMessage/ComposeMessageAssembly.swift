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

    public static func makeComposeMessageViewController(env: AppEnvironment = .shared, options: ComposeMessageOptions = ComposeMessageOptions()) -> UIViewController {
        let batchId = UUID.string
        let interactor = ComposeMessageInteractorLive(
            env: env,
            batchId: batchId,
            uploadFolderPath: "conversation attachments",
            restrictForFolderPath: true,
            uploadManager: UploadManager(identifier: batchId),
            publisherProvider: URLSessionDataTaskPublisherProviderLive()
        )
        let recipientUseCase = RecipientUseCase()
        let viewModel = ComposeMessageViewModel(router: env.router, options: options, interactor: interactor, recipientUseCase: recipientUseCase)

        let view = ComposeMessageView(model: viewModel)
        return CoreHostingController(view)
    }

    public static func makeComposeMessageViewController(env: AppEnvironment = .shared, queryItems: [URLQueryItem]) -> UIViewController {
        makeComposeMessageViewController(env: env, options: ComposeMessageOptions(queryItems: queryItems))
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment)
    -> ComposeMessageView {
        let interactor = ComposeMessageInteractorPreview()
        let options = ComposeMessageOptions()
        let viewModel = ComposeMessageViewModel(router: env.router, options: options, interactor: interactor, recipientUseCase: RecipientUseCase())
        return ComposeMessageView(model: viewModel)
    }

#endif
}
