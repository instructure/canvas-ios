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

public class DashboardContainerViewModel: ObservableObject {
    // MARK: - Inputs

    public let settingsButtonTapped = PassthroughSubject<Void, Never>()

    // MARK: - Outputs

    public let showSettings = PassthroughSubject<(view: UIViewController, viewSize: CGSize), Never>()

    // MARK: - Private Variables

    private var subscriptions = Set<AnyCancellable>()

    public init(
        environment: AppEnvironment,
        courseSyncInteractor: CourseSyncInteractor = CourseSyncDownloaderAssembly.makeInteractor()
    ) {
        settingsButtonTapped
            .map {
                let interactor = DashboardSettingsInteractorLive(environment: environment, defaults: environment.userDefaults)
                let viewModel = DashboardSettingsViewModel(interactor: interactor)
                let dashboard = CoreHostingController(DashboardSettingsView(viewModel: viewModel))
                dashboard.addDoneButton(side: .left)
                return (HelmNavigationController(rootViewController: dashboard), viewModel.popoverSize)
            }
            .subscribe(showSettings)
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: .OfflineSyncTriggered)
            .compactMap { $0.object as? [CourseSyncEntry] }
            .flatMap { courseSyncInteractor.downloadContent(for: $0 )}
            .sink()
            .store(in: &subscriptions)
    }
}
