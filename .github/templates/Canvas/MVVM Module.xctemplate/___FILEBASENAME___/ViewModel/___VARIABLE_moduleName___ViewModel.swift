//___FILEHEADER___

import Combine

public class ___VARIABLE_moduleName___ViewModel: ObservableObject {
    @Published public private(set) var state: InstUI.ScreenState = .loading
    public let pageTitle = String(localized: "template", bundle: .core)
    public let pageViewEvent = ScreenViewTrackingParameters(eventName: "/template")

    private let interactor: ___VARIABLE_moduleName___Interactor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: ___VARIABLE_moduleName___Interactor) {
        self.interactor = interactor
    }
}
