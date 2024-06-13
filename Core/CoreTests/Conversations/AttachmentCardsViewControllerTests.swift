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

import AVKit
import XCTest
@testable import Core
import TestsFoundation

class AttachmentCardsViewControllerTests: CoreTestCase {
    lazy var controller = AttachmentCardsViewController.create()

    lazy var audioComment = MediaComment.make(from: .make(
        content_type: "audio/x-m4a",
        display_name: "Audio Comment",
        media_id: "a-1234",
        media_type: .audio,
        url: URL(string: "data:audio/x-m4a,")!
    ))
    lazy var videoComment = MediaComment.make(from: .make(
        display_name: "Video Comment",
        url: URL(string: "data:video/mp4,comment")!
    ))

    lazy var audioFile = File.make(from: .make(
        id: "a",
        display_name: "Audio File",
        contentType: "audio/x-m4a",
        url: URL(string: "data:audio/x-m4a,")!,
        mime_class: "file" // sadly seen in the wild
    ))
    lazy var errorFile = File.make(from: .make(
        id: "e",
        display_name: "Broken File"
    ), uploadError: "It didn't work")
    lazy var uploadFile = File.make(from: .make(
        id: "u",
        display_name: "Upload File",
        size: 100
    ), bytesSent: 25, taskID: "2")
    lazy var thumbFile = File.make(from: .make(
        id: "t",
        display_name: "Thumbnail File",
        created_at: Clock.now.addDays(-1),
        thumbnail_url: URL(string: "data:image/jpeg,")!
    ))
    lazy var newImageFile = File.make(from: .make(
        id: "i",
        display_name: "Image File",
        url: URL(string: "data:image/jpeg,")!,
        created_at: Clock.now
    ))
    lazy var videoFile = File.make(from: .make(
        id: "v",
        display_name: "Video File",
        contentType: "video/mp4",
        url: URL(string: "data:video/mp4,file")!,
        mime_class: "video"
    ))
    lazy var pdfFile = File.make(from: .make(
        id: "p",
        display_name: "PDF File",
        contentType: "application/pdf",
        url: URL(string: "/files/d?download=1")!,
        mime_class: "pdf"
    ))

    var shownOptions: File?

    func testLayout() {
        controller.showOptions = { self.shownOptions = $0 }
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.stackView.spacing, 12)
        XCTAssertEqual(controller.stackView.leadingPadding.constant, 16)
        XCTAssertEqual(controller.stackView.trailingPadding.constant, 16)

        Clock.mockNow(Date())
        controller.updateAttachments([ pdfFile, errorFile, uploadFile ])
        XCTAssertEqual(controller.stackView.arrangedSubviews.count, 3)

        XCTAssertEqual(controller.getCard(0).fileStackView?.isHidden, false)
        XCTAssertEqual(controller.getCard(0).button?.accessibilityLabel, "PDF File")
        XCTAssertEqual(controller.getCard(0).iconView?.image, UIImage.pdfLine)
        XCTAssertEqual(controller.getCard(0).nameLabel?.text, "PDF File")
        controller.getCard(0).button?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(router.lastRoutedTo(.parse("/files/d?download=1")))
        XCTAssertEqual(controller.getCard(0).gestureRecognizers?.count, 1)
        controller.longPressAttachment(sender: controller.getCard(0).gestureRecognizers!.first! as! UILongPressGestureRecognizer)
        XCTAssertEqual(shownOptions, pdfFile)

        XCTAssertEqual(controller.getCard(1).fileStackView?.isHidden, false)
        XCTAssertEqual(controller.getCard(1).button?.accessibilityLabel, "Failed. Tap for options")
        XCTAssertEqual(controller.getCard(1).iconView?.image, UIImage.warningLine)
        XCTAssertEqual(controller.getCard(1).iconView?.tintColor, .textDanger)
        XCTAssertEqual(controller.getCard(1).nameLabel?.text, "Failed. Tap for options")
        controller.getCard(1).button?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(shownOptions, errorFile)

        XCTAssertEqual(controller.getCard(2).progressView?.isHidden, false)
        XCTAssertEqual(controller.getCard(2).button?.accessibilityLabel, "Uploading Upload File is at 25%")
        XCTAssertNotNil(controller.getCard(2).progressTimer)
        Clock.mockNow(Date().add(.second, number: 2))
        controller.getCard(2).stepProgress() // FIXME: trigger timer's target
        XCTAssertNil(controller.getCard(2).progressTimer)
        XCTAssertEqual(controller.getCard(2).progressView?.progress, 0.25)
        XCTAssertEqual(controller.getCard(2).progressLabel?.text, "25%")

        Clock.reset()
    }

    func testAudio() {
        controller.view.layoutIfNeeded()
        controller.updateAttachments([ audioFile ], mediaComment: audioComment)
        XCTAssertEqual(controller.stackView.arrangedSubviews.count, 2)

        XCTAssertEqual(controller.getCard(0).fileStackView?.isHidden, false)
        XCTAssertEqual(controller.getCard(0).button?.accessibilityLabel, "Audio Comment")
        XCTAssertEqual(controller.getCard(0).iconView?.image, UIImage.audioLine)
        XCTAssertEqual(controller.getCard(0).nameLabel?.text, "Audio Comment")
        controller.getCard(0).button?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(router.presented is AVPlayerViewController)

        XCTAssertEqual(controller.getCard(1).fileStackView?.isHidden, false)
        XCTAssertEqual(controller.getCard(1).button?.accessibilityLabel, "Audio File")
        XCTAssertEqual(controller.getCard(1).iconView?.image, UIImage.audioLine)
        XCTAssertEqual(controller.getCard(1).nameLabel?.text, "Audio File")
        controller.getCard(1).button?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(router.presented is AVPlayerViewController)
    }

    func testVideo() {
        controller.view.layoutIfNeeded()
        controller.updateAttachments([ videoFile ], mediaComment: videoComment)
        XCTAssertEqual(controller.stackView.arrangedSubviews.count, 2)

        XCTAssertEqual((controller.getCard(0).playerController?.player?.currentItem?.asset as? AVURLAsset)?.url, videoComment.url)
        XCTAssertEqual((controller.getCard(1).playerController?.player?.currentItem?.asset as? AVURLAsset)?.url, videoFile.url)
    }

    func testImage() {
        controller.view.layoutIfNeeded()
        controller.updateAttachments([ thumbFile, newImageFile ])

        XCTAssertEqual(controller.getCard(0).button?.accessibilityLabel, "Thumbnail File")
        XCTAssertEqual(controller.getCard(0).imageView?.url, thumbFile.thumbnailURL)
        controller.getCard(0).button?.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(router.lastRoutedTo(.parse(thumbFile.url!)))

        XCTAssertEqual(controller.getCard(1).button?.accessibilityLabel, "Image File")
        XCTAssertEqual(controller.getCard(1).imageView?.url, newImageFile.url)
    }
}
