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

#import <objc/runtime.h>

#import "Router.h"
#import "Router+Routes.h"

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

- (UIViewController *)routeFromController:(UIViewController *)sourceController toURL:(NSURL *)url {

    UIViewController *destinationViewController = [self controllerForHandlingBlockFromURL:url];
    
    if (!destinationViewController && self.fallbackHandler) {
        self.fallbackHandler(url, sourceController);
        return nil;
    }
    
    if ([sourceController isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)sourceController) pushViewController:destinationViewController animated:YES];
    } else {
        [sourceController.navigationController pushViewController:destinationViewController animated:YES];
    }
    
    return destinationViewController;
}

# pragma marks - Parsing

- (BOOL)matchURL:(NSURL *)url matchHandler:(void(^)(NSDictionary *params, id classOrBlock))matchHandler {
    NSArray *urlComponents = url.pathComponents;
    
    // strip /api/v1/ if it's there
    if (urlComponents.count > 2 && [urlComponents[1] isEqualToString:@"api"] && [urlComponents[2] isEqualToString:@"v1"]) {
        urlComponents = [urlComponents subarrayWithRange:NSMakeRange(3, urlComponents.count - 3)];
    }
    else if (urlComponents.count > 0) { // strip slash
        urlComponents = [urlComponents subarrayWithRange:NSMakeRange(1, urlComponents.count -1)];
    }

    __block NSMutableDictionary *params;
    __block BOOL matchFound = NO;
    
    [self.routes.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSURL *routeURL = [NSURL URLWithString:key];
        NSArray *routeComponents = [routeURL.pathComponents subarrayWithRange:NSMakeRange(1, routeURL.pathComponents.count -1)];
        params = [NSMutableDictionary new];
        
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
        if (self.canvasAPI) {
            params[@"canvasAPI"] = self.canvasAPI;
        }
        matchHandler(params, self.routes[key]);
        *stop = matchFound;
    }];
    
    if(!matchFound){
        NSLog(@"no registered route for URL %@", url);
    }
    
    return matchFound;
}

@end

