//
//  ProgressDispatcher.swift
//  SoProgressive
//
//  Created by Derrick Hathaway on 4/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public class ProgressDispatcher: NSObject {
    private var pipe = Signal<Progress, NoError>.pipe()
    
    public var onProgress: Signal<Progress, NoError> {
        return pipe.0
    }
    
    public func dispatch(progress: Progress) {
        pipe.1.sendNext(progress)
    }
}


