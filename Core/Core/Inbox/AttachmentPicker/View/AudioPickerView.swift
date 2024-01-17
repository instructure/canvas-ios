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

import Foundation
import SwiftUI

struct AudioPickerView: View {
    @ObservedObject private var viewModel: AudioPickerViewModel
    @Environment(\.viewController) private var controller

    init(viewModel: AudioPickerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            durationView
            contentView
            controlView
        }
        .background {
            Color.black
        }
    }

    private var durationView: some View {
        HStack(alignment: .center) {
            if viewModel.isRecording {
                Text(viewModel.recordingDurationString)
                    .foregroundStyle(Color.white)
            } else if viewModel.isPlaying {
                Text(viewModel.playingDurationString)
                    .foregroundStyle(Color.white)
            } else {
                Text(viewModel.defaultDurationString)
                    .foregroundStyle(Color.white)
            }
        }
        .padding(.vertical, 12)
        .background {
            Color.black
        }
    }

    private var contentView: some View {
        VStack {
            HStack {
                Spacer()
            }
            Spacer()
        }
        .background { Color.red }
    }

    private var controlView: some View {
        HStack {
            if (viewModel.availableForPlaying) {
                VStack(alignment: .leading) {
                    Button {
                        viewModel.availableForPlaying = false
                    } label: {
                        Text("Retake", bundle: .core)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .center) {
                    if (!viewModel.isPlaying) {
                        Button {
                            viewModel.startPlaying()
                        } label: {
                            Image.playSolid
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 50, height: 50, alignment: .center)
                    } else {
                        Button {
                            viewModel.pausePlaying()
                        } label: {
                            Image.pauseSolid
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 50, height: 50, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .trailing) {
                    Button {
                        viewModel.useAudioButtonDidTap.accept(controller)
                    } label: {
                        Text("Use Audio", bundle: .core)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading) {
                    Button {
                        viewModel.cancelButtonDidTap.accept(controller)
                    } label: {
                        Text("Cancel", bundle: .core)
                            .foregroundStyle(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .center) {
                    if (!viewModel.isRecording) {
                        Button {
                            viewModel.startRecording()
                        } label: {
                            ZStack {
                                Circle()
                                    .padding(0)
                                    .foregroundStyle(Color.white)
                                Circle()
                                    .padding(2)
                                    .foregroundStyle(Color.black)
                                Circle()
                                    .padding(5)
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .frame(width: 50, height: 50, alignment: .center)
                    } else {
                        Button {
                            viewModel.stopRecording()
                        } label: {
                            ZStack {
                                Circle()
                                    .padding(0)
                                    .foregroundStyle(Color.white)
                                Circle()
                                    .padding(2)
                                    .foregroundStyle(Color.black)
                                Rectangle()
                                    .padding(10)
                                    .foregroundStyle(Color.red)
                            }
                            .animation(.default)
                        }
                        .frame(width: 50, height: 50, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .trailing) {
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background {
            Color.black
        }
    }

}

#if DEBUG

struct AudioPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPickerView(viewModel: AudioPickerViewModel(router: PreviewEnvironment().router))
    }
}

#endif
