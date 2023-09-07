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
import mobile_offline_downloader_ios

public class FileListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!

    lazy var addButton = UIBarButtonItem(image: .addSolid, style: .plain, target: self, action: #selector(addItem))
    lazy var editButton = UIBarButtonItem(
        title: NSLocalizedString("Edit", bundle: .core, comment: ""), style: .plain,
        target: self, action: #selector(edit)
    )

    let batchID = UUID.string
    public var color: UIColor?
    let env = AppEnvironment.shared
    public let titleSubtitleView = TitleSubtitleView.create()
    var context = Context.currentUser
    lazy var filePicker = FilePicker(delegate: self)
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
    lazy var folder = env.subscribe(GetFolderByPath(context: context, path: path)) { [weak self] in
        self?.updateFolder()
    }
    var items: Store<GetFolderItems>?
    lazy var group = context.contextType == .group ? env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    } : nil
    lazy var uploads = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.updateUploads()
    }

    private var offlineFileInteractor: OfflineFileInteractor?

    public static func create(context: Context, path: String? = nil, offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive()) -> FileListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.path = path ?? ""
        controller.offlineFileInteractor = offlineFileInteractor
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Files", bundle: .core, comment: ""))

        addButton.accessibilityIdentifier = "FileList.addButton"
        addButton.accessibilityLabel = NSLocalizedString("Add Item", bundle: .core, comment: "")

        editButton.accessibilityIdentifier = "FileList.editButton"

        emptyImageView.image = UIImage(named: Panda.FilePicker.name, in: .core, compatibleWith: nil)
        emptyMessageLabel.text = NSLocalizedString("This folder is empty.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Files", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading files. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        refreshControl.color = nil

        searchBar.placeholder = NSLocalizedString("Search", bundle: .core, comment: "")
        searchBar.backgroundColor = .backgroundLightest

        tableView.backgroundColor = .backgroundLightest
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.tableView.contentOffset.y = self.searchBar.frame.height
        }

        colors.refresh()
        course?.refresh()
        group?.refresh()
        folder.refresh()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        if context.contextType == .user {
            navigationController?.navigationBar.useGlobalNavStyle()
        } else {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    func updateNavBar() {
        if let course = course?.first {
            updateNavBar(subtitle: course.name, color: course.color)
        } else if let group = group?.first {
            updateNavBar(subtitle: group.name, color: group.color)
        } else if context.contextType == .user {
            color = .textDark
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
        let title = (path.isEmpty ? nil : folder.first?.name) ?? NSLocalizedString("Files", bundle: .core, comment: "")
        setupTitleViewInNavbar(title: title)
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
        tableView.reloadData()
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
        let title = String.localizedStringWithFormat(NSLocalizedString("Are you sure you want to delete %@?", comment: ""), name)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("Delete", bundle: .core, comment: ""), style: .default, handler: handler))
        env.router.show(alert, from: self, options: .modal())
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
            emptyMessageLabel.text = NSLocalizedString("We couldn’t find any files like that.", bundle: .core, comment: "")
            emptyTitleLabel.text = NSLocalizedString("No Results", bundle: .core, comment: "")
        } else {
            emptyImageView.image = UIImage(named: Panda.FilePicker.name, in: .core, compatibleWith: nil)
            emptyMessageLabel.text = NSLocalizedString("This folder is empty.", bundle: .core, comment: "")
            emptyTitleLabel.text = NSLocalizedString("No Files", bundle: .core, comment: "")
        }
        search()
    }

    func search() {
        results = []
        guard let searchTerm = searchTerm else { return tableView.reloadData() }
        loadingView.isHidden = false
        emptyView.isHidden = true
        errorView.isHidden = true
        tableView.reloadData()
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
        tableView.reloadData()
    }

    @objc
    private func didBecomeActiveNotification() {
        tableView.reloadData()
    }
}

