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

import Foundation
import Core

enum ModuleItemSequenceAssembly {
    static func makeItemSequenceView(
        environment: AppEnvironment,
        courseID: String,
        assetType: GetModuleItemSequenceRequest.AssetType,
        assetID: String,
        url: URLComponents
    ) -> UIViewController {
        let interactor = ModuleItemSequenceInteractorLive(
            courseID: courseID,
            assetType: assetType,
            environment: environment
        )
        let stateInteractor = ModuleItemStateInteractorLive(
            environment: environment,
            courseID: courseID,
            url: url,
            assetType: assetType
        )
        let viewModel = ModuleItemSequenceViewModel(
            moduleItemInteractor: interactor,
            moduleItemStateInteractor: stateInteractor,
            assetType: assetType,
            assetID: assetID
        )
        let view = ModuleItemSequenceView(viewModel: viewModel)
        environment.tabBar(isVisible: false)
        return CoreHostingController(view)
    }

    static func makeModuleNavBarView(
        isNextButtonEnabled: Bool,
        isPreviousButtonEnabled: Bool,
        didTapNext: @escaping () -> Void,
        didTapPrevious: @escaping () -> Void
    ) -> ModuleNavBarView {
        let router = AppEnvironment.shared.router
        return ModuleNavBarView(
            router: router,
            isNextButtonEnabled: isNextButtonEnabled,
            isPreviousButtonEnabled: isPreviousButtonEnabled,
            didTapNext: didTapNext,
            didTapPrevious: didTapPrevious
        )
    }

    static func makeErrorView(didTapRetry: @escaping () -> Void) -> ModuleItemSequenceErrorView {
        ModuleItemSequenceErrorView(didTapRetry: didTapRetry)
    }

    static func makeLockView(title: String, lockExplanation: String) -> ModuleItemLockedView {
        ModuleItemLockedView(title: title, lockExplanation: lockExplanation)
    }

    static func makeExternalURLView(
        environment: AppEnvironment,
        name: String,
        url: URL,
        courseID: String?
    ) -> ExternalURLViewRepresentable {
        ExternalURLViewRepresentable(
            environment: environment,
            name: name,
            url: url,
            courseID: courseID
        )
    }

    static func makeLTIView(
        environment: AppEnvironment,
        tools: LTITools,
        name: String?
    ) -> LTIViewRepresentable {
        LTIViewRepresentable(
            environment: environment,
            tools: tools,
            name: name
        )
    }

    static func makeModuleItemView(viewController: UIViewController) -> ModuleItemViewRepresentable {
        ModuleItemViewRepresentable(viewController: viewController)
    }

#if DEBUG
    static func makeItemSequencePreview() -> ModuleItemSequenceView {
        let viewModel = ModuleItemSequenceViewModel(
            moduleItemInteractor: ModuleItemSequenceInteractorPreview(),
            moduleItemStateInteractor: ModuleItemStateInteractorPreview(),
            assetType: .moduleItem,
            assetID: "assetID"
        )
        let view = ModuleItemSequenceView(viewModel: viewModel)
        return view
    }
#endif
}
