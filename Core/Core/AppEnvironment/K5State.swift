//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class K5State {
    /** This flag indicates that the logged in user requested K5 mode. The app might not follow this if the K5 feature flag is turned off. */
    public var shouldUseK5Mode = false {
        didSet {
            UITabBar.updateFontAppearance(useK5Fonts: isK5Enabled)
            UIBarButtonItem.updateFontAppearance(useK5Fonts: isK5Enabled)
            UISegmentedControl.updateFontAppearance()
        }
    }
    /** This flag indicates if K5 mode is turned on and should be used. */
    public var isK5Enabled: Bool { shouldUseK5Mode && ExperimentalFeature.K5Dashboard.isEnabled }

    public func userDidLogout() {
        shouldUseK5Mode = false
    }
}
