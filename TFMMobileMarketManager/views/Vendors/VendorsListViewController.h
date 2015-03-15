//
//  VendorsListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Vendors.h"
#import "VendorFormViewController.h"
#import "FXForms.h"

@interface VendorsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) Vendors *selectedObject;

@end
