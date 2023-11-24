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

import Foundation

public enum CourseSyncSelectorAssembly {

    public static func makeViewController(env: AppEnvironment, courseID: String? = nil) -> UIViewController {
        let selectorInteractor = CourseSyncSelectorInteractorLive(courseID: courseID,
                                                                  sessionDefaults: env.userDefaults ?? .fallback)
        let syncInteractor = CourseSyncDownloaderAssembly.makeInteractor()
        let diskSpaceInteractor = DiskSpaceInteractorLive()
        let viewModel = CourseSyncSelectorViewModel(
            selectorInteractor: selectorInteractor,
            syncInteractor: syncInteractor,
            router: env.router
        )
        let diskSpaceViewModel = CourseSyncDiskSpaceInfoViewModel(interactor: diskSpaceInteractor, app: env.app ?? .student)
        let offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())
        let view = CourseSyncSelectorView(viewModel: viewModel,
                                          diskSpaceViewModel: diskSpaceViewModel,
                                          offlineModeViewModel: offlineModeViewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    static func makePreview(env: AppEnvironment, isEmpty: Bool, isLoading: Bool) -> CourseSyncSelectorView {
        let selectorInteractor = CourseSyncSelectorInteractorPreview(sessionDefaults: .fallback)

        if isEmpty {
            selectorInteractor.mockEmptyState()
        }

        if isLoading {
            selectorInteractor.mockLoadingState()
        }

        let syncInteractor = CourseSyncInteractorPreview()
        let diskSpaceInteractor = DiskSpaceInteractorPreview()
        let viewModel = CourseSyncSelectorViewModel(
            selectorInteractor: selectorInteractor,
            syncInteractor: syncInteractor,
            router: env.router
        )
        let diskSpaceViewModel = CourseSyncDiskSpaceInfoViewModel(interactor: diskSpaceInteractor, app: env.app ?? .student)
        let offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeInteractorMock())

        return CourseSyncSelectorView(viewModel: viewModel,
                                      diskSpaceViewModel: diskSpaceViewModel,
                                      offlineModeViewModel: offlineModeViewModel)
    }

#endif

}
