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

let InstUserLocale = "InstUserLocale"
public class LocalizationManager: NSObject {
    private static var effectiveLocale: String? {
        return Bundle.main.preferredLocalizations.first
    }

    @objc public static var currentLocale: String? {
        return UserDefaults.standard.string(forKey: InstUserLocale) ?? effectiveLocale
    }

    public static var needsRestart: Bool {
        return currentLocale != effectiveLocale
    }

    @objc
    public static func getLocales () -> [[String: String]] {
        return Bundle.main.localizations.filter { id in id != "Base" }.map { id in
            return [
                "name": Locale.current.localizedString(forIdentifier: id) ?? id,
                "languageCode": id,
            ]
        }.sorted { a, b in
            return a["name"] ?? "" < b["name"] ?? ""
        }
    }

    @objc
    public static func setCurrentLocale(_ locale: String) {
        // da-x-k12 -> da-instk12
        let newLocale = locale.replacingOccurrences(of: "-x-", with: "-inst")
        guard Bundle.main.localizations.contains(newLocale) else { return }

        UserDefaults.standard.set(newLocale, forKey: InstUserLocale)
        UserDefaults.standard.set([newLocale], forKey: "AppleLanguages")

        guard Bundle.main.preferredLocalizations.first != newLocale else { return }
        guard let root = HelmManager.shared.topMostViewController() ?? UIApplication.shared.keyWindow?.rootViewController else { return }
        let alert = UIAlertController(title: NSLocalizedString("Updated Language Settings", bundle: .core, comment: ""), message: NSLocalizedString("The app needs to restart to use the new language settings. Please relaunch the app.", bundle: .core, comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close App", bundle: .core, comment: ""), style: .default) { _ in
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        })
        root.present(alert, animated: true)
        HelmManager.shared.onReactLoginComplete = {} // don't show dashboard
    }

    @objc public static func closed() {
        if needsRestart {
            exit(EXIT_SUCCESS)
        }
    }
}
