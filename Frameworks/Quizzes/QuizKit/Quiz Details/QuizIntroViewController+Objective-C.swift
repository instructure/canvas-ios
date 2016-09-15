//
//  Quizzes+Objective-C.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 3/27/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import TooLegit


extension QuizIntroViewController {
    public convenience init(session: Session, quizURL: NSURL, quizID: String) {
        let components = NSURLComponents(URL:quizURL, resolvingAgainstBaseURL: false)
        components?.path = nil
        components?.query = nil
        components?.fragment = nil

        let context = ContextID(url: quizURL)!
        let service = CanvasQuizService(session: session, context: context, quizID: quizID)
        let controller = QuizController(service: service, quiz: nil)

        self.init(quizController: controller)
    }
}