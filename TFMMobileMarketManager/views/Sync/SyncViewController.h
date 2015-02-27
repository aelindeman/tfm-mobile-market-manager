//
//  SyncViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
@import ExternalAccessory;

@interface SyncViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

- (IBAction)syncButtonPressed:(id)sender;

@end
