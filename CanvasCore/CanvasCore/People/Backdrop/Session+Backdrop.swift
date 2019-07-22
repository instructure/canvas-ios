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

import ReactiveSwift

extension Session {
    fileprivate enum Associated {
        static var backdrop: Int = 0
    }
    
    @objc var backdropKey: String {
        return "\(sessionID)-backdrop"
    }
    
    var backdropFile: BackdropFile? {
        get {
            if let hash = UserDefaults.standard.object(forKey: backdropKey) as? NSNumber, let backdrop = BackdropFile.fromHash(hash.intValue) {
                self.backdropFile = backdrop
                return backdrop
            }
            
            return nil
        } set {
            UserDefaults.standard.set(newValue.map { NSNumber(value: $0.hashValue) }, forKey: backdropKey)
        }
    }
    
    public var backdropPhoto: SignalProducer<UIImage?, NSError> {
        // has the user selected a file?
        guard let file = self.backdropFile else {
            return SignalProducer(value: nil)
        }
        
        let downloader = BackdropFileDownloader.sharedDownloader
        
        return downloader
            .imageProducer(file)
            .map { $0 } // map it 2 optional
    }

    @objc public func backdropPhoto(_ completion: @escaping (UIImage?) -> ()) {
        backdropPhoto
            .observe(on: UIScheduler())
            .startWithResult { completion($0.value!) }
    }
    
    @objc public func updateBackdropFileFromServer(_ completed: @escaping (Bool)->()) {
        getBackdropOnServer(self)
            .observe(on: UIScheduler())
            .on(failed: { err in print(err.debugDescription); completed(false) })
            .startWithResult { [weak self] result in
                self?.backdropFile = result.value!
                completed(true)
            }
    }
}
