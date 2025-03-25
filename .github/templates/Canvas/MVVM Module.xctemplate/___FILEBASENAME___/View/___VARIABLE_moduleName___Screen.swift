//___FILEHEADER___

import SwiftUI

public struct ___VARIABLE_moduleName___Screen: View, ScreenViewTrackable {
    public var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @ObservedObject private var viewModel: ___VARIABLE_moduleName___ViewModel

    public init(viewModel: ___VARIABLE_moduleName___ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(state: viewModel.state) { _ in
            Text(verbatim: "template")
        }
        .navigationTitle(viewModel.pageTitle)
    }
}

#if DEBUG

#Preview {
    ___VARIABLE_moduleName___Assembly.makePreview()
}

#endif
