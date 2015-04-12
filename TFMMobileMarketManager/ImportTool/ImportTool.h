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

@interface ImportTool : NSObject

@property bool skipFirstRow;

- (id)initWithSkipSetting:(bool)skipFirstRow;

- (unsigned int)importStaffFromCSV:(NSURL *)url;
- (unsigned int)importVendorsFromCSV:(NSURL *)url;
- (unsigned int)importLocationsFromCSV:(NSURL *)url;

- (bool)importDump:(NSURL *)url;
// - (bool)importTable:(NSURL *)url;

@end
