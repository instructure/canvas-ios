//
//  LoadingQuestionsView.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 4/30/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

class LoadingQuestionsView: UIView {
    class func goGoGadgetLoadingQuestionsView() -> LoadingQuestionsView {
        let nib = UINib(nibName: "LoadingQuestionsView", bundle: NSBundle(forClass: LoadingQuestionsView.classForCoder()))
        
        return nib.instantiateWithOwner(nil, options: nil).first as! LoadingQuestionsView
    }
}
