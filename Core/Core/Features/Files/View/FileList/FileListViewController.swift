//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UIKit
import Combine
import CombineSchedulers

public class FileListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    private enum Section: Hashable { case uploads, searchResults, folderItems }
    private enum RowItem: Hashable {
        case upload(id: String)
        case searchResult(id: String)
        case folderItem(id: String)
    }

    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!

    // Legacy version exists, cannot be marked unavailable
    lazy var addButton: UIBarButtonItem = {
        var button = UIBarButtonItem(image: .addSolid)

        let addFolderAction = UIAction(title: .init(localized: "Add Folder", bundle: .core), image: .folderLine) { [weak self] _ in
            self?.addFolder()
        }
        addFolderAction.accessibilityIdentifier = "FileList.addFolderButton"

        let addFileAction = UIAction(title: .init(localized: "Add File", bundle: .core), image: .addDocumentLine) { [weak self] _ in
            guard let self = self else { return }
            self.filePicker.pick(from: self)
        }
        addFileAction.accessibilityIdentifier = "FileList.addFileButton"

        let menu = UIMenu(children: !isStudentAccessRestricted ? [addFolderAction, addFileAction] : [addFolderAction])
        return UIBarButtonItem(image: .addSolid, menu: menu)
    }()

    @available(iOS, deprecated: 26, message: "Non-legacy version exists")
    lazy var legacyAddButton = UIBarButtonItem(image: .addSolid, style: .plain, target: self, action: #selector(addItem))
    lazy var editButton = UIBarButtonItem(
        title: String(localized: "Edit", bundle: .core), style: .plain,
        target: self, action: #selector(edit)
    )

    let batchID = UUID.string
    public var color: UIColor?
    var env: AppEnvironment = .shared
    public let titleSubtitleView = TitleSubtitleView.create()
    var context = Context.currentUser
    lazy var filePicker = FilePicker(env: env, delegate: self)
    var keyboard: KeyboardTransitioning?
    var path = ""
    var searchTerm: String?
    var results: [APIFile] = []

    public lazy var screenViewTrackingParameters: ScreenViewTrackingParameters = {
        var eventName = "\(context == .currentUser ? "" : context.pathComponent)/files"
        if !path.isEmpty {
            eventName += "/folder/\(path)"
        }
        return ScreenViewTrackingParameters(eventName: eventName)
    }()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = context.contextType == .course ? env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var folder = env.subscribe(GetFolderByPath(context: context.local, path: path)) { [weak self] in
        self?.updateFolder()
    }

    var items: Store<GetFolderItems>?

    lazy var group = context.contextType == .group ? env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var uploads = env.uploadManager.subscribe(batchID: batchID) { [weak self] in
        self?.updateUploads()
    }

    private var offlineFileInteractor: OfflineFileInteractor?
    private var studentAccessInteractor: StudentAccessInteractor?
    private var subscriptions = Set<AnyCancellable>()
    private var isStudentAccessRestricted = false
    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var dataSource: UITableViewDiffableDataSource<Section, RowItem>!

    public static func create(
        env: AppEnvironment,
        context: Context,
        path: String? = nil,
        offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive(),
        studentAccessInteractor: StudentAccessInteractor? = nil,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> FileListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.env = env
        controller.path = path ?? ""
        controller.offlineFileInteractor = offlineFileInteractor
        controller.studentAccessInteractor = studentAccessInteractor
        controller.scheduler = scheduler
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        if #available(iOS 26, *) {
            navigationItem.title = String(localized: "Files", bundle: .core)
        } else {
            setupTitleViewInNavbar(title: String(localized: "Files", bundle: .core))
        }

        addButton.accessibilityIdentifier = "FileList.addButton"
        addButton.accessibilityLabel = String(localized: "Add Item", bundle: .core)
        legacyAddButton.accessibilityIdentifier = "FileList.addButton"
        legacyAddButton.accessibilityLabel = String(localized: "Add Item", bundle: .core)
        editButton.accessibilityIdentifier = "FileList.editButton"

        emptyImageView.image = UIImage(named: Panda.FilePicker.name, in: .core, compatibleWith: nil)
        emptyMessageLabel.text = String(localized: "This folder is empty.", bundle: .core)
        emptyTitleLabel.text = String(localized: "No Files", bundle: .core)
        errorView.messageLabel.text = String(localized: "There was an error loading files. Pull to refresh to try again.", bundle: .core)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        searchBar.placeholder = String(localized: "Search", bundle: .core)
        searchBar.backgroundColor = .backgroundLightest

        tableView.backgroundColor = .backgroundLightest
        tableView.refreshControl = refreshControl
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.tableView.contentOffset.y = self.searchBar.frame.height
        }

        studentAccessInteractor?
            .isRestricted()
            .receive(on: scheduler)
            .assign(to: \.isStudentAccessRestricted, on: self, ownership: .weak)
            .store(in: &subscriptions)

        setupDataSource()

        colors.refresh()
        course?.refresh()
        group?.refresh()
        folder.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
        }
        if #unavailable(iOS 26) {
            if context.contextType == .user {
                navigationController?.navigationBar.useGlobalNavStyle()
            } else {
                navigationController?.navigationBar.useContextColor(color)
            }
        }
    }

    func updateNavBar() {
        if #available(iOS 26, *) {
            if let course = course?.first {
                navigationItem.subtitle = course.name
            } else if let group = group?.first {
                navigationItem.subtitle = group.name
            }
        } else {
            if let course = course?.first {
                updateNavBar(subtitle: course.name, color: course.color)
            } else if let group = group?.first {
                updateNavBar(subtitle: group.name, color: group.color)
            } else if context.contextType == .user {
                color = .textDark
            }
        }
        view.tintColor = color
        updateNavButtons()
    }

    func updateFolder() {
        if let folderID = items?.useCase.folderID, folder.isEmpty {
            let updated: Folder? = env.database.viewContext.first(where: #keyPath(Folder.id), equals: folderID)
            if let folder = updated, !env.database.viewContext.isObjectDeleted(folder) {
                // Folder was renamed, make sure next refresh doesn't 404.
                path = folder.path
                self.folder = env.subscribe(GetFolderByPath(context: context, path: path)) { [weak self] in
                    self?.updateFolder()
                }
            } else {
                // Folder was deleted, go back.
                env.router.dismiss(self)
            }
        }

        loadingView.isHidden = !folder.pending || !folder.isEmpty || folder.error != nil || refreshControl.isRefreshing
        errorView.isHidden = folder.error == nil
        let title = (path.isEmpty ? nil : folder.first?.name) ?? String(localized: "Files", bundle: .core)

        if #available(iOS 26, *) {
            navigationItem.title = title
        } else {
            setupTitleViewInNavbar(title: title)
        }

        updateNavButtons()

        guard let folder = folder.first, items == nil else { return update() }
        items = env.subscribe(GetFolderItems(folderID: folder.id)) { [weak self] in
            self?.update()
        }
        items?.refresh()
    }

    @objc func refresh() {
        folder.refresh(force: true)
        items?.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        search()
    }

    func update() {
        guard let items = items, searchTerm == nil else { return }
        loadingView.isHidden = !items.pending || !items.isEmpty || items.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = items.pending || !items.isEmpty || items.error != nil
        errorView.isHidden = items.error == nil
        applySnapshot()
    }

    func delete(fileID: String, fileName: String) {
        showDeleteAlert(name: fileName) { [weak self] _ in
            DeleteFile(fileID: fileID).fetch { _, _, error in
                performUIUpdate {
                    if let error = error {
                        self?.showError(error)
                    } else {
                        self?.refresh()
                    }
                }
            }
        }
    }

    func delete(folder: Folder) {
        showDeleteAlert(name: folder.name) { [weak self] _ in
            DeleteFolder(folderID: folder.id, force: true).fetch { _, _, error in
                performUIUpdate {
                    if let error = error {
                        self?.showError(error)
                    }
                }
            }
        }
    }

    func showDeleteAlert(name: String, handler: @escaping ((UIAlertAction) -> Void)) {
        let title = String.localizedStringWithFormat(String(localized: "Are you sure you want to delete %@?", bundle: .core), name)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        alert.addAction(AlertAction(String(localized: "Delete", bundle: .core), style: .default, handler: handler))
        env.router.show(alert, from: self, options: .modal())
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, rowItem in
            guard let self else { return UITableViewCell() }
            let isOffline = self.offlineFileInteractor?.isOffline == true
            switch rowItem {
            case .upload(let id):
                let cell: FileListUploadCell = tableView.dequeue(for: indexPath)
                let file = self.uploads.all.first(where: { self.uploadID($0) == id })
                cell.update(file)
                return cell
            case .searchResult(let id):
                let cell: FileListCell = tableView.dequeue(for: indexPath)
                cell.accessibilityIdentifier = "FileList.\(indexPath.row)"
                cell.backgroundColor = .backgroundLightest
                let result = self.results.first(where: { $0.id.value == id })
                let isAvailable = self.offlineFileInteractor?.isItemAvailableOffline(courseID: self.course?.first?.id, fileID: id) == true
                cell.update(result: result, isOffline: isOffline, isAvailable: isAvailable)
                return cell
            case .folderItem(let id):
                let cell: FileListCell = tableView.dequeue(for: indexPath)
                cell.accessibilityIdentifier = "FileList.\(indexPath.row)"
                cell.backgroundColor = .backgroundLightest
                let item = self.items?.all.first(where: { $0.id == id })
                let isAvailable = self.offlineFileInteractor?.isItemAvailableOffline(courseID: self.course?.first?.id, fileID: item?.id) == true
                cell.update(item: item, color: self.color, isOffline: isOffline, isAvailable: isAvailable)
                return cell
            }
        }
        tableView.delegate = self
        tableView.selectionFollowsFocus = false
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>()
        snapshot.appendSections([.uploads, .searchResults, .folderItems])

        let uploadItems = uploads.all.map { RowItem.upload(id: uploadID($0)) }
        snapshot.appendItems(uploadItems, toSection: .uploads)

        let resultItems = results.map { RowItem.searchResult(id: $0.id.value) }
        snapshot.appendItems(resultItems, toSection: .searchResults)

        if searchTerm == nil {
            let folderItems = (items?.all ?? []).map { RowItem.folderItem(id: $0.id) }
            snapshot.appendItems(folderItems, toSection: .folderItems)
        }

        if !uploadItems.isEmpty {
            snapshot.reconfigureItems(uploadItems)
        }

        let updatedFolderItems = (items?.updatedObjects ?? []).map { RowItem.folderItem(id: $0.id) }
        if !updatedFolderItems.isEmpty {
            snapshot.reconfigureItems(updatedFolderItems)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func uploadID(_ file: File) -> String {
        file.taskID ?? file.objectID.uriRepresentation().absoluteString
    }
}

