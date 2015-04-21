//
//  ImporterViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "ImportTool.h"

// needed for database prepopulation
#import "MarketStaff.h"
#import "Vendors.h"
#import "Locations.h"

@interface ImporterViewController : UIViewController

@property NSURL *fileToImport;

@property (weak, nonatomic) IBOutlet UISegmentedControl *importDestination;
@property (weak, nonatomic) IBOutlet UISwitch *firstRowSkipSwitch;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;

- (void)loadFromURL:(NSURL *)url;
- (IBAction)prepopulatePrompt:(id)sender;
- (IBAction)confirmImportData:(id)sender;

- (void)importData;

@end
