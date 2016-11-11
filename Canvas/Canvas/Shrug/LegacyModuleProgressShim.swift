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
import SoProgressive
import TooLegit
import TechDebt
import CanvasKit
import SoEdventurous

/** Keeps TechDebt Modules and Assignments UI up to date course progress
 */
public class LegacyModuleProgressShim: NSObject {
    public static func observeProgress(session: Session) {
        NSNotificationCenter.defaultCenter().addObserver(session, selector: #selector(Session.legacyModuleItemProgressUpdated(_:)), name: CBIModuleItemProgressUpdatedNotification, object: nil)
    }
}

extension Session {
    func legacyModuleItemProgressUpdated(note: NSNotification) {
        if let progress = Progress(contextID: ContextID(id: user.id, context: .User), notification: note) {
            progressDispatcher.dispatch(progress)
        }
    }
}

extension Progress {
    init?(contextID: ContextID, notification: NSNotification) {
        guard let
            id = notification.userInfo?[CBIUpdatedModuleItemIDStringKey] as? String,
            noteKind = notification.userInfo?[CBIUpdatedModuleItemTypeKey] as? String
        else {
            return nil
        }

        let kind: Progress.Kind
        switch noteKind {
        case CKIModuleItemCompletionRequirementMustView:
            kind = .Viewed
        case CKIModuleItemCompletionRequirementMustSubmit:
            kind = .Submitted
        case CKIModuleItemCompletionRequirementMustContribute:
            kind = .Contributed
        case CKIModuleItemCompletionRequirementMustMarkDone:
            kind = .MarkedDone
        case CKIModuleItemCompletionRequirementMinimumScore:
            kind = .MinimumScore
        default: fatalError("Unknown completion requirement")
        }

        self.kind = kind
        self.contextID = contextID
        self.itemType = .LegacyModuleProgressShim
        self.itemID = id
    }
}