extension FileListViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if offlineFileInteractor?.isOffline == true {
            UIAlertController.showItemNotAvailableInOfflineAlert {
                self.searchBarCancelButtonClicked(searchBar)
            }
        }
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchBar(searchBar, textDidChange: "")
        searchBarSearchButtonClicked(searchBar)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let newSearch = searchText.count >= 3 ? searchText : nil
        tableView.setContentOffset(.zero, animated: true)
        guard newSearch != searchTerm else { return }
        searchTerm = newSearch
        if searchTerm != nil {
            emptyImageView.image = UIImage(named: Panda.NoResults.name, in: .core, compatibleWith: nil)
            emptyMessageLabel.text = String(localized: "We couldn’t find any files like that.", bundle: .core)
            emptyTitleLabel.text = String(localized: "No Results", bundle: .core)
        } else {
            emptyImageView.image = UIImage(named: Panda.FilePicker.name, in: .core, compatibleWith: nil)
            emptyMessageLabel.text = String(localized: "This folder is empty.", bundle: .core)
            emptyTitleLabel.text = String(localized: "No Files", bundle: .core)
        }
        search()
    }

    func search() {
        results = []
        guard let searchTerm = searchTerm else { return applySnapshot() }
        loadingView.isHidden = false
        emptyView.isHidden = true
        errorView.isHidden = true
        applySnapshot()
        env.api.makeRequest(GetFilesRequest(context: context, searchTerm: searchTerm)) { [weak self] files, _, error in performUIUpdate {
            guard self?.searchTerm == searchTerm else { return }
            self?.showResults(files ?? [], error: error)
        } }
    }

    func showResults(_ results: [APIFile], error: Error?) {
        self.results = results
        loadingView.isHidden = true
        emptyView.isHidden = !results.isEmpty
        errorView.isHidden = error == nil
        applySnapshot()
    }
}

