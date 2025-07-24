//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import Combine

public enum LocalizationManager {
    private static let instUserLocale = "InstUserLocale"
    static var suspend = #selector(NSXPCConnection.suspend)

    private static var effectiveLocale: String? {
        return Bundle.main.preferredLocalizations.first
    }

    public static var currentLocale: String? {
        return UserDefaults.standard.string(forKey: instUserLocale) ?? effectiveLocale
    }

    public static var needsRestart: Bool {
        return currentLocale != effectiveLocale
    }

    static func convertCustomLocale(_ locale: String?) -> String {
        var newLocale = locale ?? ""
        // da-x-k12 -> da-instk12, en-AU-x-unimelb -> en-AU-unimelb
        let parts = newLocale.components(separatedBy: "-x-")
        if var custom = parts.count == 2 ? parts[1] : nil {
            if custom.count < 5 {
                custom = "inst\(custom)"
            } else if custom.count > 8 {
                custom = String(custom.dropLast(custom.count - 8))
            }
            newLocale = "\(parts[0])-\(custom)"
        }
        return newLocale
    }

    static func setCurrentLocale(_ locale: String?) {
        let newLocale = convertCustomLocale(locale)
        guard Bundle.main.localizations.contains(newLocale) else { return }

        UserDefaults.standard.set(newLocale, forKey: instUserLocale)
        UserDefaults.standard.set([newLocale], forKey: "AppleLanguages")
    }

    public static func localizeForApp(_ app: UIApplication, locale: String?, then: () -> Void) {
        setCurrentLocale(locale)
        let env = AppEnvironment.shared
        guard needsRestart, let root = env.window?.rootViewController else { return then() }
        let alert = UIAlertController(
            title: String(localized: "Updated Language Settings", bundle: .core),
            message: String(localized: "The app needs to restart to use the new language settings. Please relaunch the app.", bundle: .core),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(String(localized: "Close App", bundle: .core), style: .default) { _ in
            UIControl().sendAction(suspend, to: app, for: nil)
        })
        if let presented = root.presentedViewController { // QR login alert
            env.router.dismiss(presented) {
                env.router.show(alert, from: root, options: .modal())
            }
        } else {
            env.router.show(alert, from: root, options: .modal())
        }
    }

    public static func localizeForApp(
        _ app: UIApplication,
        locale: String?
    ) -> AnyPublisher<UIAlertController?, Never> {
        setCurrentLocale(locale)
        let env = AppEnvironment.shared
        guard
            needsRestart,
            env.window?.rootViewController != nil else {
            return Just(nil).eraseToAnyPublisher()
        }
        let alert = UIAlertController(
            title: String(localized: "Updated Language Settings", bundle: .core),
            message: String(localized: "The app needs to restart to use the new language settings. Please relaunch the app.", bundle: .core),
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(String(localized: "Close App", bundle: .core), style: .default) { _ in
            UIControl().sendAction(suspend, to: app, for: nil)
        })
        return Just(alert).eraseToAnyPublisher()
    }
}
