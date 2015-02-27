//
//  LocationsForm.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "FXForms.h"

@interface LocationsForm : NSObject <FXForm>

@property NSString *abbreviation;
@property NSString *address;
@property NSString *name;

@end
