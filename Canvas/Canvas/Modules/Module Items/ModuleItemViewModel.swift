//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import ReactiveCocoa
import Result
import SoPersistent
import SoEdventurous
import TooLegit
import SoIconic
import SoPretty
import TechDebt
import SoProgressive
import PageKit
import AssignmentKit

let ModuleItemBecameActiveNotification = "ModuleItemBecameActiveNotification"

class ModuleItemViewModel: NSObject {
    // Input
    let session: Session
    let moduleID: String

    // Output
    let title: AnyProperty<String?>
    let completionRequirement: AnyProperty<ModuleItem.CompletionRequirement?>
    let errorSignal: Signal<NSError, NoError>
    let moduleItemID: AnyProperty<String?>
    lazy var embeddedViewController: SignalProducer<UIViewController?, NoError> = {
        let content = self.moduleItem.producer.map { $0?.content }.skipRepeats(==)
        let masteryPathsItemModuleItemID = self.moduleItem.producer.map { $0 as? MasteryPathsItem }.map { $0?.moduleItemID }.skipRepeats(==)
        let url = self.url.producer.skipRepeats(==)
        return combineLatest(url, content, masteryPathsItemModuleItemID).map { url, content, moduleItemID in
            if let content = content {
                switch content {
                case .ExternalURL(url: let url):
                    let browser = WebBrowserViewController(URL: url)
                    browser.delegate = self
                    return browser
                case .MasteryPaths:
                    if let moduleItemID = moduleItemID {
                        return try! MasteryPathSelectOptionViewController(session: self.session, moduleID: self.moduleID, itemIDWithMasteryPaths: moduleItemID)
                    }
                default: break
                }
            }
            return url.flatMap(Router.sharedRouter().controllerForHandlingURL)
        }
    }()

    // Private
    private let moduleItem: MutableProperty<ModuleItem?>
    private var observer: ManagedObjectObserver<ModuleItem> {
        didSet {
            moduleItem.value = observer.object
            moduleItem <~ observer.signal.map { $0.1 }.filter { !($0?.deleted ?? false) }
        }
    }
    private let moduleObserver: ManagedObjectObserver<Module>
    private let module: AnyProperty<Module?>
    private let errorObserver: Observer<NSError, NoError>
    private let disposable = CompositeDisposable()
    private let siblingsCollection: FetchedCollection<ModuleItem>
    private let siblingsUpdates: AnyProperty<[CollectionUpdate<ModuleItem>]>
    private let url: AnyProperty<NSURL?>
    private let completed: AnyProperty<Bool?>
    private let nextModuleItem: AnyProperty<ModuleItem?>
    private let previousModuleItem: AnyProperty<ModuleItem?>
    private let nextModuleItemIsValid: AnyProperty<Bool>
    private let previousModuleItemIsValid: AnyProperty<Bool>
    private let selected = MutableProperty<Bool?>(nil)
    private let locked: AnyProperty<Bool>

    // Actions
    lazy var markAsDoneAction: Action<Void, Void, NoError> = {
        return Action(enabledIf: self.canFulfill(.MarkDone)) { _ in
            blockProducer {
                self.moduleItem.value?.postProgress(self.session, kind: .MarkedDone) ?? ()
            }
        }
    }()
    lazy var markAsViewedAction: Action<Void, Void, NoError> = {
        return Action(enabledIf: self.canFulfill(.MustView)) { _ in
            blockProducer {
                self.moduleItem.value?.postProgress(self.session, kind: .Viewed) ?? ()
            }
        }
    }()
    lazy var nextAction: Action<Void, Void, NSError> = {
        return Action(enabledIf: self.nextModuleItemIsValid) { _ in
            attemptProducer {
                guard let next = self.nextModuleItem.value else {
                    fatalError("This action should only be enabled if there is a next item")
                }
                self.observer = try ModuleItem.observer(self.session, moduleItemID: next.id)
            }
        }
    }()
    lazy var previousAction: Action<Void, Void, NSError> = {
        return Action(enabledIf: self.previousModuleItemIsValid) { _ in
            attemptProducer {
                guard let previous = self.previousModuleItem.value else {
                    fatalError("This action should only be enabled if there is a previous item")
                }
                self.observer = try ModuleItem.observer(self.session, moduleItemID: previous.id)
            }
        }
    }()

    // Cocoa Actions
    lazy var markAsDoneCocoaAction: CocoaAction = { CocoaAction(self.markAsDoneAction, input: ()) }()
    lazy var nextCocoaAction: CocoaAction = { CocoaAction(self.nextAction, input: ()) }()
    lazy var previousCocoaAction: CocoaAction = { CocoaAction(self.previousAction, input: ()) }()

