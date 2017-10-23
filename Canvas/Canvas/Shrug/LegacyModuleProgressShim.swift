//
// Copyright (C) 2016-present Instructure, Inc.
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
import TechDebt
import CanvasKit
import CanvasCore

/** Keeps TechDebt Modules and Assignments UI up to date course progress
 */
open class LegacyModuleProgressShim: NSObject {
    open static func observeProgress(_ session: Session) {
        NotificationCenter.default.addObserver(session, selector: #selector(Session.legacyModuleItemProgressUpdated(_:)), name: NSNotification.Name.CBIModuleItemProgressUpdated, object: nil)
    }
}

extension Session {
    func legacyModuleItemProgressUpdated(_ note: NSNotification) {
        if let progress = Progress(contextID: ContextID(id: user.id, context: .user), notification: note) {
            progressDispatcher.dispatch(progress)
        }
    }
}

extension CanvasCore.Progress {
    init?(contextID: ContextID, notification: NSNotification) {
        guard let
            id = notification.userInfo?[CBIUpdatedModuleItemIDStringKey] as? String,
            let noteKind = notification.userInfo?[CBIUpdatedModuleItemTypeKey] as? String
        else {
            return nil
        }

        let kind: CanvasCore.Progress.Kind
        switch noteKind {
        case CKIModuleItemCompletionRequirementMustView:
            kind = .viewed
        case CKIModuleItemCompletionRequirementMustSubmit:
            kind = .submitted
        case CKIModuleItemCompletionRequirementMustContribute:
            kind = .contributed
        case CKIModuleItemCompletionRequirementMustMarkDone:
            kind = .markedDone
        case CKIModuleItemCompletionRequirementMinimumScore:
            kind = .minimumScore
        default: fatalError("Unknown completion requirement")
        }

        self.kind = kind
        self.contextID = contextID
        self.itemType = .legacyModuleProgressShim
        self.itemID = id
    }
}
