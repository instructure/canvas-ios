//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore
import Core

/** Keeps Modules and Assignments UI up to date course progress
 */
open class LegacyModuleProgressShim: NSObject {
    @objc public static func observeProgress(_ session: Session) {
        NotificationCenter.default.addObserver(session, selector: #selector(Session.legacyModuleItemProgressUpdated(_:)), name: NSNotification.Name(rawValue: "CBIModuleItemProgressUpdated"), object: nil)
    }
}

extension Session {
    @objc func legacyModuleItemProgressUpdated(_ note: NSNotification) {
        if let progress = Progress(contextID: .user(user.id), notification: note) {
            progressDispatcher.dispatch(progress)
        }
    }
}

extension CanvasCore.Progress {
    init?(contextID: Context, notification: NSNotification) {
        guard let
            id = notification.userInfo?["CBIUpdatedModuleItemIDStringKey"] as? String,
            let noteKind = notification.userInfo?["CBIUpdatedModuleItemTypeKey"] as? String
        else {
            return nil
        }

        let kind: CanvasCore.Progress.Kind
        switch noteKind {
        case "must_view":
            kind = .viewed
        case "must_submit":
            kind = .submitted
        case "must_contribute":
            kind = .contributed
        case "must_mark_done":
            kind = .markedDone
        case "min_score":
            kind = .minimumScore
        default: fatalError("Unknown completion requirement")
        }

        self.init(kind: kind, contextID: contextID, itemType: .legacyModuleProgressShim, itemID: id)
    }
}
