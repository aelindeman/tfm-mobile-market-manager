//
//  SelectExistingReportViewController.h
//  TFMMobileMarketManager
//

#import <QuickLook/QuickLook.h>
#import "AppDelegate.h"

@interface SelectExistingReportViewController : UITableViewController <QLPreviewControllerDataSource>

// starting directory - will only traverse this folder for its immediate subfolders and their files
@property NSString *basePath;

@property NSString *selectedObject;

// array of dictionaries
// @[ @{@"name": @"subfolder name", @"items": @[ @"file 1", @"file 2", ... ] }, @{ ... } ];
@property NSArray *items;

// preview window
@property (nonatomic) QLPreviewController *previewer;

@end
