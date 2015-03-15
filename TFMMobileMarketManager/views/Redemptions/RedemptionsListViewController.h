//
//  RedemptionsListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Redemptions.h"
#import "RedemptionFormViewController.h"
#import "FXForms.h"

@interface RedemptionsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) Redemptions *selectedObject;

@end
