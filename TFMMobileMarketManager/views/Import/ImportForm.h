//
//  ImportForm.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "ImportTool.h"
#import "FXForms.h"

@interface ImportForm : NSObject <FXForm>

@property NSURL *url;

@property ImportType importType;
@property ImportFormat importFormat;
@property bool skipFirstRow;

@end
