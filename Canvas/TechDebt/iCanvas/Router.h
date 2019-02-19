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
    
    

@import UIKit;

@class CKCanvasAPI, CBIViewModel;

typedef UIViewController *(^RouteHandler)(NSDictionary<NSString *, id> *params, id sender);
typedef void(^DispatchHandler)(UIViewController *viewController);
typedef void(^FallbackHandler)(NSURL *url, UIViewController *sender);
typedef void(^ControllerHandler)(UIViewController *controller);

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

#pragma marks - Removing Routes
- (void)removeRoute:(NSString *)route;

#pragma marks - Dispatching
- (UIViewController *)controllerForHandlingURL:(NSURL *)url;
- (void)controllerForHandlingURL:(NSURL *)url handler:(ControllerHandler)handler;

/**
 @return the view controller that was routed to
 */
- (UIViewController *)routeFromController:(UIViewController *)sourceController toURL:(NSURL *)url;
- (UIViewController *)routeFromController:(UIViewController *)sourceController toURL:(NSURL *)url withOptions:(NSDictionary *)options;

/**
 @return the view controller that was routed to
 */
- (UIViewController *)routeFromController:(UIViewController *)sourceController toViewModel:(CBIViewModel *)viewModel;

- (void)openCanvasURL:(NSURL *)url withOptions:(NSDictionary *)options;

@end
