import UIKit

@available(iOS 13.0, *)
public final class DownloadButton: UIView {

    // MARK: - States -

    public enum State {
        case idle
        case waiting
        case retry
        case downloading
        case downloaded
    }

    // MARK: - Attributes , Colors and Fonts -

    public var mainTintColor: UIColor = .blue {
        didSet {
            idleButton.tintColor = mainTintColor
            waitingView.strokeColor = mainTintColor
            downloadingButton.mainTintColor = mainTintColor
            downloadedButton.tintColor = mainTintColor
            retryButton.tintColor = mainTintColor
        }
    }
    let buttonConfiguration = UIImage.SymbolConfiguration(weight: .light)
    public lazy var idleButtonImage: UIImage = UIImage(
        systemName: "arrow.down.circle",
        withConfiguration: buttonConfiguration
    )! {
        didSet {
            self.idleButton.setImage(idleButtonImage, for: .normal)
            self.idleButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    public lazy var downloadedButtonImage: UIImage = UIImage(
        systemName: "trash.circle",
        withConfiguration: buttonConfiguration
    )! {
        didSet {
            self.downloadedButton.setImage(downloadedButtonImage, for: .normal)
            self.downloadedButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    public lazy var retryButtonImage: UIImage = UIImage(
        systemName: "arrow.clockwise.circle",
        withConfiguration: buttonConfiguration
    )! {
        didSet {
            self.retryButton.setImage(retryButtonImage, for: .normal)
            self.retryButton.imageView?.contentMode = .scaleAspectFit
        }
    }

    public var progress: Float = 0 {
        didSet {
            downloadingButton.progress = progress
        }
    }

    public var currentState: State = .idle {
        didSet {
            // MARK: - Current State Changed
            transition(from: oldValue, to: currentState)
            onState?(currentState)
        }
    }
    var onState: ((State) -> Void)?

    // MARK: - Private Properties -

    let idleButton: RoundButton = RoundButton()
    let waitingView: WaitingView = WaitingView()
    let retryButton: RoundButton = RoundButton()
    let downloadingButton: ProgressButton = ProgressButton()
    let downloadedButton: RoundButton = RoundButton()

    // MARK: - CallBacks -

    public var onTap: ((State) -> Void)?

    // MARK: - Inits -

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        commonInit()
    }

    public func setImageForAllStates(uiImage: UIImage) {
        idleButtonImage = uiImage
        downloadedButtonImage = uiImage
        retryButtonImage = uiImage
    }

    public func defaultImageForStates() {
        idleButtonImage = UIImage(
            systemName: "arrow.down.circle",
            withConfiguration: buttonConfiguration
        ) ?? UIImage()
        downloadedButtonImage = UIImage(
            systemName: "trash.circle",
            withConfiguration: buttonConfiguration
        ) ?? UIImage()
        retryButtonImage = UIImage(
            systemName: "arrow.clockwise.circle",
            withConfiguration: buttonConfiguration
        ) ?? UIImage()
    }

    private func commonInit() {
        addSubview(idleButton)
        setIdleButtonConstraints()
        idleButton.image = idleButtonImage
        idleButton.tintColor = mainTintColor
        idleButton.addTarget(self, action: #selector(currentButtonTapped), for: .touchUpInside)

        addSubview(waitingView)
        setWaitingButtonConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currentButtonTapped))
        waitingView.addGestureRecognizer(tapGesture)
        waitingView.strokeColor = mainTintColor

        addSubview(downloadingButton)
        setDownloadingButtonConstraints()
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(currentButtonTapped))
        downloadingButton.addGestureRecognizer(tapGesture2)
        progress = 0
        downloadingButton.mainTintColor = mainTintColor

        addSubview(downloadedButton)
        setDownloadedButtonConstraints()
        downloadedButton.image = downloadedButtonImage
        downloadedButton.tintColor = mainTintColor
        downloadedButton.addTarget(self, action: #selector(currentButtonTapped), for: .touchUpInside)

        addSubview(retryButton)
        setRetryButtonConstraints()
        retryButton.image = retryButtonImage
        retryButton.tintColor = mainTintColor
        retryButton.addTarget(self, action: #selector(currentButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup Constraitns -

    private func setIdleButtonConstraints() {
        idleButton.pinToSuperview()
    }

    private func setWaitingButtonConstraints() {
        waitingView.pinToSuperview(constant: 0)
    }

    private func setDownloadingButtonConstraints() {
        downloadingButton.pinToSuperview()
    }

    private func setDownloadedButtonConstraints() {
        downloadedButton.pinToSuperview()
    }

    private func setRetryButtonConstraints() {
        retryButton.pinToSuperview()
    }

    // MARK: - Actions -

    @objc private func currentButtonTapped(_ sender: UITapGestureRecognizer? = nil) {
        print("tap0ped")
        onTap?(currentState)
    }
}
