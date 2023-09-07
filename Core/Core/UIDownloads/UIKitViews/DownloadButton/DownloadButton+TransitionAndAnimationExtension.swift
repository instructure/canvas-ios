import UIKit

@available(iOS 13.0, *)
extension DownloadButton {

    func transition(from currentState: State, to nextState: State) {
        handleUnknownTransition(state: nextState)
        resetOtherViews(currentState: nextState)
    }

    // MARK: - Transition Functions -

    func handleTransitionFromIdleToWaiting() {
        idleButton.alpha = 0
        waitingView.alpha = 1
    }

    func handleTransitionFromIdleToDownloading() {
        idleButton.alpha = 0
        downloadingButton.alpha = 1
    }

    func handleTransitionFromWaitingToIdle() {
        waitingView.alpha = 0
        idleButton.alpha = 1
    }

    func handleTransitionFromWaitingToDownloading() {
        waitingView.alpha = 0
        downloadingButton.alpha = 1
    }

    func handleTransitionFromDownloadingToDownloaded() {
        downloadingButton.alpha = 0
        downloadedButton.alpha = 1
    }

    func handleTransitionFromDownloadingToIdle() {
        downloadingButton.alpha = 0
        idleButton.alpha = 1
    }

    func handleUnknownTransition(state: State) {
        switch state {
        case .idle:
            self.idleButton.alpha = 1
        case .waiting:
            self.waitingView.alpha = 1
        case .downloading:
            self.downloadingButton.alpha = 1
        case .downloaded:
            self.downloadedButton.alpha = 1
        case .retry:
            self.retryButton.alpha = 1
        }
    }

    // MARK: - Reset Other Views -

    func resetOtherViews(currentState: State) {
        if currentState != .idle {
            self.idleButton.alpha = 0
        }
        if currentState != .waiting {
            self.waitingView.alpha = 0
        }
        if currentState != .downloading {
            self.downloadingButton.alpha = 0
        }
        if currentState != .downloaded {
            self.downloadedButton.alpha = 0
        }
        if currentState != .retry {
            self.retryButton.alpha = 0
        }
    }
}
