//
//  ImporterViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

// needed for database prepopulation
#import "MarketStaff.h"
#import "Vendors.h"
#import "Locations.h"

@interface ImporterViewController : UIViewController

@property NSURL *fileToImport;

@property (weak, nonatomic) IBOutlet UISegmentedControl *importDestination;
@property (weak, nonatomic) IBOutlet UITextView *importData;

- (void)handleOpenURL:(NSURL *)url;
- (IBAction)prepopulatePrompt:(id)sender;
- (IBAction)importData:(UIButton *)sender;

@end
