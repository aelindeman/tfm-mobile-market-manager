//
//  MarketDayFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "MarketDays.h"
#import "MarketDayForm.h"
#import "MainMenuViewController.h"
#import "MarketOpenMenuViewController.h"
#import "FXForms.h"

@interface MarketDayFormViewController : FXFormViewController <MarketOpenDelegate>

@property (nonatomic, assign) id <MarketOpenDelegate> delegate;

@property (nonatomic) NSManagedObjectID *marketdayID;
@property (nonatomic) MarketDays *marketday;
@property bool editMode;

@end
