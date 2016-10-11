//
//  CSGErrorDocumentViewController.h
//  SpeedGrader
//
//  Created by Nathan Lambson on 5/20/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGDocumentHandler.h"

@interface CSGErrorDocumentViewController : UIViewController<CSGDocumentHandler>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@end
