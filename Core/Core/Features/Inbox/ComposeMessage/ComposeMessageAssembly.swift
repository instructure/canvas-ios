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
        options: ComposeMessageOptions = ComposeMessageOptions(),
        env: AppEnvironment
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
        let studentAccessInteractor = StudentAccessInteractorLive(env: env)

        let viewModel = ComposeMessageViewModel(
            options: options,
            interactor: interactor,
            recipientInteractor: recipientInteractor,
            inboxSettingsInteractor: settingsInteractor,
            studentAccessInteractor: studentAccessInteractor,
            env: env
        )

        let view = ComposeMessageView(model: viewModel)
        return CoreHostingController(view, env: env)
    }

    public static func makeComposeMessageViewController(env: AppEnvironment, url: URLComponents) -> UIViewController {
        if let queryItems = url.queryItems {
            return makeComposeMessageViewController(options: ComposeMessageOptions(queryItems: queryItems), env: env)
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
            options: options,
            interactor: interactor,
            recipientInteractor: RecipientInteractorLive(),
            inboxSettingsInteractor: InboxSettingsInteractorPreview(),
            studentAccessInteractor: StudentAccessInteractorPreview(env: env),
            env: env
        )
        return ComposeMessageView(model: viewModel)
    }

#endif
}
