//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import CoreData
import SwiftUI

final class FileUploadNotificationCardListViewModel: ObservableObject {
    // MARK: - Dependencies

    private let environment: AppEnvironment

    // MARK: - Inputs

    public private(set) var sceneDidBecomeActive = PassthroughSubject<Void, Never>()

    // MARK: - Outputs

    @Published public private(set) var items: [FileUploadNotificationCardItemViewModel] = []

    // MARK: - Private properties

    private lazy var fileSubmissions: Store<LocalUseCase<FileSubmission>> = {
        let scope = Scope(
            predicate: NSPredicate(format: "%K == false", #keyPath(FileSubmission.isHiddenOnDashboard)),
            order: []
        )
        let useCase = LocalUseCase<FileSubmission>(scope: scope)
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    private lazy var fileUploadItems: Store<LocalUseCase<FileUploadItem>> = {
        let scope = Scope(predicate: .all, order: [])
        let useCase = LocalUseCase<FileUploadItem>(scope: scope)
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(environment: AppEnvironment = .shared) {
        self.environment = environment
        getSubmissions()

        sceneDidBecomeActive
            .sink { [self] in
                getSubmissions()
            }
            .store(in: &subscriptions)
    }

    private func getSubmissions() {
        fileSubmissions.refresh()
        fileUploadItems.refresh()
    }

    private func update() {
        items = fileSubmissions.map { submission in
            createFileUploadNotificationCardItemViewModel(for: submission)
        }
    }

    private func getNotificationCardItemState(
        from state: FileSubmission.State
    ) -> FileUploadNotificationCardItemViewModel.State {
        switch state {
        case .waiting, .uploading: return .uploading
        case .failedUpload, .failedSubmission: return .failure
        case .submitted: return .success
        }
    }

    private func createFileUploadNotificationCardItemViewModel(
        for submission: FileSubmission
    ) -> FileUploadNotificationCardItemViewModel {
        return FileUploadNotificationCardItemViewModel(
            id: submission.objectID,
            assignmentName: submission.assignmentName,
            state: getNotificationCardItemState(from: submission.state),
            isHiddenByUser: submission.isHiddenOnDashboard,
            cardDidTap: { [weak self] submissionID, viewController in
                self?.cardDidTap(
                    submissionID: submissionID,
                    viewController: viewController
                )
            },
            dismissDidTap: { [weak environment] in
                environment?.database.viewContext.perform {
                    submission.isHiddenOnDashboard = true
                    try? environment?.database.viewContext.save()
                }
            }
        )
    }

    private func cardDidTap(
        submissionID _: NSManagedObjectID,
        viewController _: WeakViewController
    ) {
        // TODO: Routing to a fully functional `FileProgressListView` will be possible once the new File Upload logic is used everywhere in the app.
        /*
         var listViewController: CoreHostingController<FileProgressListView<FileProgressListViewModel>>!
         let viewModel = FileProgressListViewModel(
             submissionID: submissionID,
             dismiss: { [weak self] in
                 self?.environment.router.dismiss(listViewController)
             }
         )

         let listView = FileProgressListView(viewModel: viewModel)
         listViewController = CoreHostingController(listView)

         environment.router.show(
             listViewController,
             from: viewController,
             options: .modal(isDismissable: false, embedInNav: true, addDoneButton: false),
             analyticsRoute: "/file_progress"
         )
          */
    }
}
