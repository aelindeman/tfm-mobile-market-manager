//
//  MarketDayFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "MarketDay.h"
#import "MarketDayForm.h"
#import "MainMenuViewController.h"
#import "FXForms.h"

@interface MarketDayFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *marketdayID;
@property (nonatomic) MarketDay *marketday;
@property bool editMode;

@end
