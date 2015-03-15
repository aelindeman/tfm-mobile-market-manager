//
//  ConsoleViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

@interface ConsoleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tableField;
@property (weak, nonatomic) IBOutlet UITextField *predicateField;
@property (weak, nonatomic) IBOutlet UITextField *sortField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortOrderPicker;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *executeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;

@property (weak, nonatomic) IBOutlet UITextView *output;

- (IBAction)executeButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)exportButtonPressed:(id)sender;

@end
