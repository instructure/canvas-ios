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
import CanvasKeymaster
import TooLegit
import SoLazy
import Result
import ReactiveSwift
import ReactiveObjCBridge


let TheKeymaster = CanvasKeymaster.the()


extension CKIUser {
    fileprivate var sessionUser: SessionUser {
        return SessionUser(id: id, name: name, loginID: loginID, sortableName: sortableName, email: email, avatarURL: avatarURL)
    }
}

extension CKIClient {
    fileprivate var legitSession: Session {
        guard let url = baseURL else { ❨╯°□°❩╯⌢"The client doesn't have a baseURL?" }
        return Session(baseURL: url, user: currentUser.sessionUser, token: accessToken, masqueradeAsUserID: self.actAsUserID)
    }
}

extension Session {
    static var loginSignalProducer: SignalProducer<Session, NoError> {
        let login: SignalProducer<CKIClient?, NoError> = bridgedSignalProducer(from: CanvasKeymaster.the().signalForLogin).flatMapError { _ in .empty }
        return login
            .map { $0!.authSession }
            .start(on: UIScheduler())
            .observe(on: UIScheduler())
    }
    
    static var logoutSignalProducer: SignalProducer<UIViewController, NoError> {
        let logout: SignalProducer<UIViewController?, NoError> = bridgedSignalProducer(from: CanvasKeymaster.the().signalForLogout).flatMapError { _ in .empty }
        return logout
            .map { $0! }
            .start(on: UIScheduler())
            .observe(on: UIScheduler())
    }
}
