//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData
import Foundation

/// Stores whether the user accepted or declined analytics tracking.
/// If `consentValue` is `nil`, that means the consent dialog had not been presented yet,
/// (or at least the user made no action on it)
/// Only one entity should exist per user per app.
public final class CDAnalyticsConsent: NSManagedObject, WriteableModel {
    @NSManaged private var consentValueRaw: NSNumber?
    public private(set) var consentValue: Bool? {
        get { consentValueRaw?.boolValue }
        set { consentValueRaw = NSNumber(newValue) }
    }

    @discardableResult
    public static func save(
        _ item: APIAnalyticsConsent,
        in context: NSManagedObjectContext
    ) -> CDAnalyticsConsent {
        let model: CDAnalyticsConsent = context.fetch(.all).first ?? context.insert()

        if item.message == APIAnalyticsConsent.noDataMessage {
            model.consentValue = nil
        } else if let data = item.data {
            model.consentValue = data.mobile_consent
        } else {
            // This should never be reached. The usecase is expected to fail in this case.
            model.consentValue = nil
        }
        return model
    }
}
