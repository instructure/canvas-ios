//
//  CKOAuthWebLoginViewController.m
//  CanvasKit
//
//  Created by Stephen Lottermoser on 11/4/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKOAuthWebLoginViewController.h"
#import "CKUser.h"
#import "CKCanvasAPI.h"
#import "NSString+CKAdditions.h"
#import "CKStylingButton.h"
#import "CKAlertViewWithBlocks.h"
#import "CKCanvasURLConnection.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+CanvasKit1.h"

@interface CKOAuthWebLoginViewController ()

@property (copy, readwrite) NSString *accessToken;
@property (strong, readwrite) CKUser *user;
@property (copy) NSURL *originalURL;
    
@end

@implementation CKOAuthWebLoginViewController

#pragma mark - View lifecycle

- (id)init {
    // There's an HD version of this storyboard too, but for the web login controller, both just have
    // a single large webview, so it doesn't matter much.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CKOAuthLogin" bundle:[NSBundle bundleForClass:[self class]]];
    self = [storyboard instantiateViewControllerWithIdentifier:@"CKOAuthWebLoginController"];
    return self;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    
    [self.canvasAPI verifyMobileAppWithBlock:^(NSError *error, BOOL isFinalValue) {
        if (isFinalValue) {
            if (error) {
                // Catch the errors here. There are two error types for now: If the response was NO, it is passed as an error. The other is an unknown error.
                NSLog(@"Server / Mobile App verification failed with error: %@",error);
                
                NSString *alertMessage = NSLocalizedString(@"An unknown error occurred",nil);
                
                if ([[error domain] isEqualToString:CKCanvasErrorDomain]) {
                    if (CKCanvasErrorCodeMobileVerifyGeneralNotAuthorized == [error code]) {
                        alertMessage = NSLocalizedString(@"This app is not authorized for use.",nil);
                    }
                    else if (CKCanvasErrorCodeMobileVerifyDomainNotAuthorized == [error code]) {
                        alertMessage = NSLocalizedString(@"The server you entered is not authorized for this app.",nil);
                    }
                    else if (CKCanvasErrorCodeMobileVerifyUserAgentUnknown == [error code]) {
                        alertMessage = NSLocalizedString(@"The user agent for this app is unauthorized.",nil);
                    }
                    else {
                        alertMessage = NSLocalizedString(@"We were unable to verify the server for use with this app.",nil);
                    }
                }
                
                UIAlertView *verificationAlert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
                [verificationAlert show];
                
                return;
            }
            else {
                NSURL *theBaseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", self.canvasAPI.apiProtocol, self.canvasAPI.hostname]];
                self.originalURL = theBaseURL;
                self.baseURL = theBaseURL;
                self.clientID = self.canvasAPI.clientId;
                self.clientSecret = self.canvasAPI.clientSecret;
                
                [self loadOuthLoginScreen];
            }
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    UIImage *image = [UIImage canvasKit1ImageNamed:@"icon_back_light.png"];
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    backButton.imageInsets = UIEdgeInsetsMake(4, 0, 4, 10);

    self.navigationItem.leftBarButtonItem = backButton;
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)loadOuthLoginScreen
{
    NSString *urlWithParameters = [NSString stringWithFormat:@"/login/oauth2/auth?client_id=%@&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&mobile=1", self.clientID];

    if (self.forceCanvasLogin) {
        urlWithParameters = [urlWithParameters stringByAppendingString:@"&canvas_login=1"];
    }
    
    NSURL *requestURL = [NSURL URLWithString:urlWithParameters relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setValue:[CKCanvasURLConnection CKUserAgentString] forHTTPHeaderField:@"User-Agent"];
    
    if (self.forceCanvasLogin) {
        [request addValue:@"canvas_sa_delegated=\"1\"" forHTTPHeaderField:@"Cookie"];
    }

    self.title = self.baseURL.host;
    [self.webView loadRequest:request];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] path] isEqualToString:@"/login/oauth2/auth"]) {
        NSString *query = request.URL.query;
        NSDictionary *parameters = [query queryParameters];
        
        if (parameters[@"code"]) {
            NSURL *tokenURL = [NSURL URLWithString:@"/login/oauth2/token" relativeToURL:self.originalURL];
            NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:tokenURL];
            postRequest.HTTPMethod = @"POST";
            postRequest.HTTPBody = [[NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@",
                                     self.clientID, self.clientSecret, parameters[@"code"]]
                                    dataUsingEncoding:NSUTF8StringEncoding];
            
            [NSURLConnection sendAsynchronousRequest:postRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *aResponse, NSData *data, NSError *error) {
                 NSHTTPURLResponse *response = (NSHTTPURLResponse *)aResponse;
                 if (error){
                     self.finishedBlock(error, nil, nil);
                     return;
                 }
                 int statusCode = [((NSHTTPURLResponse *)response) statusCode];
                 if (statusCode < 200 || statusCode >= 300) {
                     error = [[NSError alloc] initWithDomain:CKCanvasErrorDomain code:statusCode userInfo:nil];
                     self.finishedBlock(error, nil, nil);
                 }
                 else if ([response statusCode] != 200) {
                     error = [NSError errorWithDomain:@"HTTP" code:[response statusCode] userInfo:nil];
                     self.finishedBlock(error, nil, nil);
                 }
                 else {
                     NSError *jsonError;
                     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:&jsonError];
                     self.accessToken = dict[@"access_token"];
                     
                     // Load the user. We will set the immediate information that comes back with the OAuth response. The app may choose to get the more detailed profile info via the API.
                     self.user = [[CKUser alloc] initWithInfo:dict[@"user"]];
                     
                     self.finishedBlock(dict == nil ? jsonError : nil, self.accessToken, self.user);
                     
                 }
                 if (!error) {
                     self.finishedBlock = nil;
                     [self dismissViewControllerAnimated:YES completion:NULL];
                 }
             }];
            
            return NO;
        }
        else if (parameters[@"error"]) {
            NSLog(@"An OAuth Error happened. User might have canceled.");
            [self goBack];
            // Clear out the cookies, or you can get stuck if you logged in with valid credentials but then
            // deny the oauth access.
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.baseURL];
            for (NSHTTPCookie *cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
            return NO;
        }
    }
    
    // check if host is valid 
    // for now if the host is invalid, canvas redirects to canvas.instructure.com/login
    if (![self.baseURL.host isEqualToString:@"canvas.instructure.com"] && [request.URL.absoluteString isEqualToString:@"https://canvas.instructure.com/login"]) {
        NSString *baseMessage = NSLocalizedString(@"%@ is not a valid host", @"%@ is the token where the host name goes. Error message that the host doesn't exist.");
        CKAlertViewWithBlocks *alert = [[CKAlertViewWithBlocks alloc] initWithTitle:NSLocalizedString(@"Error", @"Title of alert box") 
                                                                            message:[[NSString alloc] initWithFormat:baseMessage, self.baseURL.host]];
        [alert addButtonWithTitle:NSLocalizedString(@"OK",nil) handler:^{
            [self goBack];
        }];
        [alert show];
    }
    return YES;
}


- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Problem", @"Error message title")
                                                        message:NSLocalizedString(@"An unknown error occurred", @"Error message text")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:nil];
    if (error) {
        if (error.code == 102) {
            // ignore the error
            
            // 102 is a frame load error that occurs when we've logged in successfully
            return;
        }
        
        alertView.message = [error localizedDescription];
        NSLog(@"An error occurred during the login process (%@): %@", [[aWebView request] URL], [error localizedDescription]);
    }
    
    [alertView show];
}

#pragma mark - navigation actions

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
