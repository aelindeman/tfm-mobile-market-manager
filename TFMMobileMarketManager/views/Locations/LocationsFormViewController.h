//
//  LocationsFormViewController.h
//  tfmco-mip
//

#import "AppDelegate.h"
#import "Locations.h"
#import "LocationsForm.h"
#import "FXForms.h"

@interface LocationsFormViewController : FXFormViewController

@property (nonatomic) NSManagedObjectID *editObjectID;
@property (nonatomic) Locations *editObject;
@property bool editMode;

@end
