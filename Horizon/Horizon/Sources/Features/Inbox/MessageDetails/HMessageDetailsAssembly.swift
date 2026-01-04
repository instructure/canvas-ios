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
import UIKit

struct HorizonMessageDetailsAssembly {
    public static func makeViewController(
        conversationID: String,
        allowArchive: Bool
    ) -> UIViewController {
        let batchID = UUID.string
        let env = AppEnvironment.shared

        let messageDetailsInteractor =  MessageDetailsInteractorLive(
            env: env,
            conversationID: conversationID
        )

        let composeMessageInteractor = ComposeMessageInteractorLive(
            env: AppEnvironment.shared,
            batchId: batchID,
            uploadFolderPath: "conversation attachments",
            uploadManager: UploadManager(env: env, identifier: batchID)
        )
        let attachmentViewModel = AttachmentViewModel(composeMessageInteractor: composeMessageInteractor)
        let viewModel = HMessageDetailsViewModel(
            conversationID: conversationID,
            router: env.router,
            userID: env.currentSession?.userID ?? "",
            attachmentViewModel: attachmentViewModel,
            messageDetailsInteractor: messageDetailsInteractor,
            composeMessageInteractor: composeMessageInteractor,
            downloadFileInteractor: DownloadFileInteractorLive(),
            allowArchive: allowArchive
        )
        let view = HMessageDetailsView(viewModel: viewModel)
        return CoreHostingController(view)
    }

     static func makeAnnouncementView(notificationModel: NotificationModel) -> UIViewController {
         let interactor = NotificationInteractorLive(
             userID: AppEnvironment.shared.currentSession?.userID ?? "",
             formatter: NotificationFormatterLive()
         )
         let viewModel = HAnnouncementDetailsViewModel(
            notificationModel: notificationModel,
            interactor: interactor
         )
        return CoreHostingController(HAnnouncementDetailsView(viewModel: viewModel))
    }
}

#if DEBUG
extension HorizonMessageDetailsAssembly {
    static func makePreview() -> HMessageDetailsView {
        let env = PreviewEnvironment()
        let context = env.globalDatabase.viewContext
        let loremIpsumLong = """
                         Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus\
                         rutrum
                         """
        let attachmentViewModel = AttachmentViewModel(composeMessageInteractor: ComposeMessageInteractorPreview())
        let viewModel = HMessageDetailsViewModel(
            conversationID: "conversationID",
            router: env.router,
            userID: env.currentSession?.userID ?? "",
            attachmentViewModel: attachmentViewModel,
            messageDetailsInteractor: MessageDetailsInteractorPreview(
                env: env,
                subject: "",
                messages: .make(count: 5, body: loremIpsumLong, in: context)
            ),
            composeMessageInteractor: ComposeMessageInteractorPreview(),
            downloadFileInteractor: DownloadFileInteractorLive(),
            allowArchive: false
        )
       return HMessageDetailsView(viewModel: viewModel)
    }
}
#endif
