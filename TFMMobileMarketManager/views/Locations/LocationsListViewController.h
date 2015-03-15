//
//  LocationsListViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Locations.h"
#import "LocationsFormViewController.h"
#import "FXForms.h"

@interface LocationsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) Locations *selectedObject;

@end
