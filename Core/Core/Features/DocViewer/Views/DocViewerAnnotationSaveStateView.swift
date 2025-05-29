//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import SwiftUI
import PSPDFKit
import PSPDFKitUI

class DocViewerAnnotationSaveStateViewModel: ObservableObject {
    enum State: Equatable, CaseIterable {
        case saving
        case saved
        case error

        var text: String {
            switch self {
            case .saving: String(localized: "Saving...", bundle: .core)
            case .saved: String(localized: "All annotations saved.", bundle: .core)
            case .error: String(localized: "Error Saving. Tap to retry.", bundle: .core)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .saved: .textSuccess
            case .error: .textDanger
            default: .textDarkest
            }
        }

        var icon: Image {
            switch self {
            case .saving: .circleArrowUpLine
            case .saved: .checkSolid
            case .error: .xSolid
            }
        }

        var isEnabled: Bool {
            self == .error
        }
    }

    @Published fileprivate(set) var saveState: State = .saved
    let didTapRetry = PassthroughSubject<Void, Never>()

    init(state: State = .saved) {
        self.saveState = state
    }
}

struct DocViewerAnnotationSaveStateView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
//    @State private var isDragButtonSelected: Bool = false

    @ObservedObject private var viewModel: DocViewerAnnotationSaveStateViewModel

    init(
        viewModel: DocViewerAnnotationSaveStateViewModel,
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button {
            if viewModel.saveState == .error {
                viewModel.didTapRetry.send(())
            }
        } label: {
            HStack(spacing: 0) {
                viewModel.saveState.icon
                    .scaledIcon(size: 12)
                    .padding(.trailing, 3)
                Text(viewModel.saveState.text)
                    .font(.regular12, lineHeight: .fit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(viewModel.saveState) // This will trigger a transition animation when the state changes
            .transition(.push(from: .bottom))
        }
        .background(Color.backgroundLightest)
        .foregroundStyle(viewModel.saveState.foregroundColor)
        .clipped()
        .disabled(!viewModel.saveState.isEnabled)
        .accessibilityAddTraits(viewModel.saveState.isEnabled ? [.isButton] : [])
        .animation(.default, value: viewModel.saveState)
    }
}

#if DEBUG

#Preview {
    @Previewable @State var changingViewModel = DocViewerAnnotationSaveStateViewModel(state: .saving)

    VStack(spacing: 0) {
        DocViewerAnnotationSaveStateView(
            viewModel: DocViewerAnnotationSaveStateViewModel(state: .saving)
        )
        DocViewerAnnotationSaveStateView(
            viewModel: DocViewerAnnotationSaveStateViewModel(state: .error)
        )
        DocViewerAnnotationSaveStateView(
            viewModel: DocViewerAnnotationSaveStateViewModel(state: .saved)
        )
        DocViewerAnnotationSaveStateView(
            viewModel: changingViewModel
        )
    }
    .onAppear {
        let timer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { _ in
            var possibleCases = DocViewerAnnotationSaveStateViewModel.State.allCases
            possibleCases.removeAll(where: { $0 == changingViewModel.saveState })
            if let randomState = possibleCases.randomElement() {
                changingViewModel.saveState = randomState
            }
        }
        timer.fire() // Trigger once immediately
    }
}

#endif
//
//// MARK: - PSPDFKit Toolbar Representable
//
//struct AnnotationToolbarRepresentable: UIViewRepresentable {
//    var annotationStateManager: AnnotationStateManager
//    @Binding var isDragButtonSelected: Bool
//
//    func makeUIView(context: Context) -> DocViewerAnnotationToolbar {
//        let toolbar = DocViewerAnnotationToolbar(annotationStateManager: annotationStateManager)
//        toolbar.tintColor = Brand.shared.primary
//        toolbar.backgroundView = nil
//        toolbar.backgroundColor = .backgroundLightest
//
//        // Connect the publisher
//        toolbar.isDragButtonSelected
//            .sink { isDragSelected in
//                isDragButtonSelected = isDragSelected
//            }
//            .store(in: &context.coordinator.subscriptions)
//
//        return toolbar
//    }
//
//    func updateUIView(_ uiView: DocViewerAnnotationToolbar, context: Context) {
//        // Update any toolbar properties here if needed
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator {
//        var subscriptions = Set<AnyCancellable>()
//    }
//}
//
//// MARK: - Preview Provider
//
//struct DocViewerAnnotationToolsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let annotationStateManager = AnnotationStateManager()
//
//        VStack(spacing: 20) {
//            DocViewerAnnotationToolsView(
//                annotationStateManager: annotationStateManager,
//                initialState: .saved,
//                onRetry: {}
//            )
//
//            DocViewerAnnotationToolsView(
//                annotationStateManager: annotationStateManager,
//                initialState: .saving,
//                onRetry: {}
//            )
//
//            DocViewerAnnotationToolsView(
//                annotationStateManager: annotationStateManager,
//                initialState: .error,
//                onRetry: {}
//            )
//        }
//        .previewLayout(.sizeThatFits)
//    }
//}
