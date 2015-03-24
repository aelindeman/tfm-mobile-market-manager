//
//  RedemptionListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Redemptions.h"
#import "RedemptionFormViewController.h"
#import "FXForms.h"

@interface RedemptionListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) Redemptions *selectedObject;

@end
