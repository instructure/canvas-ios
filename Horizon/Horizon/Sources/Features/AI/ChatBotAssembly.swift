//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI
import Core

final class ChatBotAssembly {

    static func makeChatBotView(courseId: String? = nil, pageUrl: String? = nil, fileId: String? = nil) -> UIViewController {
        CoreHostingController(
            ChatBotView(
                viewModel: ChatBotViewModel(
                    chatBotInteractor: makeChatBotInteractor(courseId: courseId, pageUrl: pageUrl, fileId: fileId)
                )
            )
        )
    }

    static func makeChatBotInteractor(courseId: String? = nil, pageUrl: String? = nil, fileId: String? = nil) -> ChatBotInteractor {
        if let courseId = courseId, let pageUrl = pageUrl {
            return ChatBotInteractorLive(courseId: courseId, pageUrl: pageUrl)
        }
        if let courseId = courseId, let fileId = fileId {
            return ChatBotInteractorLive(
                courseId: courseId,
                fileId: fileId,
                downloadFileInteractor: DownloadFileInteractorLive(courseID: courseId)
            )
        }
        return ChatBotInteractorLive()
    }

    static func makeAIQuizView() -> AIQuizView {
        let router = AppEnvironment.shared.router
        let viewModel = AIQuizViewModel(router: router)
        return AIQuizView(viewModel: viewModel)
    }

    static func makeAIFlashCardView() -> AIFlashCardView {
        let router = AppEnvironment.shared.router
        let viewModel = AIFlashCardViewModel(router: router)
        return AIFlashCardView(viewModel: viewModel)
    }
}
