//
//  Session+Backdrop.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 5/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import Result
import ReactiveCocoa

extension Session {
    private enum Associated {
        static var backdrop: Int = 0
    }
    
    var backdropKey: String {
        return "\(sessionID)-backdrop"
    }
    
    var backdropFile: BackdropFile? {
        get {
            if let hash = NSUserDefaults.standardUserDefaults().objectForKey(backdropKey) as? NSNumber, backdrop = BackdropFile.fromHash(hash.integerValue) {
                self.backdropFile = backdrop
                return backdrop
            }
            
            return nil
        } set {
            NSUserDefaults.standardUserDefaults().setObject(newValue.map { NSNumber(integer: $0.hashValue) }, forKey: backdropKey)
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

    public func backdropPhoto(completion: (UIImage?) -> ()) {
        backdropPhoto
            .observeOn(UIScheduler())
            .startWithNext(completion)
    }
    
    public func updateBackdropFileFromServer(completed: Bool->()) {
        getBackdropOnServer(self)
            .observeOn(UIScheduler())
            .on(failed: { err in print(err.debugDescription); completed(false) })
            .startWithNext { [weak self] file in
                self?.backdropFile = file
                completed(true)
            }
    }
}
