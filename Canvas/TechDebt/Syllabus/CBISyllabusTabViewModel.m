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
    
    

#import "CBISyllabusTabViewModel.h"
#import "CBISyllabusViewModel.h"
#import "CBIAssignmentViewModel.h"
#import "CBICalendarEventViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "Router.h"
@import CanvasKeymaster;

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
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    if (self) {
        NSCalendar *current = [NSCalendar currentCalendar];
        self.viewControllerTitle = NSLocalizedStringFromTableInBundle(@"Syllabus", nil, bundle, @"Title for Syllabus screen");
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^(id viewModel){
            NSString *class = NSStringFromClass([viewModel class]);
            NSDate *syllabusDate = nil;
            NSString *name = @"";

            if ([class isEqualToString:@"CBISyllabusViewModel"]) {
                return @(SyllabusSection);
            }

            if ([class isEqualToString:@"CBICalendarEventViewModel"] ||
                [class isEqualToString:@"CBIAssignmentViewModel"]){
                
                syllabusDate = [viewModel syllabusDate];
                name = [viewModel name];
            }
            
            if (!syllabusDate){
                return @(NoDateSection);
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
            NSBundle *bundle = [NSBundle bundleForClass:self.class];
            NSString *class = NSStringFromClass([viewModel class]);
            NSDate *syllabusDate = nil;
            NSString *name = @"";

            if ([class isEqualToString:@"CBISyllabusViewModel"]) {
                return NSLocalizedStringFromTableInBundle(@"Course Syllabus", nil, bundle, @"");
            }

            if ([class isEqualToString:@"CBICalendarEventViewModel"] ||
                [class isEqualToString:@"CBIAssignmentViewModel"]){
                
                syllabusDate = [viewModel syllabusDate];
                name = [viewModel name];
            }
            
            if (!syllabusDate){
                return NSLocalizedStringFromTableInBundle(@"No Date", nil, bundle, nil);
            }
            
            if ([name caseInsensitiveCompare:@"Syllabus"] == NSOrderedSame){
                return NSLocalizedStringFromTableInBundle(@"Course Syllabus", nil, bundle, nil);;
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
                return NSLocalizedStringFromTableInBundle(@"Past", nil, bundle, nil);
            }else if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedSame){
                return NSLocalizedStringFromTableInBundle(@"Today", nil, bundle, nil);
            }else if([syllabusDateWithoutTime compare:todaysDateWithoutTime] == NSOrderedDescending && [syllabusDateWithoutTime compare:weekFromTodayDateWithoutTime] == NSOrderedAscending){
                return NSLocalizedStringFromTableInBundle(@"Next 7 Days", nil, bundle, nil);
            }
            
            return NSLocalizedStringFromTableInBundle(@"Future", nil, bundle, nil);
        }sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"syllabusDate" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
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
        return [[[[calendarEvents rac_sequence] filter:^BOOL(CKICalendarEvent *event) {
            return event.hidden == NO;
        }] map:^id(CKICalendarEvent *event) {
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
    [[Router sharedRouter] routeFromController:controller toViewModel:self];
}
@end
