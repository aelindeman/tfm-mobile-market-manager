//
//  ImportTool.h
//  TFMMobileMarketManager
//

#import <Foundation/Foundation.h>

#import "MarketStaff.h"
#import "Vendors.h"
#import "Locations.h"

@interface ImportTool : NSObject

- (void)importStaffFromCSV:(NSURL *)url;
- (void)importVendorsFromCSV:(NSURL *)url;
- (void)importLocationsFromCSV:(NSURL *)url;

@end
