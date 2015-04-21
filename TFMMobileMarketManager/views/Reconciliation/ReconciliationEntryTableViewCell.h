//
//  ReconciliationEntryTableViewCell.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"

@interface ReconciliationEntryTableViewCell : UITableViewCell <UITextFieldDelegate>

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
@property (weak, nonatomic) IBOutlet UITextField *snapField2;
@property (weak, nonatomic) IBOutlet UITextField *creditField1;
@property (weak, nonatomic) IBOutlet UITextField *creditField2;
@property (weak, nonatomic) IBOutlet UITextField *totalField1;
@property (weak, nonatomic) IBOutlet UITextField *totalField2;

- (IBAction)sanitizeField:(id)sender;

- (void)removePlaceholders;

- (void)setField1Prefix:(NSString *)prefix;
- (void)setField1Suffix:(NSString *)suffix;
- (void)setField2Prefix:(NSString *)prefix;
- (void)setField2Suffix:(NSString *)suffix;

- (NSDictionary *)getData;
- (bool)reconcileWith:(NSDictionary *)inputs;

@end
