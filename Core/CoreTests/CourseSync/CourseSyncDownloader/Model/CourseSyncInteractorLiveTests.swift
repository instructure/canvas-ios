//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import CombineSchedulers
@testable import Core
import Foundation
import TestsFoundation
import XCTest

class CourseSyncInteractorLiveTests: CoreTestCase {
    private var assignmentsInteractor: CourseSyncAssignmentsInteractorMock!
    private var pagesInteractor: CourseSyncPagesInteractorMock!
    private var discussionsInteractor: CourseSyncDiscussionsInteractorMock!
    private var filesInteractor: CourseSyncFilesInteractorMock!
    private var modulesInteractor: CourseSyncModulesInteractorMock!
    private var progressWriterInteractor: CourseSyncProgressWriterInteractor!
    private var progressObserverInteractor: CourseSyncProgressObserverInteractor!
    private var entries: [CourseSyncEntry]!
    private var testScheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        assignmentsInteractor = CourseSyncAssignmentsInteractorMock()
        pagesInteractor = CourseSyncPagesInteractorMock()
        filesInteractor = CourseSyncFilesInteractorMock()
        modulesInteractor = CourseSyncModulesInteractorMock()
        progressWriterInteractor = CourseSyncProgressWriterInteractorLive(container: database)
        progressObserverInteractor = CourseSyncProgressObserverInteractorLive(container: database)
        testScheduler = DispatchQueue.test

