//
//  MarketStaffListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketStaff.h"
#import "MarketStaffFormViewController.h"
#import "FXForms.h"

@interface MarketStaffListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
