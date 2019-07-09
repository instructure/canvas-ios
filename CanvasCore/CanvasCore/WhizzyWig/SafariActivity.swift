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

class SafariActivity: UIActivity {
    @objc var url: URL?

    override var activityTitle: String? {
        return NSLocalizedString("Open in Safari", tableName: "Localizable", bundle: .core, value: "", comment: "")
    }

    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "SafariActivity")
    }

    override var activityImage: UIImage? {
        return UIImage(named: "safari_activity", in: .core, compatibleWith: nil)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activityItem in activityItems {
            if activityItem is URL {
                return true
            }
        }
        return false
    }

    public override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if let url = activityItem as? URL {
                self.url = url
                break
            }
        }
    }

    public override func perform() {
        guard let url = url else {
            activityDidFinish(false)
            return
        }
        UIApplication.shared.open(url, options: [:]) { [weak self] completed in
            self?.activityDidFinish(completed)
        }
    }
}
