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
    
    

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+AnalyticsTracking.h"
#import <CanvasKit1/CKActionSheetWithBlocks.h>
#import <CanvasKit1/NSFileManager+CKAdditions.h>
#import "UIAlertController+TechDebt.h"
#import "ReceivedFilesViewController.h"
#import "DocumentLibraryView.h"

#import "CBIDropbox.h"

#import "CBILog.h"

@interface ReceivedFilesViewController () <DocumentLibraryViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *libraryContainer;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleSelectionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (assign, nonatomic) int numberOfImportOptions;

@property (strong) DocumentLibraryView *libraryView;
@end

@implementation ReceivedFilesViewController {
    id didBecomeActiveObserver;
    NSURL *photoSelectionURL;
    NSURL *dropboxSelectionURL;
    UIPopoverController *popoverController;
}
@synthesize libraryContainer;
@synthesize filenameLabel;
@synthesize submitButton;
@synthesize toolbar;
@synthesize navigationItem;
@synthesize toggleSelectionButton;
@synthesize trashButton;
@synthesize libraryView;
@synthesize onSubmitBlock;
@synthesize numberOfImportOptions;


static NSURL *receivedFilesFolder() {
    NSFileManager *fileManager = [NSFileManager new];
    NSURL *documentsURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:NULL];
    
    NSURL *oldLibraryFolder = [documentsURL URLByAppendingPathComponent:@"SubmissionLibrary"];
    NSURL *libraryFolder = [documentsURL URLByAppendingPathComponent:@"ReceivedFiles"];
    
    // Move the old library, or create a new one
    if (![fileManager moveItemAtURL:oldLibraryFolder toURL:libraryFolder error:NULL]) {
        [fileManager createDirectoryAtURL:libraryFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return libraryFolder;
}

+ (BOOL)addToReceivedFiles:(NSURL *)url error:(NSError **)error {
    if (![[url scheme] isEqualToString:@"file"]) {
        return NO;
    }
    
    NSURL *newURL = [self addItemAtURLToReceivedFiles:url error:error];
    
    if (newURL) {
        NSString *title = NSLocalizedString(@"File received", nil);
        NSString *messageTemplate = NSLocalizedString(@"'%@' is now ready to submit to assignments", @"%@ will be replaced by the filename");
        NSString *message = [NSString stringWithFormat:messageTemplate, url.lastPathComponent];
        [UIAlertController showAlertWithTitle:title message:message];
        [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    }

    return newURL != nil;
}

+ (NSURL *)addItemAtURLToReceivedFiles:(NSURL *)url error:(NSError **)error {
    NSURL *directory = receivedFilesFolder();
    NSString *lastPathComponent = url.lastPathComponent;
    NSURL *destination = nil;
    if (lastPathComponent) {
        destination = [directory URLByAppendingPathComponent:lastPathComponent];
        
        NSFileManager *fileManager = [NSFileManager new];
        destination = [fileManager uniqueFileURLWithURL:destination];
        
        if (![fileManager copyItemAtURL:url toURL:destination error:error]) {
            return nil;
        }
    }
    
    return destination;
}

+ (instancetype)presentReceivedFilesViewControllerFrom:(UIViewController *)presenter {
    if (presenter == nil) {
        return nil;
    }
    UINavigationController *nav = (UINavigationController *)[[UIStoryboard storyboardWithName:@"ReceivedFilesViewController" bundle:[NSBundle bundleForClass:[ReceivedFilesViewController class]]] instantiateInitialViewController];
    nav.view.backgroundColor = UIColor.whiteColor;
    
    [presenter presentViewController:nav animated:YES completion:nil];
    
    return nav.viewControllers[0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_submitButtonTitle) {
        _submitButtonTitle = submitButton.title;
    }
    
    self.numberOfImportOptions = 1;
    
    libraryView = [[DocumentLibraryView alloc] initWithFrame:libraryContainer.bounds];
    libraryView.translatesAutoresizingMaskIntoConstraints = NO;
    libraryView.delegate = self;
    [self populateLibraryViewItems];
    libraryView.noItemsHelpString = NSLocalizedString(@"You have no files available for upload. To add files from other apps, find a file in another app, then find the \"Open In\" button to open it in Canvas. You can also tap and hold on attachments in the Mail app to open them in Canvas.", @"An explanation of how to transfer files to the Canvas app.");
    [libraryContainer addSubview:libraryView];
    [NSLayoutConstraint activateConstraints:@[
        [libraryView.topAnchor constraintEqualToAnchor:libraryContainer.topAnchor],
        [libraryView.bottomAnchor constraintEqualToAnchor:libraryContainer.bottomAnchor],
        [libraryView.leftAnchor constraintEqualToAnchor:libraryContainer.leftAnchor],
        [libraryView.rightAnchor constraintEqualToAnchor:libraryContainer.rightAnchor],
    ]];

    self.navigationItem.title = NSLocalizedString(@"Select file(s)", @"Title for a file picker window");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    toggleSelectionButton.accessibilityTraits = UIAccessibilityTraitButton;
    toggleSelectionButton.accessibilityLabel = NSLocalizedString(@"Select or deselect", nil);
    toggleSelectionButton.accessibilityHint = NSLocalizedString(@"Toggles selection of current item", nil);
    
    [self updateSubmitButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    didBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification *note) {
                                                                                [self populateLibraryViewItems];
                                                                            }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (didBecomeActiveObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:didBecomeActiveObserver];
        didBecomeActiveObserver = nil;
    }
}

- (BOOL)prefersStatusBarHidden {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)setSubmitButtonTitle:(NSString *)submitButtonTitle {
    _submitButtonTitle = [submitButtonTitle copy];
    [self updateSubmitButton];
}


- (void)populateLibraryViewItems {
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSURL *libraryURL = receivedFilesFolder();
    
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtURL:libraryURL
                                      includingPropertiesForKeys:@[NSURLCreationDateKey]
                                                         options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                    errorHandler:NULL];
    
    NSMutableArray *items = [NSMutableArray new];
    for (NSURL *url in enumerator) {
        NSNumber *isDir;
        [url getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:NULL];
        if ([isDir boolValue] == NO) {
            [items addObject:url];
        }
    }
    [items sortUsingComparator:^NSComparisonResult(NSURL * obj1, NSURL *obj2) {
        NSDate *date1, *date2;
       
        // If any of these error, we'll just get nil, which won't break any comparisons.
        [obj1 getResourceValue:&date1 forKey:NSURLCreationDateKey error:NULL];
        [obj2 getResourceValue:&date2 forKey:NSURLCreationDateKey error:NULL];

        // Compare in reverse to get newest items first
        return [date2 compare:date1];
    }];
    
    
    dropboxSelectionURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"dropbox-logos_dropbox-vertical-blue" withExtension:@"png"];
    // Only show the dropbox option if the dropbox application is installed
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"dbapi-1://"]]) {
        // Adding this at zero first will make it second when adding another item at 0
        [items insertObject:dropboxSelectionURL atIndex:0];
        [self resetFilenameLabelWithItem:libraryView.frontItem];
        
        self.numberOfImportOptions++;
    }

    photoSelectionURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"icon_video_large" withExtension:@"png"];
    [items insertObject:photoSelectionURL atIndex:0];
    [self resetFilenameLabelWithItem:libraryView.frontItem];
    
    libraryView.itemURLs = items;
    [libraryView setNeedsLayout];
}

