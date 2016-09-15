//
//  NSURLSession+SoLazy.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 4/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension NSURLSession {
    public func getAllTheTasksWithCompletionHandler(completionHandler: [NSURLSessionTask]->Void) {
        if #available(iOS 9, *) {
            getAllTasksWithCompletionHandler(completionHandler)
            return
        }
        getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let tasks = (dataTasks as [NSURLSessionTask]) + (uploadTasks as [NSURLSessionTask]) + (downloadTasks as [NSURLSessionTask])
            completionHandler(tasks)
        }
    }
}
