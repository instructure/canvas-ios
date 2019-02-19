//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class LocalizationManager {
    private static let instUserLocale = "InstUserLocale"

    private static var effectiveLocale: String? {
        return Bundle.main.preferredLocalizations.first
    }

    public static var currentLocale: String? {
        return UserDefaults.standard.string(forKey: instUserLocale) ?? effectiveLocale
    }

    public static func getLocales () -> [(id: String, name: String)] {
        return Bundle.main.localizations.filter { id in id != "Base" }.map { id in
            return (id: id, name: Locale.current.localizedString(forIdentifier: id) ?? id)
        }.sorted { a, b in
            return a.name < b.name
        }
    }

    public static func setCurrentLocale(_ locale: String?) {
        // da-x-k12 -> da-instk12
        let newLocale = locale?.replacingOccurrences(of: "-x-", with: "-inst") ?? ""
        guard Bundle.main.localizations.contains(newLocale) else { return }

        UserDefaults.standard.set(newLocale, forKey: instUserLocale)
        UserDefaults.standard.set([newLocale], forKey: "AppleLanguages")
    }

    public static var needsRestart: Bool {
        return currentLocale != effectiveLocale
    }
}