extension FileListViewController: FilePickerDelegate {
    func updateNavButtons() {
        let button = if #available(iOS 26, *) { addButton } else { legacyAddButton }
        navigationItem.rightBarButtonItems = [
            canAddItem ? button : nil,
            canEditFolder ? editButton : nil
        ].compactMap { $0 }
    }

    var canEditFolder: Bool {
        !path.isEmpty && // Can't edit root folder
        folder.first?.forSubmissions == false &&
        (
            context == .currentUser ||
            course?.first?.hasTeacherEnrollment == true
        )
    }

    @objc func edit() {
        guard let folderID = folder.first?.id else { return }
        env.router.route(to: "/folders/\(folderID)/edit", from: self, options: .modal(isDismissable: false, embedInNav: true))
    }

    var canAddItem: Bool {
        folder.first?.canUpload == true
    }

    @available(iOS, deprecated: 26)
    @objc func addItem() {
        let sheet = BottomSheetPickerViewController.create()
        sheet.addAction(
            image: .folderLine,
            title: String(localized: "Add Folder", bundle: .core),
            accessibilityIdentifier: "FileList.addFolderButton"
        ) { [weak self] in
            self?.addFolder()
        }
        if !isStudentAccessRestricted {
            sheet.addAction(
                image: .addDocumentLine,
                title: String(localized: "Add File", bundle: .core),
                accessibilityIdentifier: "FileList.addFileButton"
            ) { [weak self] in
                guard let self = self else { return }
                self.filePicker.pick(from: self)
            }
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func addFolder() {
        let prompt = UIAlertController(title: String(localized: "Add Folder", bundle: .core), message: nil, preferredStyle: .alert)
        prompt.addTextField { field in
            field.placeholder = String(localized: "Name", bundle: .core)
            field.accessibilityLabel = String(localized: "Folder Name", bundle: .core)
        }
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        prompt.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .default) { [weak self] _ in
            let name = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            self?.addFolder(name: name)
        })
        env.router.show(prompt, from: self, options: .modal())
    }

