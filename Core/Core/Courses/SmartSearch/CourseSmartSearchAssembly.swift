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

import SwiftUI

public enum CourseSmartSearchAssembly {

    public static func make<Content: View>(context: Context, color: UIColor?, containing content: Content) -> UIViewController {
        let attributes = CourseSmartSearchViewAttributes(context: context, color: color)
        let interactor = CourseSmartSearchInteractorLive(context: context)
        let provider = CourseSmartSearchViewsProvider(interactor: interactor)
        return CoreSearchHostingController(
            attributes: attributes,
            provider: provider,
            interactor: interactor,
            content: content
        )
    }

    #if DEBUG
    public static func makePreview<Content: View>(context: Context, color: UIColor?, containing content: Content) -> UIViewController {
        let attributes = CourseSmartSearchViewAttributes(context: context, color: color)
        let interactor = CourseSmartSearchInteractorPreview()
        let provider = CourseSmartSearchViewsProvider(interactor: interactor)
        return CoreSearchHostingController(
            attributes: attributes,
            provider: provider,
            interactor: interactor,
            content: content
        )
    }
    #endif
}
