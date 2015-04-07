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
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *importButton;

- (void)handleOpenURL:(NSURL *)url;
- (IBAction)prepopulatePrompt:(id)sender;
- (IBAction)importData:(UIButton *)sender;

@end
