//
//  CKMDomainSearchViewController.h
//  CanvasKeymaster
//
//  Created by Layne Moseley on 2/13/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKIAccountDomain;
@protocol CKMDomainSearchViewControllerDelegate;

@interface CKMDomainSearchViewController : UIViewController

@property (nonatomic, weak) id<CKMDomainSearchViewControllerDelegate> delegate;

@end

@protocol CKMDomainSearchViewControllerDelegate

- (void)showHelpPopover;
- (void)sendDomain:(CKIAccountDomain *)domain;

@end
