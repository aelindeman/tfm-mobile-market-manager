//
//  ReconciliationEntryTableViewCell.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

@interface ReconciliationEntryTableViewCell : UITableViewCell

@property (nonatomic) NSString *field1Prefix;
@property (nonatomic) NSString *field1Suffix;
@property (nonatomic) NSString *field2Prefix;
@property (nonatomic) NSString *field2Suffix;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UILabel *snapLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (weak, nonatomic) IBOutlet UITextField *snapField1;
- (IBAction)snapField1EditingDidBegin:(id)sender;
- (IBAction)snapField1EditingDidEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *snapField2;
- (IBAction)snapField2EditingDidBegin:(id)sender;
- (IBAction)snapField2EditingDidEnd:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *creditField1;
- (IBAction)creditField1EditingDidBegin:(id)sender;
- (IBAction)creditField1EditingDidEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *creditField2;
- (IBAction)creditField2EditingDidBegin:(id)sender;
- (IBAction)creditField2EditingDidEnd:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *totalField1;
- (IBAction)totalField1EditingDidBegin:(id)sender;
- (IBAction)totalField1EditingDidEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *totalField2;
- (IBAction)totalField2EditingDidBegin:(id)sender;
- (IBAction)totalField2EditingDidEnd:(id)sender;

- (void)setField1Prefix:(NSString *)prefix;
- (void)setField1Suffix:(NSString *)suffix;
- (void)setField2Prefix:(NSString *)prefix;
- (void)setField2Suffix:(NSString *)suffix;

@end
