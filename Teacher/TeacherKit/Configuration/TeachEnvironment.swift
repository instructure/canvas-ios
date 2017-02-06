//
//  TeachEnvironment.swift
//  Teacher
//
//  Created by Derrick Hathaway on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SixtySix

// MARK: I'm Sooooo Lazy Sometimes
public typealias TEnv = TeacherEnvironment

extension TEnv {
    
    /**
     A shortcut for handling operations that might fail.
     
     This will use the current errorHandler to handle any errors thrown by `f`
    
     @param viewController passed along to the current environment's `errorHandler` which by default will present an alert dialog from `viewController`
     @param f a function that might fail
    */
    public static func `try`(in viewController: UIViewController? = nil, f: () throws -> ()) {
        do { try f() }
        catch let e as NSError {
            current.errorHandler.handle(error: e, from: viewController)
        }
    }
}


// MARK: The environment for teacher app

public struct TeacherEnvironment {
    
    public let session: Session
    public let router: Router
    public let presenter: Presenter
    public let errorHandler: ErrorHandler
    
    public static var current: TEnv! {
        return stack.last
    }
    
    public static func replaceCurrentEnvironment(
        session: Session = TEnv.current.session,
        router: Router = TEnv.current.router,
        presenter: Presenter = TEnv.current.presenter,
        errorHandler: ErrorHandler = TEnv.current.errorHandler) {
        
        replaceCurrentEnvironment(
            TEnv(
                session: session,
                router: router,
                presenter: presenter,
                errorHandler: errorHandler
            )
        )
    }
    
    public static func replaceCurrentEnvironment(_ env: TEnv) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }
    
    public static func pushEnvironment(
        session: Session = TEnv.current.session,
        router: Router = TEnv.current.router,
        presenter: Presenter = TEnv.current.presenter,
        errorHandler: ErrorHandler = TEnv.current.errorHandler) {
     
        pushEnvironment(
            TEnv(
                session: session,
                router: router,
                presenter: presenter,
                errorHandler: errorHandler
            )
        )
    }
    
    public static func pushEnvironment(_ env: TEnv) {
        stack.append(env)
    }
    
    private static var stack: [TEnv] = [TEnv()]
    
    private init(
        session: Session = .unauthenticated,
        router: Router = Router(),
        presenter: Presenter = PushPresenter(),
        errorHandler: ErrorHandler = ReportErrorHandler()) {
        
        self.session = session
        self.router = router
        self.presenter = presenter
        self.errorHandler = errorHandler
    }
}
