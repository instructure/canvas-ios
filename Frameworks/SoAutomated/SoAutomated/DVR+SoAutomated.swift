//
//  DVR+SoAutomated.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 4/14/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import DVR

// Ugh. Not sure why but occassionally we get 'unrecognized selector sent to DVR.Session'.
// These patch those holes.
extension DVR.Session {
    public override func finishTasksAndInvalidate() {
        //  no-op
    }

    public override func invalidateAndCancel() {
        // no-op
    }

    public var _local_immutable_configuration: NSURLSessionConfiguration {
        return NSURLSessionConfiguration.defaultSessionConfiguration()
    }

    public var workQueue: Unmanaged<AnyObject> {
        return backingSession.performSelector(Selector("workQueue"))
    }

    public func _onqueue_getTasksWithCompletionHandler(handler: Unmanaged<AnyObject>) {
        return
    }
}
