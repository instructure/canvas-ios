//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import ReactiveSwift
import ReactiveCocoa
import CanvasCore
import Core
import class CanvasCore.ModuleItem
import class CanvasCore.Module

extension Notification.Name {
    static let moduleItemBecameActive = Notification.Name(rawValue: "ModuleItemBecameActiveNotification")
}

class ModuleItemViewModel: NSObject {
    // Input
    @objc let session: Session

    // Output
    let title: Property<String?>
    let completionRequirement: Property<ModuleItem.CompletionRequirement?>
    let errorSignal: Signal<NSError, Never>
    let moduleID: Property<String?>
    let moduleItemID: Property<String?>
    lazy var embeddedViewController: SignalProducer<UIViewController?, Never> = {
        let item = self.moduleItem.producer.skipRepeats { $0?.content == $1?.content }
        return item.map { [weak self] moduleItem in
            guard let self = self else { return nil }
            let content = moduleItem?.content
            let masteryPathsItemModuleItemID = (moduleItem as? MasteryPathsItem)?.moduleItemID
            let moduleID = moduleItem?.moduleID
            let courseID = moduleItem?.courseID
            let htmlURL = moduleItem?.htmlURL
            let url = moduleItem?.url.flatMap(URL.init(string:))
            let moduleItemID = moduleItem?.id
            if let content = content {
                switch content {
                case .externalURL(url: let url):
                    let webView = CanvasWebView()
                    webView.finishedLoading = { [weak self] in
                        self?.markAsViewedAction.apply(()).start()
                    }
                    webView.load(source: .url(url))
                    return CanvasWebViewController(webView: webView, showDoneButton: false, showShareButton: true)
                case let .externalTool(toolID, url):
                    guard let courseID = courseID else { return nil }
                    let tools = LTITools(
                        context: .course(courseID),
                        id: toolID,
                        url: url,
                        launchType: .module_item,
                        assignmentID: nil,
                        moduleID: moduleID,
                        moduleItemID: moduleItemID
                    )
                    return LTIViewController.create(tools: tools)
                default: break
                }
            }
            if let url = url {
                let controller = AppEnvironment.shared.router.match(url)
                return controller
            }
            return nil
        }
    }()

    // Private
    fileprivate let moduleItem: MutableProperty<ModuleItem?>
    fileprivate var observer: ManagedObjectObserver<ModuleItem> {
        didSet {
            moduleItem.value = observer.object
            moduleItem <~ observer.signal.map { $0.1 }.filter { !($0?.isDeleted ?? false) }
        }
    }
    fileprivate let module: Property<Module?>
    fileprivate let errorObserver: Signal<NSError, Never>.Observer
    fileprivate let disposable = CompositeDisposable()
    fileprivate let siblingsUpdates: Property<[CollectionUpdate<ModuleItem>]>
    fileprivate let url: Property<URL?>
    fileprivate let completed: Property<Bool?>
    fileprivate let nextModuleItem: Property<ModuleItem?>
    fileprivate let previousModuleItem: Property<ModuleItem?>
    fileprivate let nextModuleItemIsValid: Property<Bool>
    fileprivate let previousModuleItemIsValid: Property<Bool>
    fileprivate let selected = MutableProperty<Bool?>(nil)
    fileprivate let locked: Property<Bool>

    // Actions
    lazy var markAsDoneAction: Action<Void, Void, Never> = {
        return Action(enabledIf: self.canFulfill(.markDone)) { [weak self] _ in
            blockProducer {
                guard let self = self else { return }
                self.moduleItem.value?.postProgress(self.session, kind: .markedDone)
                return
            }
        }
    }()
    lazy var markAsViewedAction: Action<Void, Void, Never> = {
        return Action(enabledIf: self.canFulfill(.mustView)) { [weak self] _ in
            blockProducer {
                guard let self = self else { return }
                self.moduleItem.value?.postProgress(self.session, kind: .viewed)
            }
        }
    }()
    lazy var nextAction: Action<Void, Void, NSError> = {
        return Action(enabledIf: self.nextModuleItemIsValid) { [weak self] _ in
            attemptProducer {
                guard let self = self, let next = self.nextModuleItem.value else { return }
                Analytics.shared.logEvent("module_item_content_selected_next")
                self.observer = try ModuleItem.observer(self.session, moduleItemID: next.id)
            }
        }
    }()
    lazy var previousAction: Action<Void, Void, NSError> = {
        return Action(enabledIf: self.previousModuleItemIsValid) { [weak self] _ in
            attemptProducer {
                guard let self = self, let previous = self.previousModuleItem.value else { return }
                Analytics.shared.logEvent("module_item_content_selected_previous")
                self.observer = try ModuleItem.observer(self.session, moduleItemID: previous.id)
            }
        }
    }()

