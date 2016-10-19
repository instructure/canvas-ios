//
//  CBISyllabusTabViewModel.m
//  iCanvas
//
//  Created by nlambson on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISyllabusTabViewModel.h"
#import "CBISyllabusViewModel.h"
#import "CBIAssignmentViewModel.h"
#import "CBICalendarEventViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "Router.h"
@import CanvasKeymaster;
#import "CBILog.h"

@interface CBISyllabusTabViewModel ()
@property (nonatomic) NSMutableDictionary *syllabusItemsByID;
@end

@implementation CBISyllabusTabViewModel
@synthesize collectionController;

typedef NS_ENUM(NSInteger, sectionType) {
    SyllabusSection,
    PastSection,
    TodaySection,
    WeekSection,
    FutureSection,
    NoDateSection
};

- (id)init
{
    self = [super init];
    if (self) {
        NSCalendar *current = [NSCalendar currentCalendar];
        self.viewControllerTitle = NSLocalizedString(@"Syllabus", @"Title for Syllabus screen");
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^(id viewModel){
            NSString *class = NSStringFromClass([viewModel class]);
            NSDate *syllabusDate = nil;
            NSString *name = @"";

            if ([class isEqualToString:@"CBISyllabusViewModel"] ||
                [class isEqualToString:@"CBICalendarEventViewModel"] ||
                [class isEqualToString:@"CBIAssignmentViewModel"]){
                
                syllabusDate = [viewModel syllabusDate];
                name = [viewModel name];
            }
            
            if (!syllabusDate){
                return @(NoDateSection);
            }
            
            if ([name caseInsensitiveCompare:@"Syllabus"] == NSOrderedSame){
                return @(SyllabusSection);
            }
            
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:7];
            NSDate *weekFromTodaysDate = [current dateByAddingComponents:offsetComponents toDate:[NSDate date] options:kNilOptions];
            
            NSDateComponents *todaysComponents = [current
                                                        components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                        fromDate:[NSDate date]];
            NSDateComponents *weekFromTodayComponents = [current
                                                         components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                         fromDate:weekFromTodaysDate];
            NSDateComponents *syllabusDateComponents = [current
                                                        components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                        fromDate:syllabusDate];
            NSDate *todaysDateWithoutTime = [current
                                             dateFromComponents:todaysComponents];
            NSDate *weekFromTodayDateWithoutTime = [current
                                             dateFromComponents:weekFromTodayComponents];
            NSDate *syllabusDateWithoutTime = [current
                                             dateFromComponents:syllabusDateComponents];
            
            
            if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedAscending){
                return @(PastSection);
            }else if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedSame){
                return @(TodaySection);
            }else if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedDescending && [syllabusDateWithoutTime compare:weekFromTodayDateWithoutTime] == NSOrderedAscending){
                return @(WeekSection);
            }
            return @(FutureSection);
        }groupTitleBlock:^(id viewModel){
            NSString *class = NSStringFromClass([viewModel class]);
            NSDate *syllabusDate = nil;
            NSString *name = @"";
            
            if ([class isEqualToString:@"CBISyllabusViewModel"] ||
                [class isEqualToString:@"CBICalendarEventViewModel"] ||
                [class isEqualToString:@"CBIAssignmentViewModel"]){
                
                syllabusDate = [viewModel syllabusDate];
                name = [viewModel name];
            }
            
            if (!syllabusDate){
                return NSLocalizedString(@"No Date", nil);
            }
            
            if ([name caseInsensitiveCompare:@"Syllabus"] == NSOrderedSame){
                return NSLocalizedString(@"Course Syllabus", nil);;
            }
            
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:7];
            NSDate *weekFromTodaysDate = [current dateByAddingComponents:offsetComponents toDate:[NSDate date] options:kNilOptions];
            
            NSDateComponents *todaysComponents = [current
                                                  components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                  fromDate:[NSDate date]];
            NSDateComponents *weekFromTodayComponents = [current
                                                         components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                         fromDate:weekFromTodaysDate];
            NSDateComponents *syllabusDateComponents = [current
                                                        components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                        fromDate:syllabusDate];
            NSDate *todaysDateWithoutTime = [current
                                             dateFromComponents:todaysComponents];
            NSDate *weekFromTodayDateWithoutTime = [current
                                                    dateFromComponents:weekFromTodayComponents];
            NSDate *syllabusDateWithoutTime = [current
                                               dateFromComponents:syllabusDateComponents];

            
            if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedAscending){
                return NSLocalizedString(@"Past", nil);
            }else if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedSame){
                return NSLocalizedString(@"Today", nil);
            }else if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedDescending && [syllabusDateWithoutTime compare:weekFromTodayDateWithoutTime] == NSOrderedAscending){
                return NSLocalizedString(@"Next 7 Days", nil);
            }
            
            return NSLocalizedString(@"Future", nil);
        }sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"syllabusDate" ascending:YES]]];
        self.syllabusItemsByID = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulSubtitleCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
}

#pragma mark - syncing

- (RACSignal *)refreshViewModelsSignal {
    
    RACSignal *assignmentViewmodels = [[[CKIClient currentClient] fetchAssignmentsForContext:self.model.context] map:^id(NSArray *assignments) {
        return [[assignments.rac_sequence map:^id(CKIAssignment *assignment) {
            CBIAssignmentViewModel *assignmentViewModel = [CBIAssignmentViewModel viewModelForModel:assignment];
            RAC(assignmentViewModel, tintColor) = RACObserve(self, tintColor);
            return assignmentViewModel;
        }] array];
    }];
    
    RACSignal *calendarEventViewModels = [[[CKIClient currentClient] fetchCalendarEventsForContext:self.model.context] map:^id(NSArray *calendarEvents) {
        return [[[calendarEvents rac_sequence] map:^id(CKICalendarEvent *event) {
            CBICalendarEventViewModel *viewModel = [CBICalendarEventViewModel viewModelForModel:event];
            RAC(viewModel, tintColor) = RACObserve(self, tintColor);
            return viewModel;
        }] array];
    }];
    
    if ([self.model.context isKindOfClass:[CKICourse class]]){
        CBISyllabusViewModel *syllabusViewmodel = [CBISyllabusViewModel viewModelForModel:((CKICourse *)self.model.context)];
        RAC(syllabusViewmodel, tintColor) = RACObserve(self, tintColor);
        return [RACSignal concat:@[assignmentViewmodels, calendarEventViewModels, [RACSignal return:@[syllabusViewmodel]]]];
    }

    return [RACSignal concat:@[assignmentViewmodels, calendarEventViewModels]];
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"didSelectSyllabusItem");
    [[Router sharedRouter] routeFromController:controller toViewModel:self];
}
@end
