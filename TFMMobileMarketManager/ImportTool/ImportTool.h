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

- (NSUInteger)importStaffFromCSV:(NSURL *)url;
- (NSUInteger)importVendorsFromCSV:(NSURL *)url;
- (NSUInteger)importLocationsFromCSV:(NSURL *)url;

@end
