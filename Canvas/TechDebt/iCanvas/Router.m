//
//  Router.m
//  iCanvas
//
//  Created by Jason Larsen on 4/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <objc/runtime.h>

#import "Router.h"
#import "Router+Routes.h"
#import "CBIViewModel.h"
#import "CBISyllabusViewModel.h"
#import "UIViewController+Transitions.h"
#import <CanvasKit1/NSString+CKAdditions.h>
#import <CanvasKit1/CKCanvasAPI.h>
#import <CanvasKit1/CKContextInfo.h>
#import "CKCanvasAPI+CurrentAPI.h"

#import "CBISplitViewController.h"
@import CanvasKit;
@import CanvasKeymaster;

@interface Router ()
@property NSMutableDictionary *routes;
@property NSNumberFormatter *numberFormatter;
@end

@implementation UIViewController (Routing)

- (void)applyRoutingParameters:(NSDictionary *)params {
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        NSString *selectorString;
        
        objc_property_t prop = class_getProperty([self class], [key UTF8String]);
        char *setterName = property_copyAttributeValue(prop, "S");
        if (setterName) {
            selectorString = [NSString stringWithFormat:@"%s", setterName];
        }
        else {
            const char *selName = [key UTF8String];
            selectorString = [NSString stringWithFormat:@"set%c%s:", toupper(selName[0]), selName+1];
        }
        
        SEL selector = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:selector]) {
            [self setValue:obj forKey:key];
        }
    }];
}

@end

@implementation Router

- (id)init {
    self = [super init];
    if (self) {
        _routes = [NSMutableDictionary new];
        _numberFormatter = [NSNumberFormatter new];
        [self configureInitialRoutes];
    }
    return self;
}

+ (Router *)sharedRouter {
    static Router *_sharedRouter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRouter = [Router new];
    });
    
    return _sharedRouter;
}

#pragma marks - Defining Routes

- (void)addRoute:(NSString *)route handler:(RouteHandler)handler {
    self.routes[route] = handler;
}

- (void)addRoute:(NSString *)route forControllerClass:(Class)controllerClass {
    self.routes[route] = controllerClass;
}

- (void)addRoutesWithDictionary:(NSDictionary *)routes {
    [routes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // if it's a class, make sure it's a subclass of UIViewController
        if (class_isMetaClass(object_getClass(obj))) {
            if (![obj isSubclassOfClass:[UIViewController class]]) {
                [NSException raise:@"Not a subclass of UIViewController" format:@"Must pass in either a subclass of UIViewController or handler block"];
            }
        }
        
        self.routes[key] = obj;
    }];
}

#pragma marks - Dispatching

- (UIViewController *)controllerForClass:(Class)cls params:(NSDictionary *)params {
    UIViewController *viewController = [cls new];
    [viewController applyRoutingParameters:params];
    return viewController;
}

/* DEPRICATED for iPad */
- (UIViewController *)controllerForHandlingURL:(NSURL *)url {
    __block UIViewController *viewController;
    [self matchURL:url matchHandler:^(NSDictionary *params, id classOrBlock) {
        if (class_isMetaClass(object_getClass(classOrBlock))) {
            viewController = [self controllerForClass:classOrBlock params:params];
        } else {
            UIViewController *(^blockForPath)(NSDictionary *, id) = classOrBlock;
            viewController = blockForPath(params, nil);
        }
    }];
    return viewController;
}

#pragma marks - Primary iPad Routing Methods
- (UIViewController *)controllerForHandlingBlockFromURL:(NSURL *)url {
    __block UIViewController *returnedController;
    
    [self matchURL:url matchHandler:^(NSDictionary *params, id classOrBlock) {
        if (class_isMetaClass(object_getClass(classOrBlock))) { // it's a class
            returnedController = [self controllerForClass:classOrBlock params:params];
        } else {
            UIViewController *(^blockForPath)(NSDictionary *, id) = classOrBlock;
            returnedController = blockForPath(params, nil);
        }
    }];
    
    return returnedController;
}

- (UIViewController *)controllerForHandlingBlockFromViewModel:(CBIViewModel *)viewModel {
    __block id returnedController;
    if ([viewModel isKindOfClass:[CBISyllabusViewModel class]]){
        [self matchURL:[NSURL URLWithString:[viewModel.model.path stringByAppendingPathComponent:@"item/syllabus"]] matchHandler:^(NSDictionary *params, id classOrBlock) {
            if (class_isMetaClass(object_getClass(classOrBlock))) { // it's a class
                returnedController = [self controllerForClass:classOrBlock params:params];
            } else {
                id(^blockForPath)(NSDictionary *, id) = classOrBlock;
                returnedController = blockForPath(params, viewModel);
            }
        }];
    }
    else {
        [self matchURL:[NSURL URLWithString:[viewModel.model.path realURLEncodedString]] matchHandler:^(NSDictionary *params, id classOrBlock) {
            if (class_isMetaClass(object_getClass(classOrBlock))) { // it's a class
                returnedController = [self controllerForClass:classOrBlock params:params];
            } else {
                id(^blockForPath)(NSDictionary *, id) = classOrBlock;
                returnedController = blockForPath(params, viewModel);
            }
        }];
    }
    
    return returnedController;
}

