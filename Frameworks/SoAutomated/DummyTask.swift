//
//  DummyTask.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 1/12/17.
//  Copyright © 2017 instructure. All rights reserved.
//

public class DummyTask: URLSessionTask {
    override public var taskIdentifier: Int {
        get { return 1 }
        set {}
    }
}
