//
//  MockCKIClient.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import Foundation

class MockCKIClient: CKIClient {
    enum Method {
        case Fetch, Create, Delete
    }
    
    var capturedPath: NSString? = nil
    var capturedParameters: [NSObject : AnyObject]? = nil
    var capturedModelClass: AnyClass? = nil
    var capturedContext: CKIContext? = nil
    var capturedMethod: Method? = nil
    
    override func fetchResponseAtPath(path: String!, parameters: [NSObject : AnyObject]!, modelClass: AnyClass!, context: CKIContext!) -> RACSignal! {
        capturedPath = path
        capturedParameters = parameters
        capturedModelClass = modelClass
        capturedContext = context
        capturedMethod = .Fetch
        
        return RACSignal.empty()
    }
    
    override func createModelAtPath(path: String!, parameters: [NSObject : AnyObject]!, modelClass: AnyClass!, context: CKIContext!) -> RACSignal! {
        capturedPath = path
        capturedParameters = parameters
        capturedModelClass = modelClass
        capturedContext = context
        capturedMethod = .Create
        
        return RACSignal.empty()
    }
    
    override func deleteObjectAtPath(path: String!, modelClass: AnyClass!, parameters: [NSObject : AnyObject]!, context: CKIContext!) -> RACSignal! {
        capturedPath = path
        capturedParameters = parameters
        capturedModelClass = modelClass
        capturedContext = context
        capturedMethod = .Delete
        
        return RACSignal.empty()
    }
    
    
    
}