    fileprivate lazy var colorfulViewModel: ColorfulViewModel = {
        var vm = ColorfulViewModel(features: [.icon, .subtitle])
        vm.title <~ self.title.producer.map { $0 ?? "" }
        vm.subtitle <~ self.moduleItem.producer.map { $0?.detailText ?? "" }
        vm.icon <~ self.moduleItem.producer.map { $0?.icon }
        vm.accessibilityIdentifier.value = "module_item"
        vm.titleLineBreakMode = .byWordWrapping
        
        let type = self.moduleItem.value?.contentType
        vm.accessoryView <~ SignalProducer.combineLatest(self.completed.producer, self.locked.producer).map { (completed, locked) -> UIView? in
            if locked {
                let imageView = UIImageView(image: .icon(.lock))
                imageView.tintColor = .prettyGray()
                return imageView
            }

            guard let completed = completed else { return nil }

            let image: UIImage = completed ? .icon(.complete, filled: true, size: .small) : .icon(.empty, size: .small)
            let imageView =  UIImageView(image: image)
            imageView.accessibilityLabel = NSLocalizedString("Assignment", comment: "Assignment icon a11y label")
            let green = UIColor(red: 76.0/255.0, green: 174.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            imageView.tintColor = completed ? green : UIColor.prettyGray()

            return imageView
        }
        vm.color <~ self.moduleItem
            .producer
            .map { $0?.courseID }
            .flatMap(.latest) { [weak self] in
                $0.flatMap { self?.session.enrollmentsDataSource.color(for: .course($0)) }
                    ?? SignalProducer(value: .prettyGray())
            }
        vm.titleFontStyle <~ self.moduleItem
            .producer
            .map { moduleItem in
                let fontStyle: ColorfulViewModel.FontStyle
                if let content = moduleItem?.content, content == .subHeader {
                    fontStyle = .bold
                } else if let masteryPathsItem = moduleItem as? MasteryPathsItem, masteryPathsItem.lockedForUser {
                    fontStyle = .italic
                } else {
                    fontStyle = .regular
                }
                return fontStyle
            }
        vm.titleTextColor <~ self.locked.producer.map { $0 && type != .assignment && type != .discussion ? .lightGray : .black }
        vm.indentationLevel <~ self.moduleItem.producer.map { $0?.indent ?? 0 }.map { Int($0) }
        vm.selectionEnabled <~ self.locked.producer.map { !$0 && type != .subHeader || type == .assignment || type == .discussion }
        let becameActive = NotificationCenter.default.reactive
            .notifications(forName: .moduleItemBecameActive)
            .take(duringLifetimeOf: vm.setSelected)
        vm.setSelected <~ SignalProducer.combineLatest(self.moduleItem.producer, becameActive)
            .map { moduleItem, notification in
                if let moduleItem = moduleItem, let id = notification.userInfo?["moduleItemID"] as? String {
                    return moduleItem.id == id
                }
                return false
            }

        let contentType = self.moduleItem.producer.map { $0?.contentType.accessibilityLabel }
        vm.accessibilityLabel <~ SignalProducer.combineLatest(vm.title.producer, vm.subtitle.producer, contentType, self.completed.producer, self.locked.producer)
            .map { title, detail, content, completed, locked -> String in
                let completedStatus = NSLocalizedString("Status: Completed", comment: "Label read aloud when item status is completed.")
                let incompleteStatus = NSLocalizedString("Status: Incomplete", comment: "Label read aloud when item status is incomplete.")
                let lockedStatus = NSLocalizedString("Status: Locked", comment: "Label read aloud when item status is locked.")
                let status = locked ? lockedStatus : completed.flatMap { $0 ? completedStatus : incompleteStatus }
                return [title, detail, content, status].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ". ")
            }

        return vm
    }()

