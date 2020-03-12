//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

struct PropKeys {
    // View controller stuff
    static let title = "title"
    static let subtitle = "subtitle"
    static let automaticallyAdjustsScrollViewInsets = "automaticallyAdjustsScrollViewInsets"
    static let supportedOrientations = "supportedOrientations"
    static let noRotationInVerticallyCompact = "noRotationInVerticallyCompact"
    static let backgroundColor = "backgroundColor"
    
    // Nav bar stuff
    static let navBarStyle = "navBarStyle"
    static let navBarColor = "navBarColor"
    static let navBarHidden = "navBarHidden"
    static let navBarImage = "navBarImage"
    static let navBarTransparent = "navBarTransparent"
    static let drawUnderNavBar = "drawUnderNavBar"
    static let drawUnderTabBar = "drawUnderTabBar"
    static let leftBarButtons = "leftBarButtons"
    static let rightBarButtons = "rightBarButtons"
    static let backButtonTitle = "backButtonTitle"
    static let dismissButtonTitle = "dismissButtonTitle"
    static let showDismissButton = "showDismissButton"
    static let navigatorOptions = "navigatorOptions"
    
    static let modal = "modal"
    static let modalPresentationStyle = "modalPresentationStyle"
    static let modalTransitionStyle = "modalTransitionStyle"

    static let disableDismissOnSwipe = "disableSwipeDownToDismissModal"
}
