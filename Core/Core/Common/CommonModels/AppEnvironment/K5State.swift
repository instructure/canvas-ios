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
    /** This flag indicates that the logged in user is under a K5 enabled account. The app might not follow this if the K5 feature flag is turned off. */
    public private(set) var isK5Account = false {
        didSet {
            Appearance.update()
        }
    }
    public var isRemoteFeatureFlagEnabled: Bool { ExperimentalFeature.K5Dashboard.isEnabled }
    /** Reflects the sate of the local switch in the options menu. */
    public var isElementaryViewEnabled: Bool { sessionDefaults?.isElementaryViewEnabled ?? false }
    /** External dependency. */
    public var sessionDefaults: SessionDefaults?

    /**
     This flag indicates if K5 mode is turned on and should be used.
     True if all of these flags are true: `isK5Account`, `isRemoteFeatureFlagEnabled`, `isElementaryViewEnabled`.
     */
    public var isK5Enabled: Bool { isK5Account && isRemoteFeatureFlagEnabled && isElementaryViewEnabled }

    public func userDidLogin(profile: APIProfile?, isK5StudentView: Bool = false) {
        isK5Account = (profile?.k5_user == true) || isK5StudentView == true
    }

    public func userDidLogin(isK5Account: Bool) {
        self.isK5Account = isK5Account
    }

    public func userDidLogout() {
        isK5Account = false
        sessionDefaults?.isK5StudentView = false
    }
}
