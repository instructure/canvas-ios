//
//  Page+ViewModel.swift
//  Canvas
//
//  Created by Joseph Davison on 6/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import PageKit
import TooLegit
import SoPersistent
import ReactiveCocoa
import EnrollmentKit

extension Page {

    static func colorfulPageViewModel(session session: Session, page: Page) -> ColorfulViewModel {
        let vm = ColorfulViewModel(style: .Token)
        vm.title.value = page.title
        if page.frontPage {
            vm.tokenViewText.value = NSLocalizedString("Front Page", comment: "badge indicating front page")
        }
        vm.color <~ session.enrollmentsDataSource.producer(page.contextID)
            .map { $0?.color ?? .prettyGray() }

        return vm
    }

}

