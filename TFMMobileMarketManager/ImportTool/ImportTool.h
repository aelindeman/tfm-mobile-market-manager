//
//  ImportTool.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "CHCSVParser.h"

#import "MarketStaff.h"
#import "Vendors.h"
#import "Locations.h"

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
	ImportDumpAdd,
	ImportDumpUpdate
};

@interface ImportTool : NSObject

@property bool skipFirstRow;

- (id)initWithSkipSetting:(bool)skipFirstRow;

- (unsigned int)importStaffFromCSV:(NSURL *)url;
- (unsigned int)importVendorsFromCSV:(NSURL *)url;
- (unsigned int)importLocationsFromCSV:(NSURL *)url;

- (bool)importDump:(NSURL *)url;
// - (bool)importTable:(NSURL *)url;

@end
