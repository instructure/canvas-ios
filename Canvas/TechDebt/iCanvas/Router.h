//
//  Router.h
//  iCanvas
//
//  Created by Jason Larsen on 4/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import UIKit;

@class CKCanvasAPI, CBIViewModel;

typedef UIViewController *(^RouteHandler)(NSDictionary<NSString *, id> *params, id sender);
typedef void(^DispatchHandler)(UIViewController *viewController);
typedef void(^FallbackHandler)(NSURL *url, UIViewController *sender);

@interface UIViewController (Routing)
- (void)applyRoutingParameters:(NSDictionary *)params;
@end

@interface Router : NSObject
@property (copy) FallbackHandler fallbackHandler;
+ (Router *)sharedRouter;

#pragma marks - Defining Routes
- (void)addRoute:(NSString *)route handler:(RouteHandler)handler;
- (void)addRoute:(NSString *)route forControllerClass:(Class)controllerClass;
- (void)addRoutesWithDictionary:(NSDictionary *)routes;

#pragma marks - Dispatching
- (UIViewController *)controllerForHandlingURL:(NSURL *)url;

/**
 @return the view controller that was routed to
 */
- (UIViewController *)routeFromController:(UIViewController *)sourceController toURL:(NSURL *)url;

/**
 @return the view controller that was routed to
 */
- (UIViewController *)routeFromController:(UIViewController *)sourceController toViewModel:(CBIViewModel *)viewModel;

- (void)openCanvasURL:(NSURL *)url;

@end
