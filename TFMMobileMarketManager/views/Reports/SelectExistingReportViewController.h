//
//  SelectExistingReportViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "ReportsMenuViewController.h"
#import "ReportViewerViewController.h"

@interface SelectExistingReportViewController : UITableViewController <ReportsMenuDelegate>

@property (nonatomic, assign) id <ReportsMenuDelegate> delegate;

// starting directory - will only traverse this folder for its immediate subfolders and their files
@property NSString *basePath;

@property NSString *selectedObject;

// array of dictionaries
// NSArray *items = @[ @{@"name": @"subfolder name", @"items": @[ @"file 1", @"file 2", ... ] }, @{ ... } ];
@property NSArray *items;

@end
