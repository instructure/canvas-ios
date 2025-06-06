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

final class AssistAssembly {

    static func makeAssistChatView(
        courseId: String? = nil,
        pageUrl: String? = nil,
        fileId: String? = nil
    ) -> UINavigationController {
        let viewModel = AssistChatViewModel(
            courseId: courseId,
            pageUrl: pageUrl,
            fileId: fileId,
            chatBotInteractor: makeChatBotInteractor(
                courseId: courseId,
                pageUrl: pageUrl,
                fileId: fileId
            )
        )
        let view = AssistChatView(viewModel: viewModel)
        let viewController = CoreHostingController(view)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }

    static func makeChatBotInteractor(courseId: String? = nil, pageUrl: String? = nil, fileId: String? = nil) -> AssistChatInteractor {
        if let courseId = courseId, let pageUrl = pageUrl {
            return AssistChatInteractorLive(
                courseId: courseId,
                pageUrl: pageUrl
            )
        }
        if let courseId = courseId, let fileId = fileId {
            return AssistChatInteractorLive(
                courseId: courseId,
                fileId: fileId,
                downloadFileInteractor: DownloadFileInteractorLive(courseID: courseId)
            )
        }
        return AssistChatInteractorLive()
    }

    static func makeAIQuizView(
        courseId: String? = nil,
        fileId: String? = nil,
        pageUrl: String? = nil,
        quizModel: AssistQuizModel? = nil
    ) -> AssistQuizView {
        let chatBotInteractor = makeChatBotInteractor(
            courseId: courseId,
            pageUrl: pageUrl,
            fileId: fileId
        )
        let viewModel = AssistQuizViewModel(chatBotInteractor: chatBotInteractor, quizModel: quizModel)
        return AssistQuizView(viewModel: viewModel)
    }

    static func makeAIFlashCardView(flashCards: [AssistFlashCardModel]) -> AssistFlashCardView {
        let router = AppEnvironment.shared.router
        let viewModel = AssistFlashCardViewModel(flashCards: flashCards, router: router)
        return AssistFlashCardView(viewModel: viewModel)
    }
}
