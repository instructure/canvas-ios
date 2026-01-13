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

import SwiftUI

enum LearnerDashboardWidgetAssembly {

    static func makeDefaultWidgetConfigs() -> [WidgetConfig] {
        [
            WidgetConfig(id: .fullWidthWidget, order: 0, isVisible: true, settings: nil),
            WidgetConfig(id: .widget1, order: 1, isVisible: true, settings: nil),
            WidgetConfig(id: .widget2, order: 2, isVisible: true, settings: nil),
            WidgetConfig(id: .widget3, order: 3, isVisible: true, settings: nil)
        ]
    }

    static func makeWidgetViewModel(config: WidgetConfig) -> any LearnerWidgetViewModel {
        switch config.id {
        case .fullWidthWidget: FullWidthWidgetViewModel(config: config)
        case .widget1: Widget1ViewModel(config: config)
        case .widget2: Widget2ViewModel(config: config)
        case .widget3: Widget3ViewModel(config: config)
        }
    }

    @ViewBuilder
    static func makeView(for viewModel: any LearnerWidgetViewModel) -> some View {
        switch viewModel {
        case let vm as FullWidthWidgetViewModel:
            vm.makeView()
        case let vm as Widget1ViewModel:
            vm.makeView()
        case let vm as Widget2ViewModel:
            vm.makeView()
        case let vm as Widget3ViewModel:
            vm.makeView()
        default:
            SwiftUI.EmptyView()
                .onAppear {
                    assertionFailure("Unknown widget view model type")
                }
        }
    }
}