        entries = [
            CourseSyncEntry(
                name: "entry-1",
                id: "entry-1",
                hasFrontPage: false,
                tabs: [
                    .init(id: "tab-assignments", name: "Assignments", type: .assignments),
                    .init(id: "tab-pages", name: "Pages", type: .pages),
                    .init(id: "tab-files", name: "Files", type: .files),
                    .init(id: "tab-syllabus", name: "Syllabus", type: .syllabus),
                    .init(id: "tab-conferences", name: "Conferences", type: .conferences),
                    .init(id: "tab-quizzes", name: "Quizzes", type: .quizzes),
                    .init(id: "tab-discussions", name: "Discussions", type: .discussions),
                    .init(id: "tab-modules", name: "Modules", type: .modules),
                ],
                files: [
                    .make(id: "file-1", displayName: "1", url: URL(string: "1.jpg")!, bytesToDownload: 1000),
                    .make(id: "file-2", displayName: "2", url: URL(string: "2.jpg")!, bytesToDownload: 1000),
                ]
            ),
        ]
    }

    override func tearDown() {
        assignmentsInteractor = nil
        pagesInteractor = nil
        filesInteractor = nil
        progressWriterInteractor = nil
        progressObserverInteractor = nil
        entries = []
        testScheduler = nil
        super.tearDown()
    }

    func testDownloadState() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [pagesInteractor, assignmentsInteractor],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        assignmentsInteractor.publisher.send(())
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        pagesInteractor.publisher.send(())
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(1)
        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[1].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)

        subscription.cancel()
    }

    func testFilesLoadingState() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(0.1)
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[0].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[1].state, .loading(0.1))

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)
        XCTAssertEqual(entries[0].files[0].state, .downloaded)
        XCTAssertEqual(entries[0].files[1].state, .downloaded)

        subscription.cancel()
    }

    func testFilesDownloadedBytes() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].selectionState = .partiallySelected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries.totalSelectedSize, 2000)
        XCTAssertEqual(entries.totalDownloadedSize, 0)
        XCTAssertEqual(entries[0].files[0].bytesToDownload, 1000)
        XCTAssertEqual(entries[0].files[1].bytesToDownload, 1000)

        filesInteractor.publisher.send(0.1)
        XCTAssertEqual(entries[0].files[0].bytesDownloaded, 100)
        XCTAssertEqual(entries.totalDownloadedSize, 200)

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].files[0].bytesDownloaded, 1000)
        XCTAssertEqual(entries[0].files[1].bytesDownloaded, 1000)
        XCTAssertEqual(entries.totalDownloadedSize, 2000)

        subscription.cancel()
    }

    func testFilesPartialSelection() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[2].selectionState = .partiallySelected
        entries[0].files[0].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(0.1)
        testScheduler.run()
        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[0].state, .loading(0.1))
        XCTAssertEqual(entries[0].files[1].state, .loading(nil))

        filesInteractor.publisher.send(completion: .finished)
        XCTAssertEqual(entries[0].tabs[2].state, .downloaded)
        XCTAssertEqual(entries[0].files[0].state, .downloaded)
        XCTAssertEqual(entries[0].files[1].state, .loading(nil))

        subscription.cancel()
    }

    func testAssignmentErrorState() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [assignmentsInteractor],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,

            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[0].state, .loading(nil))

        assignmentsInteractor.publisher.send(completion: .failure(NSError.instructureError("Assignment error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[0].state, .error)

        subscription.cancel()
    }

    func testPagesErrorState() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [pagesInteractor],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,

            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[1].state, .loading(nil))

        pagesInteractor.publisher.send(completion: .failure(NSError.instructureError("Pages error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[1].state, .error)

        subscription.cancel()
    }

    func testFilesErrorState() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,

            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { val in
                    self.entries = val
                }
            )

        XCTAssertEqual(entries[0].state, .loading(nil))
        XCTAssertEqual(entries[0].tabs[2].state, .loading(nil))

        filesInteractor.publisher.send(completion: .failure(NSError.instructureError("Files error")))
        XCTAssertEqual(entries[0].state, .error)
        XCTAssertEqual(entries[0].tabs[2].state, .error)

        subscription.cancel()
    }

    func testStartsSyllabusDownload() {
        let syllbusDownloadStarted = expectation(description: "Syllabus download started")
        let mockSyllabusInteractor = CourseSyncSyllabusInteractorMock(expectation: syllbusDownloadStarted)
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [mockSyllabusInteractor],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,

            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[3].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [syllbusDownloadStarted], timeout: 1)
        subscription.cancel()
    }

    func testStartsConferencesDownload() {
        let conferencesDownloadStarted = expectation(description: "Conferences download started")
        let mockConferencesInteractor = CourseSyncConferencesInteractorMock(expectation: conferencesDownloadStarted)
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [mockConferencesInteractor],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[4].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [conferencesDownloadStarted], timeout: 1)
        subscription.cancel()
    }

    func testStartsQuizzesDownload() {
        let expectation = expectation(description: "Quizzes download started")
        let mockQuizzesInteractor = CourseSyncQuizzesInteractorMock(expectation: expectation)
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
                mockQuizzesInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[5].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    func testStartsDiscussionsDownload() {
        let expectation = expectation(description: "Discussions download started")
        let mockDiscussionsInteractor = CourseSyncDiscussionsInteractorMock(expectation: expectation)
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
                mockDiscussionsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[6].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    func testStartsModulesDownload() {
        let expectation = expectation(description: "Modules download started")
        let mockModulesInteractor = CourseSyncModulesInteractorMock(expectation: expectation)
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: mockModulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[7].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()
        wait(for: [expectation], timeout: 0.1)
        subscription.cancel()
    }

    func testStartsFrontPageDownload() {
        let expectation = expectation(description: "Front page download started")
        let mockPagesInteractor = CourseSyncPagesInteractorMock(expectation: expectation)
        entries = [
            CourseSyncEntry(
                name: "entry-1",
                id: "entry-1",
                hasFrontPage: true,
                tabs: [.init(id: "tab-assignments", name: "Assignments", type: .assignments)],
                files: []
            ),
        ]
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                mockPagesInteractor,
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()
        wait(for: [expectation], timeout: 0.1)
        subscription.cancel()
    }

    func testAdditionalContentDownloadWithDisabledTabs() {
        let assignmentsExpectation = expectation(description: "Assignments download started")
        let mockAssignmentsInteractor = CourseSyncAssignmentsInteractorMock(expectation: assignmentsExpectation)
        let discussionExpectation = expectation(description: "Discussions download started")
        let mockDiscussionsInteractor = CourseSyncDiscussionsInteractorMock(expectation: discussionExpectation)

        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                mockAssignmentsInteractor,
                pagesInteractor,
                mockDiscussionsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[6].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        wait(for: [assignmentsExpectation, discussionExpectation], timeout: 1)
        subscription.cancel()
    }

    func testAssociatedModuleItemsWithDisabledTabs() {
        let modulesInteractor = CourseSyncModulesInteractorMock2()
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
                CourseSyncDiscussionsInteractorPublisherMock(),
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(),
            notificationInteractor: CourseSyncNotificationInteractor(
                progressInteractor: CourseSyncProgressObserverInteractorMock()
            ),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )

        entries[0].tabs.removeAll()
        entries[0].files.removeAll()

        entries[0].tabs.append(.init(id: "tab-modules", name: "Modules", type: .modules))
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee.downloadContent(for: entries)
            .sink { entries in
                self.entries = entries
            }

        modulesInteractor.moduleItemsPublisher.send([
            .make(from: .make(id: "assignment-id", content: .assignment("assignment-id"))),
            .make(from: .make(id: "discussion-id", content: .discussion("discussion-id"))),
            .make(from: .make(id: "file-id", content: .file("file-id"))),
            .make(from: .make(id: "quiz-id", content: .discussion("quiz-id"))),
            .make(from: .make(id: "pages-id", content: .discussion("pages-id"))),

        ])

        modulesInteractor.associatedModuleItemsPublisher.send(())
        assignmentsInteractor.publisher.send(())

        XCTAssertEqual(entries[0].state, .downloaded)
        XCTAssertEqual(entries[0].tabs[0].state, .downloaded)

        subscription.cancel()
    }

    func testInitialLoadingState() {
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [pagesInteractor, assignmentsInteractor],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected
        entries[0].tabs[2].selectionState = .selected
        entries[0].files[0].selectionState = .selected
        entries[0].files[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()

        let courseProgress: CDCourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CDCourseSyncStateProgress.id), equals: "entry-1")
        ).first!
        XCTAssertEqual(courseProgress.state, .loading(nil))

        let assignmentsProgress: CDCourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CDCourseSyncStateProgress.id), equals: "tab-assignments")
        ).first!
        XCTAssertEqual(assignmentsProgress.state, .loading(nil))

        let pagesProgress: CDCourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CDCourseSyncStateProgress.id), equals: "tab-pages")
        ).first!
        XCTAssertEqual(pagesProgress.state, .loading(nil))

        let file1Progress: CDCourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CDCourseSyncStateProgress.id), equals: "file-1")
        ).first!
        XCTAssertEqual(file1Progress.state, .loading(nil))

        let file2Progress: CDCourseSyncStateProgress = databaseClient.fetch(
            scope: .where(#keyPath(CDCourseSyncStateProgress.id), equals: "file-1")
        ).first!
        XCTAssertEqual(file2Progress.state, .loading(nil))

        subscription.cancel()
    }

    func testCancellationViaNotification() {
        // GIVEN
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected

        let subscription = testee.downloadContent(for: entries).sink()
        assignmentsInteractor.publisher.send(())
        pagesInteractor.publisher.send(())

        // WHEN
        NotificationCenter.default.post(name: .OfflineSyncCancelled, object: nil)

        // THEN
        let fileProgressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch()
        let entryProgressList: [CDCourseSyncStateProgress] = databaseClient.fetch()
        XCTAssertEqual(fileProgressList.count, 0)
        XCTAssertEqual(entryProgressList.count, 0)
        XCTAssertEqual(testee.downloadSubscription, nil)
        subscription.cancel()
    }

    func testCancellation() {
        // GIVEN
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                pagesInteractor,
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationInteractor(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected
        entries[0].tabs[1].selectionState = .selected

        let subscription = testee
            .downloadContent(for: entries)
            .sink()
        assignmentsInteractor.publisher.send(())
        pagesInteractor.publisher.send(())

        // WHEN
        testee.cancel()

        // THEN
        let fileProgressList: [CDCourseSyncDownloadProgress] = databaseClient.fetch()
        let entryProgressList: [CDCourseSyncStateProgress] = databaseClient.fetch()
        XCTAssertEqual(fileProgressList.count, 0)
        XCTAssertEqual(entryProgressList.count, 0)
        XCTAssertEqual(testee.downloadSubscription, nil)
        subscription.cancel()
    }

    func testSendsSuccessNotificationOnFinish() {
        let courseSyncNotificationMock = CourseSyncNotificationMock(localNotifications: LocalNotificationsInteractor(notificationCenter: notificationCenter),
                                                                    progressInteractor: CourseSyncProgressObserverInteractorMock())
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: courseSyncNotificationMock,
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee
            .downloadContent(for: entries)
            .sink()

        // WHEN
        assignmentsInteractor.publisher.send(())

        // THEN
        XCTAssertTrue(courseSyncNotificationMock.sendCalled)
        subscription.cancel()
    }

    func testDownloadCourseListData() {
        let listInteractorMock = CourseListInteractorMock()
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationMock(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: listInteractorMock,
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )

        // WHEN
        let subscription = testee
            .downloadContent(for: entries)
            .sink()

        // THEN
        XCTAssertTrue(listInteractorMock.getCoursesCalled)
        subscription.cancel()
    }

    func testDownloadBrandTheme() {
        let brandThemeInteractorMock = BrandThemeDownloaderInteractorMock()
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: brandThemeInteractorMock,
            contentInteractors: [],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationMock(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: BackgroundActivityMock(),
            scheduler: .immediate,
            env: environment
        )

        // WHEN
        let subscription = testee
            .downloadContent(for: entries)
            .sink()

        // THEN
        XCTAssertTrue(brandThemeInteractorMock.getContentCalled)
        subscription.cancel()
    }

    func testHandlesBackgroundSyncInterruption() {
        let backgroundActivityMock = BackgroundActivityMock()
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: modulesInteractor,
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationMock(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: backgroundActivityMock,
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee
            .downloadContent(for: entries)
            .sink()

        // WHEN
        // assignmentsInteractor didn't complete sync
        backgroundActivityMock.abortHandler?()

        // THEN
        let downloadProgresses: [CDCourseSyncDownloadProgress] = databaseClient.fetch()
        XCTAssertEqual(downloadProgresses.count, 1)
        guard let downloadProgress = downloadProgresses.first else { return XCTFail() }
        XCTAssertTrue(downloadProgress.isFinished)
        XCTAssertEqual(downloadProgress.error, "Offline sync was interrupted by the operating system")
        subscription.cancel()
    }

    func testCancelsBackgroundActivityOnCancel() {
        let backgroundActivityMock = BackgroundActivityMock()
        let testee = CourseSyncInteractorLive(
            brandThemeInteractor: BrandThemeDownloaderInteractorMock(),
            contentInteractors: [
                assignmentsInteractor,
            ],
            filesInteractor: filesInteractor,
            modulesInteractor: CourseSyncModulesInteractorMock(),
            progressWriterInteractor: CourseSyncProgressWriterInteractorLive(container: database),
            notificationInteractor: CourseSyncNotificationMock(progressInteractor: CourseSyncProgressObserverInteractorMock()),
            courseListInteractor: CourseListInteractorMock(),
            studioMediaInteractor: CourseSyncStudioMediaInteractorMock(),
            backgroundActivity: backgroundActivityMock,
            scheduler: .immediate,
            env: environment
        )
        entries[0].tabs[0].selectionState = .selected

        let subscription = testee
            .downloadContent(for: entries)
            .sink()

        // WHEN
        // assignmentsInteractor didn't complete sync
        testee.cancel()

        // THEN
        XCTAssertTrue(backgroundActivityMock.stopInvoked)
        subscription.cancel()
    }
}

// MARK: - Mocks

private class CourseSyncProgressObserverInteractorMock: CourseSyncProgressObserverInteractor {
    func observeDownloadProgress() -> AnyPublisher<CourseSyncDownloadProgress, Never> {
        Just(CourseSyncDownloadProgress(bytesToDownload: 0, bytesDownloaded: 0, isFinished: false, error: nil, courseIds: [])).eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<[CourseSyncStateProgress], Never> {
        Just([]).eraseToAnyPublisher()
    }
}

private class CourseSyncNotificationMock: CourseSyncNotificationInteractor {
    private(set) var sendCalled = false

    override func send(window _: UIWindow? = AppEnvironment.shared.window) -> AnyPublisher<Void, Never> {
        sendCalled = true
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}

private class CourseSyncSyllabusInteractorMock: CourseSyncSyllabusInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncConferencesInteractorMock: CourseSyncConferencesInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncQuizzesInteractorMock: CourseSyncQuizzesInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncDiscussionsInteractorMock: CourseSyncDiscussionsInteractor {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation.fulfill()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncDiscussionsInteractorPublisherMock: CourseSyncDiscussionsInteractor {
    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncPagesInteractorMock: CourseSyncPagesInteractor {
    let publisher = PassthroughSubject<Void, Error>()
    let expectation: XCTestExpectation?

    init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation?.fulfill()
        return publisher.eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncAssignmentsInteractorMock: CourseSyncAssignmentsInteractor {
    let expectation: XCTestExpectation?
    let publisher = PassthroughSubject<Void, Error>()

    init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }

    func getContent(courseId _: String) -> AnyPublisher<Void, Error> {
        expectation?.fulfill()
        return publisher.eraseToAnyPublisher()
    }

    func cleanContent(courseId _: String) -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
}

private class CourseSyncFilesInteractorMock: CourseSyncFilesInteractor {
    let publisher = PassthroughSubject<Float, Error>()
    let filePublisher = PassthroughSubject<[Core.File], Error>()

    func downloadFile(courseId _: String, url _: URL, fileID _: String, fileName _: String, mimeClass _: String, updatedAt _: Date?) -> AnyPublisher<Float, Error> {
        publisher.eraseToAnyPublisher()
    }

    func getFiles(courseId _: String, useCache _: Bool) -> AnyPublisher<[Core.File], Error> {
        filePublisher.eraseToAnyPublisher()
    }

    func removeUnavailableFiles(courseId _: String, newFileIDs _: [String]) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private class CourseSyncModulesInteractorMock: CourseSyncModulesInteractor {
    let expectation: XCTestExpectation?

    init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }

    func getModuleItems(courseId _: String) -> AnyPublisher<[Core.ModuleItem], Error> {
        expectation?.fulfill()
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func getAssociatedModuleItems(courseId _: String, moduleItemTypes _: Set<Core.TabName>, moduleItems _: [Core.ModuleItem]) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private class CourseSyncModulesInteractorMock2: CourseSyncModulesInteractor {
    let moduleItemsPublisher = PassthroughSubject<[ModuleItem], Error>()
    let associatedModuleItemsPublisher = PassthroughSubject<Void, Error>()

    func getModuleItems(courseId _: String) -> AnyPublisher<[Core.ModuleItem], Error> {
        moduleItemsPublisher.eraseToAnyPublisher()
    }

    func getAssociatedModuleItems(courseId _: String, moduleItemTypes _: Set<Core.TabName>, moduleItems _: [Core.ModuleItem]) -> AnyPublisher<Void, Error> {
        associatedModuleItemsPublisher.eraseToAnyPublisher()
    }
}

private class BrandThemeDownloaderInteractorMock: BrandThemeDownloaderInteractor {
    public var getContentCalled = false

    override func getContent() -> AnyPublisher<Void, Never> {
        getContentCalled = true
        return Just(()).eraseToAnyPublisher()
    }
}

private class CourseSyncStudioMediaInteractorMock: CourseSyncStudioMediaInteractor {
    public var getContentCalled = false

    func getContent(courseIDs: [String]) -> AnyPublisher<Void, Never> {
        getContentCalled = true
        return Just(()).eraseToAnyPublisher()
    }
}
