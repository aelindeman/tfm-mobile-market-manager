//
//  MainMenuViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

// temporary imports for database prepopulation
#import "Location.h"
#import "Staff.h"
#import "Vendor.h"

@interface MainMenuViewController : UITableViewController

@property NSArray *menuOptions;
@property NSArray *menuSectionHeaders;

@end
