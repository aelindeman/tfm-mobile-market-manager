//
//  SelectExistingReportViewController.h
//  TFMMobileMarketManager
//

#import <QuickLook/QuickLook.h>
#import "AppDelegate.h"
#import "ReportTool.h"

@interface SelectExistingReportViewController : UITableViewController <QLPreviewControllerDataSource>

@property NSString *selectedObject;

// array of dictionaries
// @[ @{@"name": @"subfolder name", @"items": @[ @"file 1", @"file 2", ... ] }, @{ ... } ];
@property NSArray *items;

// preview window
@property (nonatomic) QLPreviewController *previewer;

@end
