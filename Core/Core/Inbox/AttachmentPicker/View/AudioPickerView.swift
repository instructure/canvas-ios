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
import Charts

public struct AudioPickerView: View {
    @ObservedObject private var viewModel: AudioPickerViewModel
    @Environment(\.viewController) private var controller
    let backgroundColor: Color = .init(hexString: "#111213") ?? Color.black
    let textColor: Color = .init(hexString: "#F5F5F5") ?? Color.white

    init(viewModel: AudioPickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            durationView
            contentView
            controlView
        }
        .background {
            backgroundColor
                .ignoresSafeArea(.all)
        }
    }

    private var durationView: some View {
        HStack(alignment: .center) {
            if viewModel.isRecording {
                Text(viewModel.recordingLengthString)
                    .foregroundStyle(textColor)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerSize: .init(width: 12, height: 12))
                            .foregroundStyle(Color.textWarning)
                    }
            } else if viewModel.isReplay {
                Text(verbatim: "\(viewModel.audioPlayerPositionString) / \(viewModel.audioPlayerDurationString)")
                    .foregroundStyle(textColor)
                    .padding(12)
            } else {
                Text(viewModel.defaultDurationString)
                    .foregroundStyle(textColor)
                    .padding(12)
            }
        }
        .padding(.vertical, 12)
        .background {
            backgroundColor
        }
    }

    private var contentView: some View {
        VStack {
            GeometryReader { geometry in
                if viewModel.isReplay {
                    playbackPlotView(maxSize: geometry.size)
                } else {
                    recordingPlotView(maxSize: geometry.size)
                }
            }
        }
        .background { Color.textWarning }
    }

    private func recordingPlotView(maxSize: CGSize) -> some View {
        let barWidth: CGFloat = 2
        let spaceWidth: CGFloat = 5
        return HStack(alignment: .center, spacing: spaceWidth) {
            ForEach(viewModel.audioChartDataSet.suffix(Int(floor(maxSize.width / (barWidth + spaceWidth)))), id: \.timestamp) { plotData in
                Rectangle()
                    .frame(width: barWidth, height: viewModel.normalizeMeteringValue(rawValue: CGFloat(plotData.value), maxHeight: maxSize.height))
                    .foregroundStyle(Color.textWarning)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .background {
            backgroundColor
        }
    }

    private func playbackPlotView(maxSize: CGSize) -> some View {
        let barWidth: CGFloat = 2
        let spaceWidth: CGFloat = 5
        let barCount = Int(floor(maxSize.width / (barWidth + spaceWidth)))
        return VStack {
            HStack {
                HStack(alignment: .center, spacing: spaceWidth) {
                    ForEach(
                        viewModel.audioChartDataSet
                            .filter { element in element.timestamp <= viewModel.audioPlayerPosition }
                            .suffix(barCount / 2),
                        id: \.timestamp
                    ) { plotData in
                        Rectangle()
                            .frame(width: barWidth, height: viewModel.normalizeMeteringValue(rawValue: CGFloat(plotData.value), maxHeight: maxSize.height))
                            .foregroundStyle(Color.textWarning)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

                HStack(alignment: .center, spacing: spaceWidth) {
                    ForEach(
                        viewModel.audioChartDataSet
                            .filter { element in element.timestamp >= viewModel.audioPlayerPosition }
                            .prefix(barCount / 2),
                        id: \.timestamp
                    ) { plotData in
                        Rectangle()
                            .frame(width: barWidth, height: viewModel.normalizeMeteringValue(rawValue: CGFloat(plotData.value), maxHeight: maxSize.height))
                            .foregroundStyle(Color.textWarning)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { gesture in
                viewModel.seekInAudio(gesture.translation.width)
            }
        )
        .background {
            backgroundColor
        }
        .overlay(
            VStack(alignment: .center) {
                HStack {
                    Divider()
                        .overlay(textColor)
                }
            }
        )
    }

    @ViewBuilder
    private var controlView: some View {
        if viewModel.isReplay {
            playBackControlView
        } else {
            recordControlView
        }
    }

    private var playBackControlView: some View {
        HStack {
            VStack(alignment: .leading) {
                Button {
                    viewModel.retakeButtonDidTap.accept(controller)
                } label: {
                    Text("Retake", bundle: .core)
                        .foregroundStyle(textColor)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .center) {
                if (!viewModel.isPlaying) {
                    Button {
                        viewModel.playAudioButtonDidTap.accept(controller)
                    } label: {
                        Image.playSolid
                            .foregroundStyle(textColor)
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                    .accessibilityLabel(Text("Play audio recording", bundle: .core))
                } else {
                    Button {
                        viewModel.pauseAudioButtonDidTap.accept(controller)
                    } label: {
                        Image.pauseSolid
                            .foregroundStyle(textColor)
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                    .accessibilityLabel(Text("Pause audio recording", bundle: .core))
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .trailing) {
                Button {
                    viewModel.useAudioButtonDidTap.accept(controller)
                } label: {
                    Text("Use Audio", bundle: .core)
                        .foregroundStyle(textColor)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background {
            backgroundColor
        }
    }

    private var recordControlView: some View {
        HStack {
            VStack(alignment: .leading) {
                Button {
                    viewModel.cancelButtonDidTap.accept(controller)
                } label: {
                    Text("Cancel", bundle: .core)
                        .foregroundStyle(textColor)
                }
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .center) {
                if viewModel.isRecorderLoading {
                    loadingIndicator
                } else if (!viewModel.isRecording) {
                    startRecordButton
                } else {
                    stopRecordingButton
                }
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .trailing) {
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background {
            backgroundColor
        }
    }

    private var startRecordButton: some View {
        Button {
            viewModel.recordAudioButtonDidTap.accept(controller)
        } label: {
            ZStack {
                Circle()
                    .padding(0)
                    .foregroundStyle(textColor)
                Circle()
                    .padding(2)
                    .foregroundStyle(backgroundColor)
                Circle()
                    .padding(5)
                    .foregroundStyle(Color.textWarning)
            }
        }
        .frame(width: 50, height: 50, alignment: .center)
        .accessibilityLabel(Text("Start audio recording", bundle: .core))
    }

    private var stopRecordingButton: some View {
        Button {
            viewModel.stopRecordAudioButtonDidTap.accept(controller)
        } label: {
            withAnimation {
                ZStack {
                    Circle()
                        .padding(0)
                        .foregroundStyle(textColor)
                    Circle()
                        .padding(2)
                        .foregroundStyle(backgroundColor)
                    Rectangle()
                        .padding(13)
                        .foregroundStyle(Color.textWarning)
                }
            }
        }
        .frame(width: 50, height: 50, alignment: .center)
        .accessibilityLabel(Text("Stop audio recording", bundle: .core))
    }

    private var loadingIndicator: some View {
        ZStack {
            Circle()
                .padding(0)
                .foregroundStyle(textColor)
            Circle()
                .padding(2)
                .foregroundStyle(backgroundColor)
            Circle()
                .fill(
                    AngularGradient(
                        colors: [textColor, .textWarning],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(270)
                    )
                )
                .padding(5)
            Circle()
                .padding(10)
                .foregroundStyle(Color.textWarning)
        }
        .frame(width: 50, height: 50, alignment: .center)
        .rotationEffect(.degrees(viewModel.loadingAnimationRotation))
        .onAppear {
            withAnimation(.linear(duration: 0.5)
                .speed(0.1).repeatForever(autoreverses: false)) {
                    viewModel.loadingAnimationRotation = 360.0
                }
        }
        .accessibilityLabel(Text("Audio recorder loading", bundle: .core))
    }
}

#if DEBUG

struct AudioPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentPickerAssembly.makeAudioPickerPreview(env: PreviewEnvironment())
    }
}

#endif
