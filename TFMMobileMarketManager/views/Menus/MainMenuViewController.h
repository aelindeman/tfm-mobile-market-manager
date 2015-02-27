//
//  MainMenuViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"

// temporary imports for database prepopulation
#import "Locations.h"
#import "MarketStaff.h"
#import "Vendors.h"

@interface MainMenuViewController : UITableViewController

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@end
