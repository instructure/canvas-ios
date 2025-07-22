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

struct PageDetailsAssembly {
    static func makeView(
        courseID: String,
        assetID: String,
        assetType: GetModuleItemSequenceRequest.AssetType
    ) -> UIViewController {
        CoreHostingController(
            PageDetailsView(
                viewModel: PageDetailsViewModel(
                    courseID: courseID,
                    assetID: assetID,
                    assetType: assetType,
                    moduleItemSequenceInteractor: ModuleItemSequenceInteractorLive(
                        courseID: courseID,
                        getCoursesInteractor: GetCoursesInteractorLive()
                    )
                )
            )
        )
    }

    static func makeView(context: Core.Context,
                         pageURL: String,
                         isCompletedItem: Bool,
                         isMarkedAsDoneButtonVisible: Bool,
                         moduleID: String,
                         itemID: String) -> PageDetailsView {

        let interactor = ModuleItemSequenceInteractorLive(
            courseID: context.id,
            getCoursesInteractor: GetCoursesInteractorLive()
        )
        let viewModel = PageDetailsViewModel(
            context: context,
            pageURL: pageURL,
            itemID: itemID,
            markAsDoneViewModel: .init(
                moduleID: moduleID,
                itemID: itemID,
                isCompleted: isCompletedItem,
                moduleItemSequenceInteractor: interactor
            )
        )
        return PageDetailsView(viewModel: viewModel)
    }
}
