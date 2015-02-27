//
//  LocationsFormViewController.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "Location.h"
#import "LocationsForm.h"
#import "FXForms.h"

@interface LocationsFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Location *editObject;
@property bool editMode;

@end
