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
import SwiftUI
import Core
import UIKit

enum ModuleItemSequenceAssembly {
    static func makeItemSequenceView(
        environment: AppEnvironment,
        courseID: String,
        assetType: GetModuleItemSequenceRequest.AssetType,
        assetID: String,
        url: URLComponents
    ) -> UIViewController {
        let getCoursesInteractor = GetCoursesInteractorLive()
        let interactor = ModuleItemSequenceInteractorLive(
            courseID: courseID,
            assetType: assetType,
            getCoursesInteractor: getCoursesInteractor
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
            router: environment.router,
            assetType: assetType,
            assetID: assetID
        )

        let showTabBarAndNavigationBar: (Bool) -> Void = { isVisible in
            environment.tabBar(isVisible: isVisible)
            environment.navigationBar(isVisible: isVisible)
        }
        let view = ModuleItemSequenceView(
            viewModel: viewModel,
            onShowNavigationBarAndTabBar: showTabBarAndNavigationBar
        )
        return CoreHostingController(view)
    }

    static func makeModuleNavBarView(
        nextButton: ModuleNavBarView.ButtonAttribute,
        previousButton: ModuleNavBarView.ButtonAttribute,
        assignmentMoreOptionsButton: ModuleNavBarView.ButtonAttribute? = nil,
        visibleButtons: [ModuleNavBarUtilityButtons] = []
    ) -> ModuleNavBarView {
        let router = AppEnvironment.shared.router
        return ModuleNavBarView(
            router: router,
            nextButton: nextButton,
            previousButton: previousButton,
            assignmentMoreOptionsButton: assignmentMoreOptionsButton,
            visibleButtons: visibleButtons
        )
    }

    static func makeErrorView(didTapRetry: @escaping () -> Void) -> ModuleItemSequenceErrorView {
        ModuleItemSequenceErrorView(didTapRetry: didTapRetry)
    }

    static func makeLockView(title: String, lockExplanation: String) -> ModuleItemLockedView {
        ModuleItemLockedView(title: title, lockExplanation: lockExplanation)
    }

    static func makeExternalURLView(
        name: String,
        url: URL,
        viewController: WeakViewController
    ) -> ExternalURLView {
        ExternalURLView(
            viewModel: ExternalURLViewModel(
                title: name,
                url: url,
                viewController: viewController
            )
        )
    }

    static func makeLTIView(
        tools: LTITools,
        name: String?
    ) -> LTIView {
        LTIView(
            viewModel: LTIViewModel(
                tools: tools,
                name: name
            )
        )
    }

    static func makeModuleItemView(
        viewController: UIViewController
    ) -> ModuleItemView {
        ModuleItemView(viewController: viewController)
    }

#if DEBUG
    static func makeItemSequencePreview() -> ModuleItemSequenceView {
        let viewModel = ModuleItemSequenceViewModel(
            moduleItemInteractor: ModuleItemSequenceInteractorPreview(),
            moduleItemStateInteractor: ModuleItemStateInteractorPreview(),
            router: AppEnvironment.shared.router,
            assetType: .moduleItem,
            assetID: "assetID"
        )
        let view = ModuleItemSequenceView(viewModel: viewModel, onShowNavigationBarAndTabBar: { _ in })
        return view
    }
#endif
}
