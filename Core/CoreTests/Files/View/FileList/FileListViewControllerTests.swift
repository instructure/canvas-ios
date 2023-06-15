//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import XCTest
@testable import Core
@testable import TestsFoundation

class FileListViewControllerTests: CoreTestCase {
    lazy var controller = FileListViewController.create(context: .currentUser, path: "Folder A")

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
            "group_1": "#00f",
        ]))
        api.mock(controller.folder, value: [
            .make(),
            .make(full_name: "my files/Folder A", id: "2", name: "Folder A", parent_folder_id: "1"),
        ])
        api.mock(GetFilesRequest(context: Context(.folder, id: "2")), value: [ .make(folder_id: "2") ])
        api.mock(GetFoldersRequest(context: Context(.folder, id: "2")), value: [
            .make(full_name: "my files/Folder A/B", id: "3", name: "B", parent_folder_id: "2"),
        ])
    }

    func testCreate() {
        XCTAssertEqual(FileListViewController.create(context: .currentUser, path: nil).path, "")
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()
        XCTAssertEqual(controller.titleSubtitleView.title, "Folder A")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)

        var index = IndexPath(row: 0, section: 2)
        var cell = controller.tableView.cellForRow(at: index) as? FileListCell
        XCTAssertEqual(cell?.iconView.icon, .folderSolid)
        XCTAssertEqual(cell?.nameLabel.text, "B")
        XCTAssertEqual(cell?.sizeLabel.text, "2 items")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/users/self/files/folder/Folder A/B"))

        index = IndexPath(row: 1, section: 2)
        cell = controller.tableView.cellForRow(at: index) as? FileListCell
        XCTAssertEqual(cell?.iconView.icon, .imageLine)
        XCTAssertEqual(cell?.nameLabel.text, "File")
        XCTAssertEqual(cell?.sizeLabel.text, "1 KB")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/users/self/files/1"))

        api.mock(GetFilesRequest(context: .currentUser, searchTerm: "Nada"), value: [])
        controller.searchBar.delegate?.searchBarTextDidBeginEditing?(controller.searchBar)
        controller.searchBar.text = "Nada"
        controller.searchBar.delegate?.searchBar?(controller.searchBar, textDidChange: "Nada")
        controller.searchBar.delegate?.searchBarSearchButtonClicked?(controller.searchBar)
        controller.searchBar.delegate?.searchBarTextDidEndEditing?(controller.searchBar)
        XCTAssertEqual(controller.emptyView.isHidden, false)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 0)

        api.mock(GetFilesRequest(context: .currentUser, searchTerm: "File"), value: [
            .make(),
            .make(created_at: Clock.now.add(.day, number: -1), thumbnail_url: URL(string: "/")),
        ])
        controller.searchBar.delegate?.searchBarTextDidBeginEditing?(controller.searchBar)
        controller.searchBar.text = "File"
        controller.searchBar.delegate?.searchBar?(controller.searchBar, textDidChange: "Fi")
        controller.searchBar.delegate?.searchBar?(controller.searchBar, textDidChange: "File")
        controller.searchBar.delegate?.searchBar?(controller.searchBar, textDidChange: "File")
        controller.searchBar.delegate?.searchBarSearchButtonClicked?(controller.searchBar)
        controller.searchBar.delegate?.searchBarTextDidEndEditing?(controller.searchBar)
        XCTAssertEqual(controller.emptyView.isHidden, true)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 2)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 0)

        index = IndexPath(row: 0, section: 1)
        cell = controller.tableView.cellForRow(at: index) as? FileListCell
        XCTAssertEqual(cell?.iconView.icon, .imageLine)
        XCTAssertEqual(cell?.nameLabel.text, "File")
        XCTAssertEqual(cell?.sizeLabel.text, "1 KB")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssert(router.lastRoutedTo("/users/self/files/1"))

        api.mock(controller.folder, value: [
            .make(full_name: "my files/Folder A", id: "2", name: "Folder Refresh", parent_folder_id: "1"),
        ])
        api.mock(GetFilesRequest(context: Context(.folder, id: "2")), value: [
            .make(folder_id: "2", display_name: "Picture", created_at: Clock.now.add(.day, number: -1), thumbnail_url: URL(string: "/")),
        ])
        controller.tableView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false) // stops refreshing

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 2)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 0)

        controller.searchBar.delegate?.searchBarCancelButtonClicked?(controller.searchBar)
        XCTAssertEqual(controller.emptyView.isHidden, true)
        XCTAssertEqual(controller.searchBar.text, "")
        XCTAssertEqual(controller.tableView.contentOffset.y, controller.searchBar.frame.height)

        drainMainQueue()

        index = IndexPath(row: 1, section: 2)
        cell = controller.tableView.cellForRow(at: index) as? FileListCell
        XCTAssertEqual(cell?.nameLabel.text, "Picture")
        XCTAssertEqual(controller.titleSubtitleView.title, "Folder Refresh")

        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.contains(controller.editButton), true)
        _ = controller.editButton.target?.perform(controller.editButton.action)
        XCTAssert(router.lastRoutedTo("/folders/2/edit", withOptions: .modal(isDismissable: false, embedInNav: true)))

        controller.tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        XCTAssertNoThrow(controller.viewWillDisappear(false))
        controller.viewWillAppear(false)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    func testCourseContext() {
        api.mock(GetCourse(courseID: "1"), value: .make())
        controller = FileListViewController.create(context: .course("1"))
        api.mock(controller.folder, value: [
            .make(context_type: "Course", context_id: "1", id: "2"),
        ])
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()

        XCTAssertEqual(controller.titleSubtitleView.title, "Files")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testGroupContext() {
        api.mock(GetGroup(groupID: "1"), value: .make())
        controller = FileListViewController.create(context: .group("1"))
        api.mock(controller.folder, value: [
            .make(context_type: "Group", context_id: "1", id: "2"),
        ])
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()

        XCTAssertEqual(controller.titleSubtitleView.title, "Files")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Group One")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }

    func testRenamedAndDeleted() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()

        XCTAssertEqual(controller.titleSubtitleView.title, "Folder A")

        api.mock(controller.folder, value: [
            .make(full_name: "my files/Folder Z", id: "2", name: "Folder Z", parent_folder_id: "1"),
        ])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)

        XCTAssertEqual(controller.titleSubtitleView.title, "Folder Z")
        XCTAssertEqual(controller.path, "Folder Z")
        XCTAssertEqual(controller.folder.useCase.path, "Folder Z")

        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)

        api.mock(controller.folder, value: [])
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.dismissed === controller)
    }

    func testAddFolder() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()

        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.contains(controller.addButton), true)
        _ = controller.addButton.target?.perform(controller.addButton.action)
        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.first?.title, "Add Folder")
        sheet?.actions.first?.action()

        let prompt = router.presented as? UIAlertController
        XCTAssertEqual(prompt?.textFields?.first?.placeholder, "Name")

        api.mock(CreateFolder(context: .currentUser, name: "Added", parentFolderID: "2"), value: .make(
            full_name: "my files/Folder A/Added", id: "8", name: "Added", parent_folder_id: "2"
        ))
        prompt?.textFields?.first?.text = ""
        XCTAssertEqual(prompt?.actions.first?.title, "Cancel")
        XCTAssertEqual(prompt?.actions.last?.title, "OK")
        (prompt?.actions.last as? AlertAction)?.handler?(UIAlertAction())
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 2), 2)

        prompt?.textFields?.first?.text = "Added"
        (prompt?.actions.last as? AlertAction)?.handler?(UIAlertAction())
        let items: [FolderItem] = databaseClient.fetch(scope: controller.items!.useCase.scope)
        XCTAssertEqual(items.count, 3)
    }

    func testAddFile() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.contains(controller.addButton), true)
        _ = controller.addButton.target?.perform(controller.addButton.action)
        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertEqual(sheet?.actions.last?.title, "Add File")
        router.calls = []
        sheet?.actions.last?.action()
        XCTAssert(router.presented is BottomSheetPickerViewController)

        controller.filePicker.delegate?.filePicker(didPick: URL(string: "picked")!)
        XCTAssertEqual(uploadManager.uploadWasCalled, true)
        uploadManager.uploadWasCalled = false

        controller.filePicker.delegate?.filePicker(didRetry: File.make())
        XCTAssertEqual(uploadManager.uploadWasCalled, true)

        File.make(from: .make(id: "1", folder_id: "2"), batchID: controller.batchID, removeURL: true, taskID: "7", session: currentSession)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 1)
        let upload = controller.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FileListUploadCell
        XCTAssertEqual(upload?.iconView.isHidden, true)
        XCTAssertEqual(upload?.nameLabel.text, "File.jpg")
        XCTAssertEqual(upload?.progressView.progress, 0)
        XCTAssertEqual(upload?.progressView.isHidden, false)
        XCTAssertEqual(upload?.sizeLabel.text, "Uploading Zero KB of 1 KB")

        router.calls = []
        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.presented is BottomSheetPickerViewController)

        File.make(from: .make(id: "1", folder_id: "2"), batchID: controller.batchID, session: currentSession)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
    }

    func testDeleteFile() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()

        let indexPath = IndexPath(row: 1, section: 2)
        let swipes = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)?.actions
        XCTAssertEqual(swipes?.count, 1)
        swipes?.first?.handler(swipes!.first!, UIView()) { success in XCTAssertTrue(success) }

        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Are you sure you want to delete File?")
        api.mock(DeleteFileRequest(fileID: "1"), error: nil)
        (alert?.actions[1] as? AlertAction)?.handler?(AlertAction())
        XCTAssertEqual((router.presented as? UIAlertController)?.message, nil)

        api.mock(DeleteFileRequest(fileID: "1"), error: NSError.instructureError("Oops"))
        (alert?.actions[1] as? AlertAction)?.handler?(AlertAction())
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Oops")
    }

    func testDeleteFileFromSearch() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        api.mock(GetFilesRequest(context: .currentUser, searchTerm: "File"), value: [
            .make(),
        ])
        controller.searchTerm = "File"
        controller.search()
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 1)

        let indexPath = IndexPath(row: 0, section: 1)
        let swipes = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)?.actions
        XCTAssertEqual(swipes?.count, 1)
        swipes?.first?.handler(swipes!.first!, UIView()) { success in XCTAssertTrue(success) }

        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Are you sure you want to delete File?")
        api.mock(DeleteFileRequest(fileID: "1"), error: nil)
        (alert?.actions[1] as? AlertAction)?.handler?(AlertAction())
        XCTAssertEqual((router.presented as? UIAlertController)?.message, nil)
    }

    func testDeleteFolder() {
        api.mock(GetFoldersRequest(context: Context(.folder, id: "2")), value: [
            .make(full_name: "my files/Folder A/B", id: "3", name: "B", parent_folder_id: "2"),
            .make(files_count: 0, full_name: "my files/Folder A/EmptyFolder", id: "4", name: "EmptyFolder", parent_folder_id: "2"),
        ])
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        drainMainQueue()

        var indexPath = IndexPath(row: 0, section: 2)
        var swipes = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)?.actions
        XCTAssertNil(swipes)

        indexPath = IndexPath(row: 1, section: 2)
        swipes = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)?.actions
        XCTAssertEqual(swipes?.count, 1)

        swipes?.first?.handler(swipes!.first!, UIView()) { success in XCTAssertTrue(success) }
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Are you sure you want to delete EmptyFolder?")

        api.mock(DeleteFolderRequest(folderID: "4", force: true), error: NSError.instructureError("Oops"))
        (alert?.actions[1] as? AlertAction)?.handler?(AlertAction())
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Oops")
    }
}
