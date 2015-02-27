//
//  MarketStaffFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Staff.h"
#import "MarketStaffForm.h"
#import "FXForms.h"

@interface MarketStaffFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Staff *editObject;
@property bool editMode;

@end