    @objc init(session: Session, moduleItemID: String) throws {
        self.session = session

        observer = try ModuleItem.observer(session, moduleItemID: moduleItemID)
        moduleItem = MutableProperty(observer.object)
        moduleItem <~ observer.signal.map { $0.1 }.filter { !($0?.isDeleted ?? false) }
        moduleID = Property(initial: nil, then: moduleItem.producer.map { $0?.moduleID }.skipRepeats(==))

        let moduleSignal = moduleID
            .signal
            .skipNil()
            .flatMap(.latest) { id in
                attemptProducer { try Module.observer(session: session, moduleID: id) }
            }
            .flatMap(.latest) { $0.signal }
            .map { $0.1 }
            .flatMapError { _ in SignalProducer<Module?, Never>(value: nil) }
        module = Property(initial: nil, then: moduleSignal)

        let updatesSignal = moduleID
            .signal
            .skipNil()
            .flatMap(.latest) { id in
                attemptProducer { () -> FetchedCollection<ModuleItem> in
                    try ModuleItem.allModuleItemsCollection(session, moduleID: id)
                }
            }
            .flatMap(.latest) { $0.collectionUpdates }
            .flatMapError { _ in SignalProducer<[CollectionUpdate<ModuleItem>], Never>(value: []) }
        siblingsUpdates = Property(initial: [], then: updatesSignal)

        title = moduleItem.map { item in
            if let masteryPathsItem = item as? MasteryPathsItem {
                guard let moduleItemFRD: ModuleItem = try! masteryPathsItem.managedObjectContext?.findOne(withPredicate: NSPredicate(format: "%K == %@", "id", masteryPathsItem.moduleItemID)) else { return "" }
                if masteryPathsItem.lockedForUser {
                    return String(format: NSLocalizedString("Locked until \"%@\" is graded", comment: "Displayed when next assignment is locked until current assignment is graded. Placeholder is an assignment's name."), moduleItemFRD.title)
                } else {
                    return NSLocalizedString("Choose option", comment: "Text for button to allow user to choose a set of assignments to do")
                }
            }

            return item?.title
        }

        completionRequirement = moduleItem.map { $0?.completionRequirement }

        self.moduleItemID = Property(initial: nil, then: moduleItem.producer.map { $0?.id }.skipRepeats(==))

        nextModuleItem = Property(initial: nil, then: SignalProducer.combineLatest(moduleItem.producer, siblingsUpdates.producer)
            .map { moduleItem, _ in moduleItem }
            .promoteError(NSError.self)
            .flatMap(.latest) { moduleItem in
                attemptProducer {
                    try moduleItem?.next(session)
                }
            }
            .flatMapError { _ in SignalProducer(value: nil) }
        )

        previousModuleItem = Property(initial: nil, then: SignalProducer.combineLatest(moduleItem.producer, siblingsUpdates.producer)
            .map { moduleItem, _ in moduleItem }
            .promoteError(NSError.self)
            .flatMap(.latest) { moduleItem in
                attemptProducer {
                    try moduleItem?.previous(session)
                }
            }
            .flatMapError { _ in SignalProducer(value: nil) }
        )

        nextModuleItemIsValid = nextModuleItem.map { $0 != nil }

        previousModuleItemIsValid = previousModuleItem.map { $0 != nil }

        (errorSignal, errorObserver) = Signal.pipe()

        url = moduleItem.map { $0?.url.flatMap { URL(string: $0) } }

        completed = moduleItem.map { moduleItem in
            guard let
                moduleItem = moduleItem,
                let completionRequirement = moduleItem.completionRequirement, completionRequirement != .mustChoose
            else {
                return nil
            }
            return moduleItem.completed
        }

        let lockedForUser = self.moduleItem.producer.map { $0?.lockedForUser ?? true }
        let moduleLocked = self.module.producer.map { $0?.state == .locked }
        locked = Property(initial: true, then: SignalProducer.combineLatest(lockedForUser, moduleLocked).map { $0 || $1 })

        super.init()
    }

