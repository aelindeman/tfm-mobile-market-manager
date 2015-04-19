//
//  ImportForm.h
//  TFMMobileMarketManager
//

#import "AppDelegate.h"
#import "FXForms.h"

typedef NS_ENUM(NSInteger, ImportType)
{
	ImportTypeDump = -1,
	ImportTypeVendors = 0,
	ImportTypeStaff,
	ImportTypeLocations,
};

typedef NS_ENUM(NSInteger, ImportFormat)
{
	ImportFormatCSV = 0,
	ImportFormatJSON
};

typedef NS_ENUM(NSInteger, ImportDumpOptions)
{
	ImportDumpReplace = 0,
	ImportDumpMerge,
	ImportDumpUpdate
};

@interface ImportForm : NSObject <FXForm>

@property NSURL *url;

@property ImportType importType;
@property ImportFormat importFormat;
@property bool skipFirstRow;

@end
