//
//  MarketStaffListViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Staff.h"
#import "MarketStaffFormViewController.h"
#import "FXForms.h"

@interface MarketStaffListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
