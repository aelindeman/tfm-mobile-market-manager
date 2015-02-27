//
//  MarketDayFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDays.h"
#import "MarketDayForm.h"
#import "MainMenuViewController.h"
#import "FXForms.h"

@interface MarketDayFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *marketdayID;
@property (nonatomic) MarketDays *marketday;
@property bool editMode;

@end