    @objc convenience init(session: Session, moduleItem: ModuleItem) throws {
        try self.init(session: session, moduleItemID: moduleItem.id)
    }

    deinit {
        disposable.dispose()
    }

    fileprivate func canFulfill(_ completionRequirement: ModuleItem.CompletionRequirement) -> Property<Bool> {
        let sameCompletionRequirement = moduleItem.producer.map { $0?.completionRequirement == completionRequirement }
        let completed = moduleItem.producer.map { $0?.completed ?? false }
        let canFulfill = SignalProducer.combineLatest(sameCompletionRequirement.skipRepeats(==), completed.skipRepeats(==)).map { $0 && !$1 }
        return Property(initial: false, then: canFulfill)
    }

    @objc func moduleItemBecameActive() {
        if let id = moduleItem.value?.id {
            NotificationCenter.default.post(name: .moduleItemBecameActive, object: nil, userInfo: ["moduleItemID": id])
        }
    }
}


// MARK: - TableViewCellViewModel
extension ModuleItemViewModel: TableViewCellViewModel {
    @objc static func tableViewDidLoad(_ tableView: UITableView) {
        ColorfulViewModel.tableViewDidLoad(tableView)
    }

    @objc func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return colorfulViewModel.cellForTableView(tableView, indexPath: indexPath)
    }
}


extension ModuleItem {
    @objc static let mustScoreNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    @objc var icon: UIImage? {
        guard let content = content else { return nil }
        switch content {
        case .assignment:   return .icon(.assignment)
        case .quiz:         return .icon(.quiz)
        case .page:         return .icon(.page)
        case .file:         return .icon(.file)
        case .discussion:   return .icon(.discussion)
        case .externalURL:  return .icon(.link)
        case .externalTool: return .icon(.lti)
        case .subHeader:    return nil
        case .masteryPaths: return .icon(.lock)
        }
    }

    @objc var detailText: String {
        guard let completionRequirement = completionRequirement else { return "" }
        switch completionRequirement {
        case .mustView:         return NSLocalizedString("Must view", comment: "user must view item to complete requirement")
        case .mustSubmit:       return NSLocalizedString("Must submit", comment: "user must submit something to complete")
        case .mustContribute:   return NSLocalizedString("Must contribute", comment: "user must contribute to complete requirement")
        case .markDone:         return NSLocalizedString("Must mark as done", comment: "user must mark item as done to complete requirement")
        case .mustChoose:       return ""
        case .minScore:
            guard let minScore = minScore else { return "" }
            return String(format: NSLocalizedString("Must score %@ or higher", comment: "format string saying what the minimum score must be"), ModuleItem.mustScoreNumberFormatter.string(from: minScore) ?? "")
        }
    }
}

extension ModuleItem.ContentType {
    var accessibilityLabel: String {
        let type: String

        switch self {
        case .file:
            type = NSLocalizedString("File", comment: "File module item type")
        case .page:
            type = NSLocalizedString("Page", comment: "Page module item type")
        case .discussion:
            type = NSLocalizedString("Discussion", comment: "Discussion module item type")
        case .assignment:
            type = NSLocalizedString("Assignment", comment: "Assignment module item type")
        case .quiz:
            type = NSLocalizedString("Quiz", comment: "Quiz module item type")
        case .subHeader:
            type = NSLocalizedString("Sub Header", comment: "Header item label")
        case .externalURL:
            type = NSLocalizedString("Link", comment: "Web URL link item label")
        case .externalTool:
            type = NSLocalizedString("External URL", comment: "External URL module item type")
        case .masteryPaths:
            type = NSLocalizedString("Mastery Path", comment: "Master Path module item type")
        }

        let template = NSLocalizedString("Type: %@", comment: "Label read aloud to describe module item type")
        return String.localizedStringWithFormat(template, type)
    }
}