- (UIViewController *)routeFromController:(UIViewController *)sourceController toURL:(NSURL *)url {

    UIViewController *destinationViewController = [self controllerForHandlingBlockFromURL:url];
    
    if (!destinationViewController && self.fallbackHandler) {
        self.fallbackHandler(url, sourceController);
        return nil;
    }
    
    [sourceController cbi_transitionToViewController:destinationViewController animated:YES];
    
    return destinationViewController;
}

- (UIViewController *)routeFromController:(UIViewController *)sourceController toViewModel:(CBIViewModel *)viewModel {
    
    UIViewController *destinationViewController = [self controllerForHandlingBlockFromViewModel:viewModel];
    
    [sourceController cbi_transitionToViewController:destinationViewController animated:YES];
    
    return destinationViewController;
}

- (void)openCanvasURL:(NSURL *)url {
    RACSignal *clientFromSuggestedDomain = [TheKeymaster signalForLoginWithDomain:url.host];
    
    [clientFromSuggestedDomain subscribeNext:^(CKIClient *client) {
        UITabBarController *root = (UITabBarController *)UIApplication.sharedApplication.windows[0].rootViewController;
        UINavigationController *selectedController = (UINavigationController *)root.selectedViewController;
        UIViewController *sourceViewController = selectedController.topViewController;
        
        if ([sourceViewController isKindOfClass:[CBISplitViewController class]]) {
            CBISplitViewController *split = (CBISplitViewController *)sourceViewController;
            sourceViewController = split.detail ?: split.master;
        }
        
        [self routeFromController:selectedController.topViewController toURL:url];
    }];
}

# pragma marks - Parsing

- (BOOL)matchURL:(NSURL *)url matchHandler:(void(^)(NSDictionary *params, id classOrBlock))matchHandler {
    NSString *currentHost = [CKIClient currentClient].baseURL.host;
    
    NSString *path = url.path;
    path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    path = [path stringByReplacingOccurrencesOfString:@"api/v1/" withString:@""];
    NSArray *urlComponents = path.pathComponents;
    
    __block NSURL *originalURL = url;
    __block NSMutableDictionary *params;
    __block BOOL matchFound = NO;
    
    BOOL requestIsInternal = [url host].description.length > 0 ? [[url host] isEqualToString:currentHost] : YES;
    
    if (requestIsInternal) {
        [self.routes.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            NSURL *routeURL = [NSURL URLWithString:key];
            NSArray *routeComponents = [routeURL.pathComponents subarrayWithRange:NSMakeRange(1, routeURL.pathComponents.count -1)];
            params = [NSMutableDictionary new];
            params[@"url"] = url;
            
            if (urlComponents.count != routeComponents.count) {
                return; // can't possibly match
            }
            
            for (NSUInteger i = 0; i < routeComponents.count; i++) {
                if ([routeComponents[i] hasPrefix:@":"]) { // save params in case this is a match
                    NSString *paramKey = [routeComponents[i] substringFromIndex:1];
                    NSString *param = urlComponents[i];
                    NSNumber *number = [self.numberFormatter numberFromString:param];
                    if (number) {
                        params[paramKey] = number;
                    }
                    else {
                        params[paramKey] = param;
                    }
                }
                else if (![urlComponents[i] isEqualToString:routeComponents[i]]) {
                    return; // not a match, continue to next key
                }
            }
            
            matchFound = YES;
            if (CKCanvasAPI.currentAPI) {
                params[@"canvasAPI"] = CKCanvasAPI.currentAPI;
            }
            if (params[@"courseIdent"]) {
                uint64_t ident = [params[@"courseIdent"] unsignedLongLongValue];
                params[@"contextInfo"] = [CKContextInfo contextInfoFromCourseIdent:ident];
            }
            else if (params[@"groupIdent"]) {
                uint64_t ident = [params[@"groupIdent"] unsignedLongLongValue];
                params[@"contextInfo"] = [CKContextInfo contextInfoFromGroupIdent:ident];
            }
            else if (params[@"userIdent"]) {
                uint64_t ident = [params[@"userIdent"] unsignedLongLongValue];
                params[@"contextInfo"] = [CKContextInfo contextInfoFromUserIdent:ident];
            }
            
            if ([self isDownloadURL:originalURL]) {
                params[@"downloadURL"] = originalURL;
            }
            
            matchHandler(params, self.routes[key]);
            *stop = matchFound;
        }];
    }

    if(!matchFound){
        NSLog(@"no registered route for URL %@", url);
    }
    
    return matchFound;
}

- (BOOL) isDownloadURL:(NSURL *)url {
    NSArray *urlComponents = url.pathComponents;
    
    __block BOOL isDownload = NO;
    [urlComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:@"download"]) {
            isDownload = YES;
            *stop = YES;
            return;
        }
    }];
    
    if (isDownload) {
        isDownload = [url.absoluteString.lowercaseString containsString:@"verifier"];
    }
    
    return isDownload;
}

@end
