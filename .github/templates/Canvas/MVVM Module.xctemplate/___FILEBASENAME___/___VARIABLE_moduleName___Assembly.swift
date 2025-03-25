//___FILEHEADER___

import SwiftUI

public enum ___VARIABLE_moduleName___Assembly {

    public static func makeViewController() -> UIViewController {
        let interactor = ___VARIABLE_moduleName___InteractorLive()
        let viewModel = ___VARIABLE_moduleName___ViewModel(interactor: interactor)
        let view = ___VARIABLE_moduleName___Screen(viewModel: viewModel)
        let host = CoreHostingController(view)
        return host
    }

#if DEBUG

    public static func makePreview() -> some View {
        let interactor = ___VARIABLE_moduleName___InteractorPreview()
        let viewModel = ___VARIABLE_moduleName___ViewModel(interactor: interactor)
        return ___VARIABLE_moduleName___Screen(viewModel: viewModel)
    }

#endif
}
