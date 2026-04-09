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

// TODO: Make it #if DEBUG later
public struct Storybook: View {
    public init() {}

    public var body: some View {
        List {
            Section(header: Text("Foundations: Atoms")) {
                NavigationLink {
                    HorizonUI.Colors.Storybook()
                } label: {
                    Text("Colors")
                }
                NavigationLink {
                    HorizonUI.Typography.Storybook()
                } label: {
                    Text("Typography")
                }
                NavigationLink {
                    HorizonUI.CornerRadius.Storybook()
                } label: {
                    Text("Corner Radius")
                }
                NavigationLink {
                    HorizonUI.Borders.Storybook()
                } label: {
                    Text("Border")
                }
                NavigationLink {
                    HorizonUI.Elevations.Storybook()
                } label: {
                    Text("Elevation / Shadows")
                }
                NavigationLink {
                    HorizonUI.Icons.Storybook()
                } label: {
                    Text("Iconography")
                }
            }
            Section(header: Text("Components: Molecules")) {
                NavigationLink {
                    HorizonUI.Badge.Storybook()
                } label: {
                    Text("Badge")
                }
                NavigationLink {
                    HorizonUI.ButtonStyles.Storybook()
                } label: {
                    Text("Buttons and Links")
                }
                NavigationLink {
                    HorizonUI.ProgressBar.Storybook()
                } label: {
                    Text("Progress Bar")
                }
                NavigationLink {
                    HorizonUI.Spinner.Storybook()
                } label: {
                    Text("Spinner")
                }
                NavigationLink {
                    HorizonUI.Tooltip.Storybook()
                } label: {
                    Text("Tooltip")
                }
                NavigationLink {
                    HorizonUI.Tabs.Storybook()
                } label: {
                    Text("Tabs")
                }
                NavigationLink {
                    HorizonUI.MenuActionsTextView.Storybook()
                } label: {
                    Text("Custom Menu Actions")
                }
                NavigationLink {
                    HorizonUI.SegmentedControl.Storybook()
                } label: {
                    Text("Segmented Control")
                }
            }
            Section(header: Text("Components: Organisms")) {
                NavigationLink {
                    HorizonUI.Controls.Storybook()
                } label: {
                    Text("Controls")
                }
                NavigationLink {
                    HorizonUI.Inputs.Storybook()
                } label: {
                    Text("Inputs and Interactive Fields")
                }
                NavigationLink {
                    HorizonUI.Cards.Storybook()
                } label: {
                    Text("Cards")
                }
                NavigationLink {
                    HorizonUI.NavigationBar.Storybook()
                } label: {
                    Text("Navigation")
                }
                NavigationLink {
                    HorizonUI.Overlay.Storybook()
                } label: {
                    Text("Navigation Overlay")
                }
                NavigationLink {
                    HorizonUI.Toast.Storybook()
                } label: {
                    Text("Alert Toast")
                }

                NavigationLink {
                    HorizonUI.FileDrop.Storybook()
                } label: {
                    Text("File Drop")
                }

                NavigationLink {
                    HorizonUI.UploadedFile.Storybook()
                } label: {
                    Text("Uploaded File")
                }
                NavigationLink {
                    HorizonUI.Modal<EmptyView>.Storybook()
                } label: {
                    Text("Modal")
                }
            }
        }
        .listStyle(.sidebar)
        .navigationBarHidden(false)
        .navigationTitle("Design System")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        Storybook()
    }
}
