//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
import WebKit
import XCTest
import Combine

class CoreWebViewStudioFeaturesInteractorTests: CoreTestCase {

    private enum TestConstants {
        static let context = Context(.course, id: "32342")
        static let pageHTML = """
        <div>
            <p>
                <iframe
                    title="Video Title 11"
                    src="https://suhaibalabsi.instructure.com/media_attachments_iframe/613046"
                    data-media-id="usyier8y9328923"
                >
                </iframe>
            </p>
            <p>
                <iframe
                    title="Video Title 22"
                    src="https://suhaibalabsi.instructure.com/media_attachments_iframe/546734"
                    data-media-id="jshf893y92biuhiuire"
                >
                </iframe>
            </p>
        </div>
        """
    }

    private var webView: CoreWebView!

    override func setUp() {
        super.setUp()
        webView = CoreWebView()
    }

    override func tearDown() {
        webView = nil
        super.tearDown()
    }

    func testFeatureFlagOn() {
        // Given
        let context = TestConstants.context
        let interactor = webView.studioFeaturesInteractor
        let feature = FeatureFlagName.studioEmbedImprovements.rawValue
        let request = GetFeatureFlagStateRequest(featureName: .studioEmbedImprovements, context: context)

        api.mock(
            request,
            value: APIFeatureFlagState(
                feature: feature,
                state: .on,
                locked: false,
                context_id: context.id,
                context_type: context.contextType.rawValue
            )
        )

        // when
        interactor.resetFeatureFlagStore(context: context, env: environment)

        // Then
        XCTAssertTrue( webView.features.contains(where: { $0 is InsertStudioOpenInDetailButtons }) )
    }

    func testFeatureFlagOff() {
        // Given
        let context = TestConstants.context
        let interactor = webView.studioFeaturesInteractor
        let feature = FeatureFlagName.studioEmbedImprovements.rawValue
        let request = GetFeatureFlagStateRequest(featureName: .studioEmbedImprovements, context: context)

        api.mock(
            request,
            value: APIFeatureFlagState(
                feature: feature,
                state: .off,
                locked: false,
                context_id: context.id,
                context_type: context.contextType.rawValue
            )
        )

        // when
        interactor.resetFeatureFlagStore(context: context, env: environment)

        // Then
        XCTAssertFalse( webView.features.contains(where: { $0 is InsertStudioOpenInDetailButtons }) )
    }

    func testFeatureFlagAllowedOn() {
        // Given
        let context = TestConstants.context
        let interactor = webView.studioFeaturesInteractor
        let feature = FeatureFlagName.studioEmbedImprovements.rawValue
        let request = GetFeatureFlagStateRequest(featureName: .studioEmbedImprovements, context: context)

        api.mock(
            request,
            value: APIFeatureFlagState(
                feature: feature,
                state: .allowed_on,
                locked: false,
                context_id: "1234",
                context_type: ContextType.account.rawValue
            )
        )

        // when
        interactor.resetFeatureFlagStore(context: context, env: environment)

        // Then
        XCTAssertTrue( webView.features.contains(where: { $0 is InsertStudioOpenInDetailButtons }) )
    }

    func preloadPageContent() {
        let mockLinkDelegate = MockCoreWebViewLinkDelegate()
        webView.linkDelegate = mockLinkDelegate
        webView.loadHTMLString(TestConstants.pageHTML)

        wait(for: [mockLinkDelegate.navigationFinishedExpectation], timeout: 10)

        let exp = expectation(description: "frame-title map updated")
        webView.studioFeaturesInteractor.onScanFinished = {
            exp.fulfill()
        }

        wait(for: [exp])
    }

    func testFramesScanning() {
        // Given
        preloadPageContent()
        let interactor = webView.studioFeaturesInteractor

        // Then
        let titleMap = interactor.videoFramesTitleMap
        XCTAssertEqual(titleMap["https://suhaibalabsi.instructure.com/media_attachments/613046"], "Video Title 11")
        XCTAssertEqual(titleMap["https://suhaibalabsi.instructure.com/media_attachments/546734"], "Video Title 22")
    }

    func testImmersiveViewURL_ExpandButton() {
        // Given
        preloadPageContent()
        let interactor = webView.studioFeaturesInteractor

        // When
        let actionUrl = "https://suhaibalabsi.instructure.com/media_attachments/613046/immersive_view"
        let action = MockNavigationAction(url: actionUrl, type: .other, sourceFrame: MockFrameInfo(isMainFrame: false))
        let immersiveUrl = interactor.urlForStudioImmersiveView(of: action)

        // Then
        XCTAssertEqual(immersiveUrl?.absoluteString, "https://suhaibalabsi.instructure.com/media_attachments/613046/immersive_view?title=Video%20Title%2011&embedded=true")
    }

    func testImmersiveViewURL_DetailButton() {
        // Given
        preloadPageContent()
        let interactor = webView.studioFeaturesInteractor

        // When
        let actionUrl = "https://suhaibalabsi.instructure.com/media_attachments/546734/immersive_view?title=Hello%20World"
        let action = MockNavigationAction(url: actionUrl, type: .linkActivated, targetFrame: MockFrameInfo(isMainFrame: false))
        let immersiveUrl = interactor.urlForStudioImmersiveView(of: action)

        // Then
        XCTAssertEqual(immersiveUrl?.absoluteString, "https://suhaibalabsi.instructure.com/media_attachments/546734/immersive_view?title=Hello%20World&embedded=true")
    }
}
