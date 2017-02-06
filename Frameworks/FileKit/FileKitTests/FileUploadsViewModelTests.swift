//
//  FileUploadsViewModelTests.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/25/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoAutomated
import Nimble
import XCTest
@testable import FileKit
import ReactiveSwift
import Result
import TooLegit
import CoreData

class FileUploadsViewModelTest: XCTestCase {
    let session = Session.user1
    let vm: FileUploadsViewModelType = FileUploadsViewModel()

    let cancelled = TestObserver<Void, NoError>()

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        self.context = try! session.filesManagedObjectContext()
        self.vm.outputs.cancelled.observe(self.cancelled.observer)
    }

    func testInputs_tappedCancel() {
        context.performAndWait {
            let batch = FileUploadBatch.template(session: self.session)
            try! self.context.save()
            self.vm.inputs.configureWith(session: self.session, batch: batch)
        }

        self.vm.inputs.tappedCancel()
        expect(self.cancelled.values.count).toEventually(equal(1))
    }
}
