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
        VStack {
            List {
                Section(header: Text("Foundations: Atoms")) {
                    NavigationLink {
                        HorizonUI.Colors.Storybook()
                    } label: {
                        Text("Colors").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Typography.Storybook()
                    } label: {
                        Text("Typography").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.CornerRadius.Storybook()
                    } label: {
                        Text("Corner Radius").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Borders.Storybook()
                    } label: {
                        Text("Border").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Elevations.Storybook()
                    } label: {
                        Text("Elevation / Shadows").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Icons.Storybook()
                    } label: {
                        Text("Iconography").tint(Color.black)
                    }
                }
                Section(header: Text("Components: Molecules")) {
                    NavigationLink {
                        HorizonUI.Badge.Storybook()
                    } label: {
                        Text("Badge").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Pill.Storybook()
                    } label: {
                        Text("Pill").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Tag.Storybook()
                    } label: {
                        Text("Tag").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.ButtonStyles.Storybook()
                    } label: {
                        Text("Buttons and Links").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.ProgressBar.Storybook()
                    } label: {
                        Text("Progress Bar").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Spinner.Storybook()
                    } label: {
                        Text("Spinner").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Tooltip.Storybook()
                    } label: {
                        Text("Tooltip").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Tabs.Storybook()
                    } label: {
                        Text("Tabs").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.MenuActionsTextView.Storybook()
                    } label: {
                        Text("Custom Menu Actions").tint(Color.black)
                    }
                }
                Section(header: Text("Components: Organisms")) {
                    NavigationLink {
                        HorizonUI.Controls.Storybook()
                    } label: {
                        Text("Controls").tint(Color.black)
                    }
                    NavigationLink {} label: {
                        Text("Inputs and Interactive Fields").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Cards.Storybook()
                    } label: {
                        Text("Cards").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.NavigationBar.Storybook()
                    } label: {
                        Text("Navigation").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.IntroBlock.Storybook()
                    } label: {
                        Text("Intro Block").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.FileUploadSheet.Storybook()
                    } label: {
                        Text("File Upload Sheet").tint(Color.black)
                    }
                    NavigationLink {
                        HorizonUI.Toast.Storybook()
                    } label: {
                        Text("Alert Toast").tint(Color.black)
                    }

                    NavigationLink {
                        HorizonUI.FileDropUploader.Storybook()
                    } label: {
                        Text("File Drop Uploader").tint(Color.black)
                    }

                    NavigationLink {
                        HorizonUI.UploadedFile.Storybook()
                    } label: {
                        Text("Uploaded File").tint(Color.black)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationBarHidden(false)
        }
        .navigationTitle("Design System")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    Storybook()
}