extension FileListViewController: FilePickerDelegate {
    func updateNavButtons() {
        navigationItem.rightBarButtonItems = [
            canAddItem ? addButton : nil,
            canEditFolder ? editButton : nil,
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

    @objc func addItem() {
        let sheet = BottomSheetPickerViewController.create()
        sheet.addAction(
            image: .folderLine,
            title: NSLocalizedString("Add Folder", bundle: .core, comment: ""),
            accessibilityIdentifier: "FileList.addFolderButton"
        ) { [weak self] in
            self?.addFolder()
        }
        sheet.addAction(
            image: .addDocumentLine,
            title: NSLocalizedString("Add File", bundle: .core, comment: ""),
            accessibilityIdentifier: "FileList.addFileButton"
        ) { [weak self] in
            guard let self = self else { return }
            self.filePicker.pick(from: self)
        }
        env.router.show(sheet, from: self, options: .modal())
    }

    func addFolder() {
        let prompt = UIAlertController(title: NSLocalizedString("Add Folder", bundle: .core, comment: ""), message: nil, preferredStyle: .alert)
        prompt.addTextField { field in
            field.placeholder = NSLocalizedString("Name", bundle: .core, comment: "")
            field.accessibilityLabel = NSLocalizedString("Folder Name", bundle: .core, comment: "")
        }
        prompt.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        prompt.addAction(AlertAction(NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { [weak self] _ in
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
        guard !completes.isEmpty else { return tableView.reloadData() }

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

extension FileListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return uploads.count
        case 1: return results.count
        default: return searchTerm != nil ? 0 : items?.count ?? 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isOffline = offlineFileInteractor?.isOffline == true
        if indexPath.section == 0 {
            let cell: FileListUploadCell = tableView.dequeue(for: indexPath)
            cell.update(uploads[indexPath.row])
            return cell
        }

        let cell: FileListCell = tableView.dequeue(for: indexPath)
        cell.accessibilityIdentifier = "FileList.\(indexPath.row)"
        cell.backgroundColor = .backgroundLightest
        if indexPath.section == 1 {
            let result: APIFile? = results[indexPath.row]
            let isAvailable = offlineFileInteractor?.isItemAvailableOffline(courseID: course?.first?.id, fileID: result?.id.value) == true
            cell.update(result: result, isOffline: isOffline, isAvailable: isAvailable)
        } else {
            let item: FolderItem? = items?[indexPath.row]
            let isAvailable = offlineFileInteractor?.isItemAvailableOffline(courseID: course?.first?.id, fileID: item?.id) == true
            cell.update(item: item, course: course?.first, color: color, isOffline: isOffline, isAvailable: isAvailable)
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0, let file = uploads[indexPath.row] {
            filePicker.showOptions(for: file, from: self)
        } else if indexPath.section == 1 {
            let id = results[indexPath.row].id.value
            routeIfAvailable(fileID: id, indexPath: indexPath)
        } else if let id = items?[indexPath.row]?.file?.id {
            routeIfAvailable(fileID: id, indexPath: indexPath)
        } else if let path = items?[indexPath.row]?.folder?.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            env.router.route(to: "/\(context.pathComponent)/files/folder/\(path)", from: self, options: .push)
        }
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard indexPath.section > 0,
              folder.first?.forSubmissions == false,
              context == .currentUser || course?.first?.hasTeacherEnrollment == true else {
            return nil
        }

        if indexPath.section == 2, let folder = items?[indexPath.row]?.folder,
           folder.forSubmissions || folder.filesCount > 0 {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", bundle: .core, comment: "")) { [weak self] _, _, completion in
            guard let self = self else { return }
            if indexPath.section == 1 {
                let file = self.results[indexPath.row]
                self.delete(fileID: file.id.value, fileName: file.display_name)
            } else if let file = self.items?[indexPath.row]?.file, let fileID = file.id, let fileName = file.displayName {
                self.delete(fileID: fileID, fileName: fileName)
            } else if let folder = self.items?[indexPath.row]?.folder {
                self.delete(folder: folder)
            }
            completion(true)
        }

        deleteAction.backgroundColor = .backgroundDanger

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    private func routeIfAvailable(fileID: String, indexPath: IndexPath) {
        guard offlineFileInteractor?.isItemAvailableOffline(courseID: course?.first?.id, fileID: fileID) == true else {
            UIAlertController.showItemNotAvailableInOfflineAlert()
            tableView.deselectRow(at: indexPath, animated: true)
            return
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
            NSLocalizedString("Uploading %@ of %@", bundle: .core, comment: "Uploading X KB of Y MB"),
            $0.bytesSent.humanReadableFileSize,
            $0.size.humanReadableFileSize
        ) }
        sizeLabel.setText(sizeText, style: .textCellSupportingText)
        sizeLabel.textColor = file?.uploadError == nil ? .textDark : .textDanger
    }
}

class FileListCell: UITableViewCell {

    @Injected(\.reachability) var reachability: ReachabilityProvider
    private let storageManager = OfflineStorageManager.shared
    private let downloadsManager = OfflineDownloadsManager.shared

    var downloadButtonHelper = DownloadStatusProvider()
    var file: File?
    var course: Course?

    @IBOutlet weak var iconView: AccessIconView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    private var fileID: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        file = nil
        course = nil
        removeDownloadButton()
    }

    func update(item: FolderItem?, course: Course?, color: UIColor?, isOffline: Bool, isAvailable: Bool) {
        fileID = item?.id
        setCellState(isAvailable: isAvailable, isUserInteractionEnabled: true)
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        nameLabel.setText(item?.name, style: .textCellTitle)
        if let folder = item?.folder {
            iconView.icon = .folderSolid
            iconView.setState(locked: folder.locked, hidden: folder.hidden, unlockAt: folder.unlockAt, lockAt: folder.lockAt)
            let sizeText = String.localizedStringWithFormat(
                NSLocalizedString("d_items", bundle: .core, comment: ""),
                folder.filesCount + folder.foldersCount
            )
            sizeLabel.setText(sizeText, style: .textCellSupportingText)
            updateAccessibilityLabel()
            return
        }
        let file = item?.file
        self.file = file
        self.course = course
        if !isOffline, let url = file?.thumbnailURL, let c = file?.createdAt, Clock.now.timeIntervalSince(c) > 3600 {
            iconView.load(url: url)
        } else {
            iconView.icon = file?.icon
        }
        iconView.setState(locked: file?.locked, hidden: file?.hidden, unlockAt: file?.unlockAt, lockAt: file?.lockAt)
        sizeLabel.setText(file?.size.humanReadableFileSize, style: .textCellSupportingText)
        updateAccessibilityLabel()
        prepareForDownload()
    }

    func update(result: APIFile?, isOffline: Bool, isAvailable: Bool) {
        fileID = result?.id.value
        setCellState(isAvailable: isAvailable, isUserInteractionEnabled: true)
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
            .compactMap { $0 }.joined(separator: ", ")
    }
}