- (IBAction)dismiss:(id)sender {
    
    DDLogVerbose(@"dismissPressed");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetFilenameLabelWithItem:(NSURL *)item {
    if (item == nil) {
        filenameLabel.text = @"";
    }
    if ([item isEqual:photoSelectionURL]) {
        filenameLabel.text = NSLocalizedString(@"Import from camera", nil);
    }
    else if ([item isEqual:dropboxSelectionURL]) {
        filenameLabel.text = NSLocalizedString(@"Import from Dropbox", nil);
    }
    else {
        filenameLabel.text = [item.lastPathComponent stringByDeletingPathExtension];
    }
}

- (BOOL)libraryViewShouldShowHelpString:(DocumentLibraryView *)aLibraryView {
    return libraryView.itemURLs.count == self.numberOfImportOptions;
}

- (void)libraryView:(DocumentLibraryView *)libraryView didChangeFrontItem:(NSURL *)item {
    if (!item || [item isEqual:photoSelectionURL] || [item isEqual:dropboxSelectionURL]) {
        self.trashButton.enabled = NO;
    } else {
        self.trashButton.enabled = YES;
    }
    [self resetFilenameLabelWithItem:item];
}

- (void)libraryView:(DocumentLibraryView *)libraryView didTapFrontItem:(NSURL *)item {
    [self tappedSelectButton:nil];
}

- (UIViewController *)libraryViewControllerForPresentingFullScreenPreview:(DocumentLibraryView *)libraryView {
    return self;
}

- (IBAction)tappedSelectButton:(id)sender {
    NSURL *selectedItem = self.libraryView.frontItem;
    if (!selectedItem) {
        return;
    }
    
    if ([selectedItem isEqual:photoSelectionURL]) {
        [self tappedCameraURL];
        return;
    }
    else if ([selectedItem isEqual:dropboxSelectionURL]) {
        [self tappedDropboxURL];
        return;
    }
    
    
    if ([libraryView.selectedItems containsObject:selectedItem]) {
        [libraryView setSelected:NO forItem:selectedItem];
    }
    else {
        [libraryView setSelected:YES forItem:selectedItem];
    }
    
    [self updateSubmitButton];
}

- (void)updateSubmitButton
{
    NSString *formatString = NSLocalizedString(@"%@ (%d)", @"Button to submit files to an assignment");
    submitButton.title = [NSString stringWithFormat:formatString, _submitButtonTitle, libraryView.selectedItems.count];
    if (libraryView.selectedItems.count == 0) {
        submitButton.enabled = NO;
    }
    else {
        submitButton.enabled = YES;
    }
}

- (IBAction)tappedSubmitButton:(id)sender {
    if (self.onSubmitBlock) {
        NSArray *selectedURLs = libraryView.selectedItems;
        self.onSubmitBlock(selectedURLs);
    }
}

- (IBAction)tappedTrashButton:(UIBarButtonItem *)sender {
    NSURL *selectedItem = self.libraryView.frontItem;
    if (selectedItem == nil) {
        return;
    }
    
    sender.enabled = NO;
    
    CKActionSheetWithBlocks *actionSheet = [[CKActionSheetWithBlocks alloc] initWithTitle:
                                            NSLocalizedString(@"Remove this file?",
                                                              @"Button title for confirming a file deletion")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Remove", @"Confirmation for removing a file")
                            handler:^{
                                DDLogVerbose(@"fileRemovedAtURL : %@", [selectedItem absoluteString]);
                                NSFileManager *fileManager = [NSFileManager new];
                                NSError *error;
                                if ([fileManager removeItemAtURL:selectedItem error:&error]) {
                                    [libraryView removeItem:selectedItem];
                                    [self updateSubmitButton];
                                }
                                else {
                                    [UIAlertController showAlertWithTitle:nil message:[error localizedDescription]];
                                }
                            }];
    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title")];
    
    actionSheet.dismissalBlock = ^{
        sender.enabled = YES;
    };
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    DDLogVerbose(@"showImagePickerWithSourceType : %zd", sourceType);
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = NO;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        [popoverController presentPopoverFromRect:filenameLabel.bounds inView:filenameLabel permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)showVideoRecorderWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    DDLogVerbose(@"showVideoRecorderWithSourceType : %zd", sourceType);
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = NO;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)tappedCameraURL {
    DDLogVerbose(@"tappedCameraURL");
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (cameraAvailable) {
        CKActionSheetWithBlocks *actionSheet = [[CKActionSheetWithBlocks alloc] initWithTitle:nil];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo or Video...", nil) handler:^{
            DDLogVerbose(@"cameraSourceSelected");
            [self showVideoRecorderWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose from Library...", nil) handler:^{
            DDLogVerbose(@"librarySourceSelected");
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            DDLogVerbose(@"cancelSelected");
            [actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        }
        
        [actionSheet showFromRect:filenameLabel.bounds inView:filenameLabel animated:YES];
    }
    else {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)tappedDropboxURL
{
    [CBIDropbox chooseFileWithLinkType:DBChooserLinkTypeDirect
                    fromViewController:self
                       completionBlock:^(NSArray *results) {
                           [results enumerateObjectsUsingBlock:^(DBChooserResult *obj, NSUInteger idx, BOOL *stop) {
                               NSLog(@"%@", obj.name);
                               
                               NSError *tempDirectoryCreationError = nil;
                               // Create temporary directory
                               NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
                               [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&tempDirectoryCreationError];
                               
                               NSURL *tempFileURL = [directoryURL URLByAppendingPathComponent:obj.name];

                               NSData *data = [NSData dataWithContentsOfURL:obj.link];
                               NSError *writeError = nil;
                               [data writeToURL:tempFileURL options:NSDataWritingAtomic error:&writeError];
                               
                               
                               // Create local copy at receivedFiles
                               NSURL *fileURL = [[self class] addItemAtURLToReceivedFiles:tempFileURL error:NULL];
                               if (fileURL) {
                                   [libraryView addItem:fileURL];
                               }
                               
                               // Cleanup temp file now that it has been added to the uploads available
                               NSError *cleanupError = nil;
                               [[NSFileManager defaultManager] removeItemAtURL:tempFileURL error:&cleanupError];
                
                           }];
                           
                       } cancelledBlock:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *fileURL = nil;
    
    NSString *selectionType = info[UIImagePickerControllerMediaType];
    if ([selectionType isEqualToString:(__bridge id)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        
        NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMMMd" options:0 locale:[NSLocale currentLocale]];
        formatter.timeStyle = NSDateFormatterMediumStyle;
        NSString *todayString = [formatter stringFromDate:[NSDate new]];
        fileURL = [tempDir URLByAppendingPathComponent:[NSString stringWithFormat:@"photo (%@).jpg", todayString]];
        fileURL = [[NSFileManager defaultManager] uniqueFileURLWithURL:fileURL];
        [imageData writeToURL:fileURL atomically:NO];
        
    }
    else if ([selectionType isEqualToString:(__bridge id)kUTTypeMovie] ||
             [selectionType isEqualToString:(__bridge id)kUTTypeVideo]) {
        fileURL = info[UIImagePickerControllerMediaURL];
    }
    fileURL = [[self class] addItemAtURLToReceivedFiles:fileURL error:NULL];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [popoverController dismissPopoverAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    if (fileURL) {
        [libraryView addItem:fileURL];
    }
}

@end
