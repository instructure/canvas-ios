//
//  SafariActivity.swift
//  CanvasCore
//
//  Created by Nate Armstrong on 5/15/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit

class SafariActivity: UIActivity {
    var url: URL?

    override var activityTitle: String? {
        return NSLocalizedString("Open in Safari", tableName: "Localizable", bundle: .core, value: "", comment: "")
    }

    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "SafariActivity")
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
