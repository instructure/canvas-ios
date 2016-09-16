//
//  CBISubmissionAnnotationPreviewHelper.m
//  iCanvas
//
//  Created by Ben Kraus on 11/11/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

#import "CBISubmissionAnnotationPreviewHelper.h"
#import "WebBrowserViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
@import CanvasKit;
@import CanvasKeymaster;

@import PSPDFKit;
@import AnnotationKit;

@implementation CBISubmissionAnnotationPreviewHelper

+ (BOOL)filePreviewableWithAnnotations:(CKIFile *)file {
    NSString *previewURLPath = [file.previewURLPath substringFromIndex:1];
    if ([previewURLPath containsString:@"api/v1/canvadoc_session"]) {
        return YES;
    } else if ([self boxRenderableAttachment:file]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)boxRenderableAttachment:(CKIFile *)attachment {
    NSArray *acceptableFileTypes = @[@"doc", @"docx", @"pdf"];
    NSString *fileExtension = attachment.name.pathExtension;
    return [acceptableFileTypes containsObject:fileExtension];
}

+ (void)loadAnnotationPreviewForFile:(CKIFile *)file fromViewController:(UIViewController *)presentingViewController {
    NSString *previewURLPath = [file.previewURLPath substringFromIndex:1];
    if ([self filePreviewableWithAnnotations:file]) {
        [SVProgressHUD show];
        
        // redirect hackyness
        CKIClient *baseClient = [[TheKeymaster currentClient] copy];
        [baseClient setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [baseClient setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [baseClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [TheKeymaster currentClient].accessToken] forHTTPHeaderField:@"Authorization"];
        // capture the redirect URL and display it \o/
        [baseClient setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
            if ([previewURLPath containsString:@"api/v1/canvadoc_session"]) {
                // YAY, let's do the new awesome annotations
                
                NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
                
                // the url looks like this: https://canvadocs-edge.insops.net/1/sessions/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjIjoxNDQ2MTM5NTY4MjgxLCJkIjoiTlA4UUdIbFAtTUNoSW9wLTdJVjY4WTFTUnh1QkRNIiwiZSI6MTQ0NjE0MzE2OCwiYSI6eyJjIjoiZGVmYXVsdCIsInAiOiJyZWFkd3JpdGUiLCJ1IjoxMDAwMDAwNjExMjAyMCwibiI6ImJrcmF1cyt0ZWFjaEBpbnN0cnVjdHVyZS5jb20iLCJyIjoiIn0sImlhdCI6MTQ0NjEzOTU2OH0.zLTb6VN4yyh-GGBhOXuflNYFwzz0tv5ucDOiBYuz3vE/view?theme=dark
                // so we need to knock off the query params and the /view from the path
                components.query = nil;
                components.path = components.path.stringByDeletingLastPathComponent;
                
                NSURL *goodURL = components.URL;
                if (goodURL != nil) {
                    // NEW ANNOTATIONS FTW!
                    [DocumentPresenter loadPDFViewController:goodURL completed:^(UIViewController *pdfViewController, NSError *error) {
                        [SVProgressHUD dismiss];
                        if (pdfViewController != nil) {
                            [presentingViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:pdfViewController] animated:YES completion:nil];
                        }
                    }];
                } else {
                    // WTF Happened!
                }
                return nil;
            } else {
                // Sigh, this doc is older and can't be supported with the new stuff
                UINavigationController *controller = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
                WebBrowserViewController *browser = controller.viewControllers[0];
                browser.request = request;
                [presentingViewController presentViewController:controller animated:YES completion:^{
                    [SVProgressHUD dismiss];
                }];
                return nil;
            }
        }];
        
        [baseClient GET:previewURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            // successful load doesn't actually mean anything except the redirect happened
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode != 302) { // Always hits here when redirecting, so ignore that
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't Load Submission", @"error title for failure to load a file submission") message:NSLocalizedString(@"We had a problem loading the submission. Please try again later.", @"error message for failure to load a file submission") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

@end