    private lazy var colorfulViewModel: ColorfulViewModel = {
        let vm = ColorfulViewModel(style: .Subtitle)
        vm.title <~ self.title.producer.map { $0 ?? "" }
        vm.detail <~ self.moduleItem.producer.map { $0?.detailText ?? "" }
        vm.icon <~ self.moduleItem.producer.map { $0?.icon }
        vm.accessibilityIdentifier.value = "module_item"

        vm.accessoryView <~ combineLatest(self.completed.producer, self.locked.producer).map { completed, locked in
            guard !locked else {
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
            .flatMap(.Latest) {
                $0.flatMap { self.session.enrollmentsDataSource.producer(ContextID(id: $0, context: .Course)).map { $0?.color ?? .prettyGray() } } ?? SignalProducer(value: .prettyGray())
            }
        vm.titleFontStyle <~ self.moduleItem
            .producer
            .map { moduleItem in
                let fontStyle: ColorfulViewModel.FontStyle
                if let content = moduleItem?.content where content == .SubHeader {
                    fontStyle = .bold
                } else if let masteryPathsItem = moduleItem as? MasteryPathsItem where masteryPathsItem.lockedForUser {
                    fontStyle = .italic
                } else {
                    fontStyle = .regular
                }
                return fontStyle
            }
        vm.titleTextColor <~ self.locked.producer.map { $0 ? .lightGrayColor() : .blackColor() }
        vm.indentationLevel <~ self.moduleItem.producer.map { $0?.indent ?? 0 }
        vm.selectionEnabled <~ self.locked.producer.map { !$0 }
        vm.setSelected <~ self.selected

        let contentType = self.moduleItem.producer.map { $0?.contentType.accessibilityLabel }
        vm.accessibilityLabel <~ combineLatest(vm.title.producer, vm.detail.producer, contentType, self.completed.producer, self.locked.producer)
            .map { title, detail, content, completed, locked in
                let completedStatus = NSLocalizedString("Status: Completed", comment: "Label read aloud when item status is completed.")
                let incompleteStatus = NSLocalizedString("Status: Incomplete", comment: "Label read aloud when item status is incomplete.")
                let lockedStatus = NSLocalizedString("Status: Locked", comment: "Label read aloud when item status is locked.")
                let status = locked ? lockedStatus : completed.flatMap { $0 ? completedStatus : incompleteStatus }
                return [title, detail, content, status].flatMap { $0 }.filter { !$0.isEmpty }.joinWithSeparator(". ")
            }

        return vm
    }()

    init(session: Session, moduleID: String, moduleItemID: String) throws {
        self.session = session
        self.moduleID = moduleID

        observer = try ModuleItem.observer(session, moduleItemID: moduleItemID)
        moduleItem = MutableProperty(observer.object)
        moduleItem <~ observer.signal.map { $0.1 }.filter { !($0?.deleted ?? false) }

        moduleObserver = try Module.observer(session, moduleID: moduleID)
        module = AnyProperty(initialValue: moduleObserver.object, signal: moduleObserver.signal.map { $0.1 })

        siblingsCollection = try ModuleItem.allModuleItemsCollection(session, moduleID: moduleID)
        siblingsUpdates = AnyProperty(initialValue: [], signal: siblingsCollection.collectionUpdates)

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

        self.moduleItemID = AnyProperty(initialValue: nil, producer: moduleItem.producer.map { $0?.id }.skipRepeats(==))

        nextModuleItem = AnyProperty(initialValue: nil, producer: combineLatest(moduleItem.producer, siblingsUpdates.producer)
            .map { moduleItem, _ in moduleItem }
            .promoteErrors(NSError)
            .flatMap(.Latest) { moduleItem in
                attemptProducer {
                    try moduleItem?.next(session)
                }
            }
            .flatMapError { _ in SignalProducer(value: nil) }
        )

        previousModuleItem = AnyProperty(initialValue: nil, producer: combineLatest(moduleItem.producer, siblingsUpdates.producer)
            .map { moduleItem, _ in moduleItem }
            .promoteErrors(NSError)
            .flatMap(.Latest) { moduleItem in
                attemptProducer {
                    try moduleItem?.previous(session)
                }
            }
            .flatMapError { _ in SignalProducer(value: nil) }
        )

        nextModuleItemIsValid = nextModuleItem.map { $0 != nil }

        previousModuleItemIsValid = previousModuleItem.map { $0 != nil }

        (errorSignal, errorObserver) = Signal.pipe()

        url = moduleItem.map { $0?.url.flatMap { NSURL(string: $0) } }

        completed = moduleItem.map { moduleItem in
            guard let
                moduleItem = moduleItem,
                completionRequirement = moduleItem.completionRequirement
                where completionRequirement != .MustChoose
            else {
                return nil
            }
            return moduleItem.completed ?? false
        }

        let lockedForUser = self.moduleItem.producer.map { $0?.lockedForUser ?? true }
        let moduleLocked = self.module.producer.map { $0?.state == .locked }
        locked = AnyProperty(initialValue: true, producer: combineLatest(lockedForUser, moduleLocked).map { $0 || $1 })

        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moduleItemBecameActive(_:)), name: ModuleItemBecameActiveNotification, object: nil)
        beginObservingLockedStatus()
    }

