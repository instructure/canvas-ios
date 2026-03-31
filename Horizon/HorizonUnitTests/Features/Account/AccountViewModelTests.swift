//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import XCTest
import Combine
import CombineSchedulers

final class AccountViewModelTests: HorizonTestCase {

    private var testee: AccountViewModel!
    private var getUserInteractor: GetUserInteractorMock!
    private var experienceInteractor: ExperienceSummaryInteractorMock!
    private var careerHelpInteractor: CareerHelpInteractorMock!

    override func setUp() {
        super.setUp()

        let user: UserProfile = databaseClient.insert()
        user.name = "Test User"
        user.email = "test@example.com"
        getUserInteractor = GetUserInteractorMock(user: user)
        experienceInteractor = ExperienceSummaryInteractorMock()
        careerHelpInteractor = CareerHelpInteractorMock()
    }

    override func tearDown() {
        testee = nil
        getUserInteractor = nil
        experienceInteractor = nil
        careerHelpInteractor = nil
        super.tearDown()
    }

    // MARK: - getAccountHelpLinks

    func test_getAccountHelpLinks_givenViewModelInitialized_thenHelpItemsStartsEmpty() {
        // When
        testee = makeViewModel()

        // Then
        XCTAssertEqual(testee.helpItems.count, 0)
    }

    // MARK: - giveFeedbackDidTap

    func test_giveFeedbackDidTap_givenBugReport_thenModalIsShown() {
        // Given
        testee = makeViewModel()
        let helpItem = HelpModel(
            id: "report_a_problem",
            title: "Report a Problem",
            url: nil,
            isBugReport: true
        )
        let viewController = WeakViewController(UIViewController())

        // When
        testee.giveFeedbackDidTap(viewController: viewController, help: helpItem)

        // Then
        XCTAssertNotNil(router.presented)
    }

    func test_giveFeedbackDidTap_givenExternalLink_thenURLIsOpened() {
        // Given
        testee = makeViewModel()
        let url = URL(string: "https://example.com/help")!
        let helpItem = HelpModel(
            id: "training_services_portal",
            title: "Training Services",
            url: url,
            isBugReport: false
        )
        let viewController = WeakViewController(UIViewController())

        // When
        testee.giveFeedbackDidTap(viewController: viewController, help: helpItem)

        // Then
        XCTAssertTrue(router.lastRoutedTo(url))
    }

    func test_giveFeedbackDidTap_givenExternalLinkWithNoURL_thenNothingHappens() {
        // Given
        testee = makeViewModel()
        let helpItem = HelpModel(
            id: "some_id",
            title: "Some Help",
            url: nil,
            isBugReport: false
        )
        let viewController = WeakViewController(UIViewController())

        // When
        testee.giveFeedbackDidTap(viewController: viewController, help: helpItem)

        // Then
        XCTAssertNil(router.presented)
        XCTAssertTrue(router.calls.isEmpty)
    }

    func test_giveFeedbackDidTap_givenBugReportSubmitted_thenOnReportBugDismissedIsTrue() {
        // Given
        testee = makeViewModel()
        let helpItem = HelpModel(
            id: "report_a_problem",
            title: "Report a Problem",
            url: nil,
            isBugReport: true
        )
        let viewController = WeakViewController(UIViewController())

        // When
        testee.giveFeedbackDidTap(viewController: viewController, help: helpItem)

        // Then
        XCTAssertNotNil(router.presented)
        XCTAssertFalse(testee.onReportBugDismissed)
    }

    func test_getAccountHelpLinks_givenHelpItemsLoaded_thenHelpItemsArePopulated() {
        // Given
        let mockHelpItems = [
            HelpModel(
                id: "report_a_problem",
                title: "Report a Problem",
                url: nil,
                isBugReport: true
            ),
            HelpModel(
                id: "training_services_portal",
                title: "Training Services",
                url: URL(string: "https://example.com/training"),
                isBugReport: false
            )
        ]
        careerHelpInteractor.helpModels = mockHelpItems

        // When
        testee = makeViewModel()

        // Then
        XCTAssertEqual(testee.helpItems.count, 2)
        XCTAssertEqual(testee.helpItems.first?.id, "report_a_problem")
        XCTAssertEqual(testee.helpItems.last?.id, "training_services_portal")
    }

    func test_getAccountHelpLinks_givenEmptyResponse_thenHelpItemsRemainsEmpty() {
        // Given
        careerHelpInteractor.helpModels = []

        // When
        testee = makeViewModel()

        // Then
        XCTAssertEqual(testee.helpItems.count, 0)
    }

    func test_refresh_givenCalled_thenHelpItemsAreReloaded() async {
        // Given
        careerHelpInteractor.helpModels = []
        testee = makeViewModel()
        XCTAssertEqual(testee.helpItems.count, 0)

        let updatedHelpItems = [
            HelpModel(
                id: "report_a_problem",
                title: "Report a Problem",
                url: nil,
                isBugReport: true
            )
        ]
        careerHelpInteractor.helpModels = updatedHelpItems

        // When
        await testee.refresh()

        // Then
        XCTAssertEqual(careerHelpInteractor.getAccountHelpLinksCallCount, 2)
        XCTAssertEqual(careerHelpInteractor.lastIgnoreCache, true)
        XCTAssertEqual(testee.helpItems.count, 1)
    }

    // MARK: - Private helpers

    private func makeViewModel() -> AccountViewModel {
        AccountViewModel(
            router: router,
            getUserInteractor: getUserInteractor,
            appExperienceInteractor: experienceInteractor,
            careerHelpInteractor: careerHelpInteractor,
            scheduler: .immediate
        )
    }
}

// MARK: - Helpers

extension GetCareerHelpResponse {
    static func make(
        id: String = "test_id",
        text: String = "Test Help",
        type: String = "custom",
        url: URL? = nil
    ) -> GetCareerHelpResponse {
        GetCareerHelpResponse(
            id: id,
            type: type,
            availableTo: nil,
            text: text,
            subtext: nil,
            url: url,
            isFeatured: nil,
            isNew: nil,
            featureHeadline: nil
        )
    }
}
