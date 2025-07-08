//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Core

class FilePickerViewModelTests: CoreTestCase {
    var testee: FilePickerViewModel!

    private let interactor = FilePickerInteractorPreview()
    private var onSelectCalled = false

    override func setUp() {
        super.setUp()
        testee = FilePickerViewModel(interactor: interactor, router: router, onSelect: onSelect)
    }

    func testOutputBindings() {
        XCTAssertEqual(testee.folderItems, [])
        XCTAssertEqual(testee.state, .loading)

        let values = [FolderItem()]
        interactor.folderItems.send(values)
        interactor.state.send(.data)

        XCTAssertEqual(testee.folderItems, values)
        XCTAssertEqual(testee.state, .data)
    }

    func testCancelButton() {
        testee.didTapCancel.accept(WeakViewController())

        XCTAssertNotNil(router.dismissed)
    }

    func testFileSelection() {
        XCTAssertFalse(onSelectCalled)
        testee.didTapFile.accept((WeakViewController(), File.make()))
        XCTAssertTrue(onSelectCalled)

        XCTAssertNotNil(router.dismissed)
    }

    func testFolderSelection() {
        let from = WeakViewController()
        testee.didTapFolder.accept((from, Folder.save(APIFolder.make(), in: databaseClient)))

        wait(for: [router.showExpectation], timeout: 1)

        XCTAssertNotNil(router.lastViewController)
    }

    private func onSelect(file: File) {
        onSelectCalled = true
    }
}