    convenience init(session: Session, moduleItem: ModuleItem) throws {
        try self.init(session: session, moduleID: moduleItem.moduleID, moduleItemID: moduleItem.id)
    }

    deinit {
        disposable.dispose()
    }

    private func canFulfill(completionRequirement: ModuleItem.CompletionRequirement) -> AnyProperty<Bool> {
        let sameCompletionRequirement = moduleItem.producer.map { $0?.completionRequirement == completionRequirement }.skipRepeats(==)
        let completed = moduleItem.producer.map { $0?.completed ?? false }.skipRepeats(==)
        let canFulfill = combineLatest(sameCompletionRequirement, completed).map { $0 && !$1 }
        return AnyProperty(initialValue: false, producer: canFulfill)
    }

    func moduleItemBecameActive(notification: NSNotification) {
        if let moduleItem = moduleItem.value, id = notification.userInfo?["moduleItemID"] as? String {
            selected.value = moduleItem.id == id
        }
    }

    func moduleItemBecameActive() {
        if let id = moduleItem.value?.id {
            NSNotificationCenter.defaultCenter().postNotificationName(ModuleItemBecameActiveNotification, object: nil, userInfo: ["moduleItemID": id])
        }
    }

    private func beginObservingLockedStatus() {
        locked.signal
            .combinePrevious(true)
            .observeNext { [weak self] previous, current in
                if previous && !current {
                    _ = try? self?.invalidateCaches()
                }
            }
    }

    private func invalidateCaches() throws {
        guard let content = moduleItem.value?.content, courseID = moduleItem.value?.courseID else {
            return
        }
        switch content {
        case let .Page(url: url):
            let contextID = ContextID(id: courseID, context: .Course)
            try Page.invalidateCache(session, contextID: contextID)
            try Page.invalidateDetailCache(session, contextID: contextID, url: url)
        case let .Assignment(id: id):
            try Assignment.invalidateCache(session, courseID: courseID)
            try Assignment.invalidateDetailsCache(session, courseID: courseID, id: id)
        default:
            break
        }
    }
}


// MARK: - WebBrowserViewControllerDelegate
extension ModuleItemViewModel: WebBrowserViewControllerDelegate {
    func webBrowser(webBrowser: WebBrowserViewController!, didFinishLoadingWebView webView: UIWebView!) {
        if moduleItemMatches(webBrowser.url) {
            markAsViewedAction.apply(()).start()
        }
    }

    private func moduleItemMatches(externalURL: NSURL) -> Bool {
        switch self.moduleItem.value?.content {
        case let .Some(.ExternalURL(url)):
            return externalURL == url
        default: return false
        }
    }
}


// MARK: - TableViewCellViewModel
extension ModuleItemViewModel: TableViewCellViewModel {
    static func tableViewDidLoad(tableView: UITableView) {
        ColorfulViewModel.tableViewDidLoad(tableView)
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return colorfulViewModel.cellForTableView(tableView, indexPath: indexPath)
    }
}


extension ModuleItem {
    var icon: UIImage? {
        guard let content = content else { return nil }
        switch content {
        case .Assignment:   return .icon(.assignment)
        case .Quiz:         return .icon(.quiz)
        case .Page:         return .icon(.page)
        case .File:         return .icon(.file)
        case .Discussion:   return .icon(.discussion)
        case .ExternalURL:  return .icon(.link)
        case .ExternalTool: return .icon(.lti)
        case .SubHeader:    return nil
        case .MasteryPaths: return .icon(.lock)
        }
    }

    var detailText: String {
        guard let completionRequirement = completionRequirement else { return "" }
        switch completionRequirement {
        case .MustView:         return NSLocalizedString("Must view", comment: "user must view item to complete requirement")
        case .MustSubmit:       return NSLocalizedString("Must submit", comment: "user must submit something to complete")
        case .MustContribute:   return NSLocalizedString("Must contribute", comment: "user must contribute to complete requirement")
        case .MarkDone:         return NSLocalizedString("Must mark as done", comment: "user must mark item as done to complete requirement")
        case .MustChoose:       return ""
        case .MinScore:
            guard let minScore = minScore else { return "" }
            return String(format: NSLocalizedString("Must score %@ or higher", comment: "format string saying what the minimum score must be"), minScore)
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
        case masteryPaths:
            type = NSLocalizedString("Mastery Path", comment: "Master Path module item type")
        }

        let template = NSLocalizedString("Type: %@", comment: "Label read aloud to describe module item type")
        return String.localizedStringWithFormat(template, type)
    }
}
