//
//  MainMenuViewController.h
//  tfmco-mip
//

#import <QuickLook/QuickLook.h>
#import "AppDelegate.h"
#import "ImportForm.h"
#import "ImportFormViewController.h"

@interface MainMenuViewController : UITableViewController <QLPreviewControllerDataSource>

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@property (nonatomic) QLPreviewController *helpViewer;

@end
