//
//  DocumentMenuViewModelTests.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/25/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Nimble
import SoAutomated
import XCTest
@testable import FileKit
import ReactiveSwift
import Result
import TooLegit
import SoPersistent
import CoreData
import MobileCoreServices

let allTypes = [kUTTypeItem as String]
let photoTypes = ["public.jpeg", "public.png"]
let videoTypes = ["public.movie", "public.mpeg-4"]
let audioTypes = ["public.mp3"]

class DocumentMenuViewModelTests: XCTestCase {
    let session = Session.user1
    let vm: DocumentMenuViewModelType = DocumentMenuViewModel()

    let showDocumentMenu = TestObserver<([DocumentOption], [String]), NoError>()
    let showImagePicker = TestObserver<(UIImagePickerControllerSourceType, [String]), NoError>()
    let showAudioRecorder = TestObserver<String, NoError>()
    let showDocumentPicker = TestObserver<UIDocumentPickerViewController, NoError>()
    let uploadable = TestObserver<Uploadable, NoError>()
    let errors = TestObserver<NSError, NoError>()

    override func setUp() {
        super.setUp()

        self.vm.outputs.showDocumentMenu.observe(self.showDocumentMenu.observer)
        self.vm.outputs.showImagePicker.observe(self.showImagePicker.observer)
        self.vm.outputs.showAudioRecorder.observe(self.showAudioRecorder.observer)
        self.vm.outputs.showDocumentPicker.observe(self.showDocumentPicker.observer)
        self.vm.outputs.uploadable.observe(self.uploadable.observer)
        self.vm.outputs.errors.observe(self.errors.observer)
    }

    func testDocumentOptions_FileTypesAre_Any() {
        self.vm.inputs.configureWith(fileTypes: allTypes)
        self.vm.inputs.showDocumentMenuButtonTapped()
        expect(self.showDocumentMenu.lastValue?.0) == [.camera(allowsPhotos: true, allowsVideos: true), .photoLibrary(allowsPhotos: true, allowsVideos: true), .recordAudio]
    }

    func testDocumentOptions_FileTypes_AllowPhotos() {
        self.vm.inputs.configureWith(fileTypes: photoTypes)
        self.vm.inputs.showDocumentMenuButtonTapped()
        expect(self.showDocumentMenu.lastValue?.0) == [.camera(allowsPhotos: true, allowsVideos: false), .photoLibrary(allowsPhotos: true, allowsVideos: false)]
    }

    func testDocumentOptions_FileTypes_AllowVideos() {
        self.vm.inputs.configureWith(fileTypes: videoTypes)
        self.vm.inputs.showDocumentMenuButtonTapped()
        expect(self.showDocumentMenu.lastValue?.0) == [.camera(allowsPhotos: false, allowsVideos: true), .photoLibrary(allowsPhotos: false, allowsVideos: true)]
    }

    func testDocumentOptions_FileTypes_AllowAudio() {
        self.vm.inputs.configureWith(fileTypes: audioTypes)
        self.vm.inputs.showDocumentMenuButtonTapped()
        expect(self.showDocumentMenu.lastValue?.0) == [.recordAudio]
    }

    func testShowImagePicker_CameraAllowsPhotosAndVideos() {
        self.vm.inputs.tappedDocumentOption(.camera(allowsPhotos: true, allowsVideos: true))
        let sourceType = self.showImagePicker.lastValue?.0
        let mediaTypes = self.showImagePicker.lastValue?.1
        expect(sourceType) == .camera
        expect(mediaTypes) == [kUTTypeImage as String, kUTTypeMovie as String]
    }

    func testShowImagePicker_CameraAllowsPhotos() {
        self.vm.inputs.tappedDocumentOption(.camera(allowsPhotos: true, allowsVideos: false))
        let sourceType = self.showImagePicker.lastValue?.0
        let mediaTypes = self.showImagePicker.lastValue?.1
        expect(sourceType) == .camera
        expect(mediaTypes) == [kUTTypeImage as String]
    }

    func testShowImagePicker_CameraAllowsVideos() {
        self.vm.inputs.tappedDocumentOption(.camera(allowsPhotos: false, allowsVideos: true))
        let sourceType = self.showImagePicker.lastValue?.0
        let mediaTypes = self.showImagePicker.lastValue?.1
        expect(sourceType) == .camera
        expect(mediaTypes) == [kUTTypeMovie as String]
    }

    func testShowImagePicker_PhotoLibraryAllowsPhotosAndVideos() {
        self.vm.inputs.tappedDocumentOption(.photoLibrary(allowsPhotos: true, allowsVideos: true))
        let sourceType = self.showImagePicker.lastValue?.0
        let mediaTypes = self.showImagePicker.lastValue?.1
        expect(sourceType) == .photoLibrary
        expect(mediaTypes) == [kUTTypeImage as String, kUTTypeMovie as String]
    }

    func testShowImagePicker_PhotoLibraryAllowsPhotos() {
        self.vm.inputs.tappedDocumentOption(.photoLibrary(allowsPhotos: true, allowsVideos: false))
        let sourceType = self.showImagePicker.lastValue?.0
        let mediaTypes = self.showImagePicker.lastValue?.1
        expect(sourceType) == .photoLibrary
        expect(mediaTypes) == [kUTTypeImage as String]
    }

    func testShowImagePicker_PhotoLibraryAllowsVideos() {
        self.vm.inputs.tappedDocumentOption(.photoLibrary(allowsPhotos: false, allowsVideos: true))
        let sourceType = self.showImagePicker.lastValue?.0
        let mediaTypes = self.showImagePicker.lastValue?.1
        expect(sourceType) == .photoLibrary
        expect(mediaTypes) == [kUTTypeMovie as String]
    }

    func testShowAudioRecorder() {
        self.vm.inputs.tappedDocumentOption(.recordAudio)
        self.showAudioRecorder.assertValues(["Done"])
    }

    func testShowDocumentPicker() {
        let picker = UIDocumentPickerViewController(documentTypes: allTypes, in: .import)
        self.vm.inputs.tappedDocumentPicker(picker)
        self.showDocumentPicker.assertValueCount(1)
    }
}

extension DocumentOption: Equatable {}
public func ==(lhs: DocumentOption, rhs: DocumentOption) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
}