    func addFolder(name: String) {
        guard let folderID = folder.first?.id else { return }
        CreateFolder(context: context, name: name, parentFolderID: folderID).fetch()
    }

    public func filePicker(didPick url: URL) {
        guard let folderID = folder.first?.id else { return }
        UploadManager.shared.upload(url: url, batchID: batchID, to: .context(Context(.folder, id: folderID)))
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.maxY), animated: true)
    }

    public func filePicker(didRetry file: File) {
        guard let folderID = folder.first?.id else { return }
        UploadManager.shared.upload(file: file, to: .context(Context(.folder, id: folderID)))
    }

    func updateUploads() {
        let completes = uploads.filter { $0.url != nil && $0.uploadError == nil }
        guard !completes.isEmpty else { return applySnapshot() }

        let context = env.database.viewContext
        let ucontext = UploadManager.shared.viewContext
        context.performAndWait {
            // Copy file object from globalDatabase
            for file in completes {
                let copy = context.copy(file)
                copy.batchID = nil
                FolderItem.save(copy, in: context)
            }
            // Delete from globalDatabase
            ucontext.delete(completes)
            try? ucontext.save()

            try? context.save()
        }
        folder.refresh(force: true)
    }
}

extension FileListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowItem = dataSource.itemIdentifier(for: indexPath) else { return }
        switch rowItem {
        case .upload(let id):
            let file = uploads.all.first(where: { uploadID($0) == id })
            if let file {
                filePicker.showOptions(for: file, from: self)
            }
        case .searchResult(let id):
            routeIfAvailable(fileID: id, indexPath: indexPath)
        case .folderItem(let id):
            if let file = items?.all.first(where: { $0.id == id })?.file, let fileID = file.id {
                routeIfAvailable(fileID: fileID, indexPath: indexPath)
            } else if let path = items?.all.first(where: { $0.id == id })?.folder?.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                env.router.route(to: "/\(context.pathComponent)/files/folder/\(path)", from: self, options: .push)
            }
        }
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let rowItem = dataSource.itemIdentifier(for: indexPath) else { return nil }

        switch rowItem {
        case .upload:
            return nil
        case .searchResult(let id):
            guard folder.first?.forSubmissions == false,
                  context == .currentUser || course?.first?.hasTeacherEnrollment == true else { return nil }
            let result = results.first(where: { $0.id.value == id })
            let deleteAction = UIContextualAction(style: .destructive, title: String(localized: "Delete", bundle: .core)) { [weak self] _, _, completion in
                if let file = result {
                    self?.delete(fileID: file.id.value, fileName: file.display_name)
                }
                completion(true)
            }
            deleteAction.backgroundColor = .backgroundDanger
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = false
            return config
        case .folderItem(let id):
            guard folder.first?.forSubmissions == false,
                  context == .currentUser || course?.first?.hasTeacherEnrollment == true else { return nil }
            let item = items?.all.first(where: { $0.id == id })
            if let folder = item?.folder, folder.forSubmissions || folder.filesCount > 0 { return nil }
            let deleteAction = UIContextualAction(style: .destructive, title: String(localized: "Delete", bundle: .core)) { [weak self] _, _, completion in
                guard let self else { return completion(true) }
                if let file = item?.file, let fileID = file.id, let fileName = file.displayName {
                    self.delete(fileID: fileID, fileName: fileName)
                } else if let folder = item?.folder {
                    self.delete(folder: folder)
                }
                completion(true)
            }
            deleteAction.backgroundColor = .backgroundDanger
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = false
            return config
        }
    }

    private func routeIfAvailable(fileID: String, indexPath: IndexPath) {
        if offlineFileInteractor?.isOffline == true {
            guard offlineFileInteractor?.isItemAvailableOffline(courseID: course?.first?.id, fileID: fileID) == true else {
                UIAlertController.showItemNotAvailableInOfflineAlert()
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        }
        env.router.route(to: "/\(context.pathComponent)/files/\(fileID)", from: self, options: .detail)
    }
}

class FileListUploadCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var sizeLabel: UILabel!

    func update(_ file: File?) {
        backgroundColor = .backgroundLightest
        iconView.isHidden = file?.uploadError == nil
        nameLabel.setText(file?.filename, style: .textCellTitle)
        progressView.color = nil
        progressView.progress = file.map { CGFloat($0.bytesSent) / CGFloat($0.size) }
        progressView.isHidden = file?.uploadError != nil
        let sizeText = file?.uploadError ?? file.map { String.localizedStringWithFormat(
            String(localized: "Uploading %@ of %@", bundle: .core, comment: "Uploading X KB of Y MB"),
            $0.bytesSent.humanReadableFileSize,
            $0.size.humanReadableFileSize
        ) }
        sizeLabel.setText(sizeText, style: .textCellSupportingText)
        sizeLabel.textColor = file?.uploadError == nil ? .textDark : .textDanger
    }
}

class FileListCell: UITableViewCell {
    @IBOutlet weak var iconView: AccessIconView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    private var fileID: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupInstDisclosureIndicator()
    }

    func update(item: FolderItem?, color: UIColor?, isOffline: Bool, isAvailable: Bool) {
        fileID = item?.id
        if isOffline {
            setCellState(isAvailable: isAvailable, isUserInteractionEnabled: true)
        }
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        nameLabel.setText(item?.name, style: .textCellTitle)
        if let folder = item?.folder {
            iconView.icon = .folderSolid
            iconView.setState(locked: folder.locked, hidden: folder.hidden, unlockAt: folder.unlockAt, lockAt: folder.lockAt)
            let sizeText = String.format(numberOfItems: folder.filesCount + folder.foldersCount)
            sizeLabel.setText(sizeText, style: .textCellSupportingText)
            updateAccessibilityLabel()
            return
        }
        let file = item?.file
        if !isOffline, let url = file?.thumbnailURL, let c = file?.createdAt, Clock.now.timeIntervalSince(c) > 3600 {
            iconView.load(url: url)
        } else {
            iconView.icon = file?.icon
        }
        iconView.setState(locked: file?.locked, hidden: file?.hidden, unlockAt: file?.unlockAt, lockAt: file?.lockAt)
        sizeLabel.setText(file?.size.humanReadableFileSize, style: .textCellSupportingText)
        updateAccessibilityLabel()
    }

    func update(result: APIFile?, isOffline: Bool, isAvailable: Bool) {
        fileID = result?.id.value
        if isOffline {
            setCellState(isAvailable: isAvailable, isUserInteractionEnabled: true)
        }
        nameLabel.setText(result?.display_name, style: .textCellTitle)
        if !isOffline, let url = result?.thumbnail_url?.rawValue, let c = result?.created_at, Clock.now.timeIntervalSince(c) > 3600 {
            iconView.load(url: url)
        } else {
            iconView.icon = File.icon(mimeClass: result?.mime_class, contentType: result?.contentType)
        }
        iconView.setState(locked: result?.locked, hidden: result?.hidden, unlockAt: result?.unlock_at, lockAt: result?.lock_at)
        sizeLabel.setText(result?.size?.humanReadableFileSize, style: .textCellSupportingText)
        updateAccessibilityLabel()
    }

    func updateAccessibilityLabel() {
        accessibilityLabel = [ iconView.accessibilityLabel, nameLabel.text, sizeLabel.text ]
            .joined(separator: ", ")
    }
}
