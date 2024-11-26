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

final class AIAssembly {

    static func makeChatBotView() -> ChatBotView {
        let router = AppEnvironment.shared.router
        let viewModel = ChatBotViewModel(router: router)
        return ChatBotView(viewModel: viewModel)
    }

    static func makeAITutorView() -> UIViewController {
        let appEnvironment = AppEnvironment.shared
        let viewModel = AITutorViewModel(router: appEnvironment.router)
        let view = AITutorView(viewModel: viewModel)
        return CoreHostingController(view)
    }

    static func makeAISummaryView() -> UIViewController {
        CoreHostingController(AISummaryView())
    }

    static func makeAIQuizView() -> AIQuizView {
        let router = AppEnvironment.shared.router
        let viewModel = AIQuizViewModel(router: router)
        return AIQuizView(viewModel: viewModel)
    }
}
