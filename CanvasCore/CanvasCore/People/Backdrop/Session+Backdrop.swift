//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    


import Result
import ReactiveSwift

extension Session {
    fileprivate enum Associated {
        static var backdrop: Int = 0
    }
    
    var backdropKey: String {
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

    public func backdropPhoto(_ completion: @escaping (UIImage?) -> ()) {
        backdropPhoto
            .observe(on: UIScheduler())
            .startWithResult { completion($0.value!) }
    }
    
    public func updateBackdropFileFromServer(_ completed: @escaping (Bool)->()) {
        getBackdropOnServer(self)
            .observe(on: UIScheduler())
            .on(failed: { err in print(err.debugDescription); completed(false) })
            .startWithResult { [weak self] result in
                self?.backdropFile = result.value!
                completed(true)
            }
    }
}
