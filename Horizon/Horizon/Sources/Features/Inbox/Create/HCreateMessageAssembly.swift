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

import Core
import SwiftUI

enum HCreateMessageAssembly {
    private static func makeViewModel() -> HCreateMessageViewModel {
        let appEnvironment = AppEnvironment.shared
        let uploadIdentifier = UUID().uuidString
        let userID = appEnvironment.currentSession?.userID ?? ""
        let composeMessageInteractor =  ComposeMessageInteractorLive(
            env: AppEnvironment.shared,
            batchId: uploadIdentifier,
            uploadFolderPath: "conversation attachments",
            uploadManager: UploadManager(
                env: AppEnvironment.shared,
                identifier: uploadIdentifier
            )
        )

        let messageInteractor = InboxMessageInteractorLive(
            env: appEnvironment,
            tabBarCountUpdater: .init(),
            messageListStateUpdater: .init()
        )

        let attachmentViewModel = AttachmentViewModel(composeMessageInteractor: composeMessageInteractor)

        return HCreateMessageViewModel(
            userID: userID,
            attachmentViewModel: attachmentViewModel,
            recipientSelectionViewModel: .init(userID: userID),
            composeMessageInteractor: composeMessageInteractor,
            inboxMessageInteractor: messageInteractor,
            router: appEnvironment.router,
        )
    }

    public static func makeViewController() -> UIViewController {
        CoreHostingController(
            HCreateMessageView(viewModel: makeViewModel())
        )
    }
}

#if DEBUG
extension HCreateMessageAssembly {
    static func makePreview() -> HCreateMessageView {
        let env = PreviewEnvironment()
        let context = env.globalDatabase.viewContext
        let attachmentViewModel = AttachmentViewModel(composeMessageInteractor: ComposeMessageInteractorPreview())
        let viewModel = HCreateMessageViewModel(
            userID: "userID",
            attachmentViewModel: attachmentViewModel,
            recipientSelectionViewModel: .init(userID: "userID"),
            composeMessageInteractor: ComposeMessageInteractorPreview(),
            inboxMessageInteractor: InboxMessageInteractorPreview(environment: env, messages: .make(count: 5, in: context)),
            router: AppEnvironment.shared.router,
        )
        return HCreateMessageView(viewModel: viewModel)
    }
}
#endif
