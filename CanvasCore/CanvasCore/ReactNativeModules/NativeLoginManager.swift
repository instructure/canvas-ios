//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

extension NativeLoginManager {
    public static func login(as entry: LoginSession, brand: Core.Brand = .shared) {
        var body: [String: Any] = [
            "appId": Bundle.main.isTeacherApp ? "teacher" : "student",
            "authToken": entry.accessToken ?? "",
            "refreshToken": entry.refreshToken ?? "",
            "clientID": entry.clientID ?? "",
            "clientSecret": entry.clientSecret ?? "",
            "baseURL": entry.baseURL.absoluteString,
            "branding": [
                "buttonPrimaryBackground": brand.buttonPrimaryBackground.hexString,
                "buttonPrimaryText": brand.buttonPrimaryText.hexString,
                "buttonSecondaryBackground": brand.buttonSecondaryBackground.hexString,
                "buttonSecondaryText": brand.buttonSecondaryText.hexString,
                "fontColorDark": brand.fontColorDark.hexString,
                "headerImageBackground": brand.headerImageBackground.hexString,
                "linkColor": brand.linkColor.hexString,
                "navBackground": brand.navBackground.hexString,
                "navBadgeBackground": brand.navBadgeBackground.hexString,
                "navBadgeText": brand.navBadgeText.hexString,
                "navIconFill": brand.navIconFill.hexString,
                "navIconFillActive": brand.navIconFillActive.hexString,
                "navTextColor": brand.navTextColor.hexString,
                "navTextColorActive": brand.navTextColorActive.hexString,
                "primary": brand.primary.hexString,
            ],
            "countryCode": Locale.current.regionCode ?? "",
            "locale": LocalizationManager.currentLocale ?? "en",
            "user": [
                "avatar_url": entry.userAvatarURL?.absoluteString,
                "id": entry.userID,
                "name": entry.userName,
                "primary_email": entry.userEmail,
            ],
            "isFakeStudent": entry.isFakeStudent,
            "isK5Enabled": AppEnvironment.shared.k5.isK5Enabled,
        ]
        if let actAsUserID = entry.actAsUserID {
            body["actAsUserID"] = actAsUserID
        }
        shared().login(body)
    }
}
