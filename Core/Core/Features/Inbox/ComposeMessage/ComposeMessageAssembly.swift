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
import Combine
import AVKit

public enum ComposeMessageAssembly {

    public static func makeComposeMessageViewController(
        env: AppEnvironment,
        options: ComposeMessageOptions = ComposeMessageOptions()
    ) -> UIViewController {

        let batchId = UUID.string
        let interactor = ComposeMessageInteractorLive(
            env: env,
            batchId: batchId,
            uploadFolderPath: "conversation attachments",
            restrictForFolderPath: true,
            uploadManager: UploadManager(env: env, identifier: batchId),
            publisherProvider: URLSessionDataTaskPublisherProviderLive()
        )
        let recipientInteractor = RecipientInteractorLive()
        let settingsInteractor = InboxSettingsInteractorLive(environment: env)
        let viewModel = ComposeMessageViewModel(
            env: env,
            options: options,
            interactor: interactor,
            recipientInteractor: recipientInteractor,
            inboxSettingsInteractor: settingsInteractor
        )

        let view = ComposeMessageView(model: viewModel)
        return CoreHostingController(view, env: env)
    }

    public static func makeComposeMessageViewController(env: AppEnvironment, url: URLComponents) -> UIViewController {
        if let queryItems = url.queryItems {
            return makeComposeMessageViewController(env: env, options: ComposeMessageOptions(queryItems: queryItems))
        } else {
            return ComposeMessageAssembly.makeComposeMessageViewController(env: env)
        }
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment)
    -> ComposeMessageView {
        let interactor = ComposeMessageInteractorPreview()
        let options = ComposeMessageOptions()
        let viewModel = ComposeMessageViewModel(
            env: env,
            options: options,
            interactor: interactor,
            recipientInteractor: RecipientInteractorLive(),
            inboxSettingsInteractor: InboxSettingsInteractorPreview()
        )
        return ComposeMessageView(model: viewModel)
    }

#endif
}
