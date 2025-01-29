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

public enum DiscussionsAssembly {

    public static func makeDiscussionCreateViewController(
        context: Context,
        isAnnouncement: Bool,
        discussionListViewController: UIViewController
    ) -> UIViewController {
        let webPageModel = DiscussionCreateWebPage(
            isAnnouncement: isAnnouncement,
            discussionListViewController: discussionListViewController
        )
        return makeEmbeddedWebPage(
            context: context,
            webPageModel: webPageModel
        )
    }

    public static func makeDiscussionEditor(
        context: Context,
        topicID: String,
        isAnnouncement: Bool
    ) -> UIViewController {
        let webPageModel = DiscussionEditWebPage(
            discussionId: topicID,
            isAnnouncement: isAnnouncement
        )
        return makeEmbeddedWebPage(
            context: context,
            webPageModel: webPageModel
        )
    }

    private static func makeEmbeddedWebPage(
        context: Context,
        webPageModel: EmbeddedWebPageViewModel
    ) -> UIViewController {
        let viewModel = EmbeddedWebPageScreenViewModel(
            context: context,
            webPageModel: webPageModel
        )
        return CoreHostingController(
            EmbeddedWebPageScreen(
                viewModel: viewModel,
                isPullToRefreshEnabled: true
            )
        )
    }
}
