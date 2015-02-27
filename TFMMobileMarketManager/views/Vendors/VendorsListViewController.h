//
//  VendorsListViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Vendor.h"
#import "VendorFormViewController.h"
#import "FXForms.h"

@interface VendorsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
