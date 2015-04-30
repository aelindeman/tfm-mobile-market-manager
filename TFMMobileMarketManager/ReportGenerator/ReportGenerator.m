//
//  ReportGenerator.m
//  TFMMobileMarketManager
//

#import "ReportGenerator.h"

@implementation ReportGenerator

static NSString *reportsSubfolder = @"Reports"; // relative to application's documents directory
static NSString *marketDaySubfolder = @"%@"; // relative to reports subfolder, replace token with market day name
static NSString *exportsSubfolder = @"Raw Data"; // relative to reports subfolder, contains reports that don't need market day to create

// replace first token with market day name, second token with report type, third token with uuid
static NSString *reportFormat = @"%@ %@ %@.csv"; // relative to market day subfolder

// report names
static NSString *demographicsReportName = TFMM3_REPORT_TYPE_DEMOGRAPHICS;
static NSString *redemptionsReportName = TFMM3_REPORT_TYPE_REDEMPTIONS;
static NSString *salesReportName = TFMM3_REPORT_TYPE_SALES;
static NSString *vendorsExportName = TFMM3_REPORT_TYPE_VENDORS;
static NSString *staffExportName = TFMM3_REPORT_TYPE_STAFF;
static NSString *locationsExportName = TFMM3_REPORT_TYPE_LOCATIONS;

static NSString *dumpName = TFMM3_REPORT_TYPE_DUMP;
static NSString *dumpFormat = @"%@ %@ %@.m3db"; // device name, dumpName, uuid

// allow init using delegate's active market day
- (id)init
{
	return [self initWithMarketDay:TFMM3_APP_DELEGATE.activeMarketDay];
}

// market day needs to be specified before generating a report
- (id)initWithMarketDay:(MarketDays *)marketDay
{
	if (self = [super init])
	{
		_selectedMarketDay = marketDay;
	}
	return self;
}

// writes contents to file, creating the file and path on the way. returns true on success
- (bool)writeReportToFile:(NSString *)path contents:(NSString *)contents
{
	NSFileHandle *fh;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	@try
	{
		// create report directory and csv file
		[fm createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
		[fm createFileAtPath:path contents:nil attributes:nil];

		// open the file for writing
		fh = [NSFileHandle fileHandleForWritingAtPath:path];
		[fh truncateFileAtOffset:[fh seekToEndOfFile]];
		[fh writeData:[contents dataUsingEncoding:NSUTF8StringEncoding]];

		NSLog(@"wrote report to %@", path);
	}
	@catch (NSException *exception)
	{
		NSLog(@"couldn’t write report: %@", [exception reason]);
	}
	@finally
	{
		[fh closeFile];
	}
	
	// return true if file was created and isn't empty, return false otherwise
	if ([fm fileExistsAtPath:path])
	{
		NSDictionary *attribs = [fm attributesOfItemAtPath:path error:nil];
		return [attribs fileSize] > 0;
	}
	else return false;
}

// creates the reports path
- (NSString *)getReportsPathForReportType:(NSString*)reportName
{
	NSString *path = [NSString pathWithComponents:@[[TFMM3_APP_DELEGATE.applicationDocumentsDirectory path], reportsSubfolder]];
	
	// create a report generation uuid
	CFUUIDRef uuid = CFUUIDCreate(nil);
	NSString *uuidString = [(NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuid)) substringToIndex:8]; // only use first 8 chars
	CFRelease(uuid);
	
	if ([TFMM3_REPORT_TYPES_MARKETDAY containsObject:reportName])
	{
		// need a consistent way of returning the market day name by its name then the date. don't rely on -description
		NSDateFormatter *mdDateFormat = [[NSDateFormatter alloc] init];
		[mdDateFormat setDateFormat:@"yyyy-MM-dd"];
		NSString *md = [NSString stringWithFormat:@"%@ %@", [mdDateFormat stringFromDate:[self.selectedMarketDay date]], [(Locations *)[self.selectedMarketDay location] name]];
		
		// return path string
		return [NSString pathWithComponents:@[path, [NSString stringWithFormat:marketDaySubfolder, md], [NSString stringWithFormat:reportFormat, md, reportName, uuidString]]];
	}
	
	else if ([[reportName lowercaseString] containsString:[TFMM3_REPORT_TYPE_DUMP lowercaseString]])
		return [NSString pathWithComponents:@[path, exportsSubfolder, [NSString stringWithFormat:dumpFormat, [[UIDevice currentDevice] name], reportName, uuidString]]];
	
	else return [NSString pathWithComponents:@[path, exportsSubfolder, [NSString stringWithFormat:reportFormat, [[UIDevice currentDevice] name], reportName, uuidString]]];
}

// creates demographics report at default path; returns path
- (NSString *)generateDemographicsReport
{
	NSString *path = [self getReportsPathForReportType:demographicsReportName];
	return [self generateDemographicsReportAtPath:path] ? path : false;
}

// creates demographics report at specific path
- (bool)generateDemographicsReportAtPath:(NSString *)path
{
	if (!self.selectedMarketDay)
	{
		NSLog(@"can't create report: no active market day set");
		return false;
	}
	
	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"CustomerType,Credit,SNAP,Total\n";
	writeString = [writeString stringByAppendingString:header];

	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Transactions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];

	NSError *error;
	NSArray *query = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	NSAssert1(!error, @"fetch request failed: %@", error);

	NSDictionary *totalsTemplate = @{@"EthnicityWhite":     @0,
									 @"EthnicityBlack":     @0,
									 @"EthnicityAsian":     @0,
									 @"EthnicityHispanic":  @0,
									 @"EthnicityOther":     @0,
									 @"GenderFemale":       @0,
									 @"GenderMale":         @0,
									 @"GenderOther":        @0,
									 @"Seniors":            @0,
									 @"FrequencyFirstTime": @0};

	NSMutableDictionary *creditTotals = [totalsTemplate mutableCopy];
	NSMutableDictionary *snapTotals = [totalsTemplate mutableCopy];
	NSMutableDictionary *throwawayTotals = [totalsTemplate mutableCopy]; // this isn't used except for a place to put garbage data

	// iter through each transaction
	for (Transactions *tx in query)
	{
		NSMutableDictionary *activeSet = tx.credit_used ? creditTotals : tx.snap_used ? snapTotals : throwawayTotals;

		if (tx.cust_ethnicity == EthnicityWhite) [activeSet setValue:@([activeSet[@"EthnicityWhite"] intValue] + 1) forKey:@"EthnicityWhite"];
		else if (tx.cust_ethnicity == EthnicityBlack) [activeSet setValue:@([activeSet[@"EthnicityBlack"] intValue] + 1) forKey:@"EthnicityBlack"];
		else if (tx.cust_ethnicity == EthnicityHispanic) [activeSet setValue:@([activeSet[@"EthnicityHispanic"] intValue] + 1) forKey:@"EthnicityHispanic"];
		else if (tx.cust_ethnicity == EthnicityAsian) [activeSet setValue:@([activeSet[@"EthnicityAsian"] intValue] + 1) forKey:@"EthnicityAsian"];
		else if (tx.cust_ethnicity == EthnicityOther) [activeSet setValue:@([activeSet[@"EthnicityOther"] intValue] + 1) forKey:@"EthnicityOther"];

		if (tx.cust_gender == GenderMale) [activeSet setValue:@([activeSet[@"GenderMale"] intValue] + 1) forKey:@"GenderMale"];
		else if (tx.cust_gender == GenderFemale) [activeSet setValue:@([activeSet[@"GenderFemale"] intValue] + 1) forKey:@"GenderFemale"];
		else if (tx.cust_gender == GenderOther) [activeSet setValue:@([activeSet[@"GenderOther"] intValue] + 1) forKey:@"GenderOther"];

		if (tx.cust_senior) [activeSet setValue:@([activeSet[@"Seniors"] intValue] + 1) forKey:@"Seniors"];

		if (tx.cust_frequency == FrequencyFirstTime) [activeSet setValue:@([activeSet[@"FrequencyFirstTime"] intValue] + 1) forKey:@"FrequencyFirstTime"];
	}

	// create the csv string, sort dictionary first (NSDictionary does not keep its order)
	for (NSString *key in [[totalsTemplate allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)])
	{
		NSUInteger creditValue = [[creditTotals objectForKey:key] intValue];
		NSUInteger snapValue = [[snapTotals objectForKey:key] intValue];
		NSUInteger totalValue = creditValue + snapValue;

		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%tu,%tu,%tu\n", key, creditValue, snapValue, totalValue]];
	}

	NSLog(@"prepped demographics report: {\n%@\n}", writeString);
	return [self writeReportToFile:path contents:writeString];
}

// redemptions
- (NSString *)generateRedemptionsReport
{
	NSString *path = [self getReportsPathForReportType:redemptionsReportName];
	return [self generateRedemptionsReportAtPath:path] ? path : false;
}

- (bool)generateRedemptionsReportAtPath:(NSString *)path
{
	if (!self.selectedMarketDay)
	{
		NSLog(@"can't create report: no active market day set");
		return false;
	}

	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"VendorName,CreditTokenCount,CreditValue,SNAPValue,BonusValue,Total\n";
	writeString = [writeString stringByAppendingString:header];

	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Redemptions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];

	NSError *error;
	NSArray *query = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	NSAssert1(!error, @"fetch request failed: %@", error);

	NSDictionary *totals = [@{@"CreditTokenCount": @0,
							  @"CreditValue":      @0,
							  @"SNAPValue":        @0,
							  @"BonusValue":       @0,
							  @"Total":            @0} mutableCopy];

	// iter through each redemption
	for (Redemptions *re in query)
	{
		[totals setValue:@([totals[@"CreditTokenCount"] intValue] + re.credit_count) forKey:@"CreditTokenCount"];
		[totals setValue:@([totals[@"CreditValue"] intValue] + re.credit_amount) forKey:@"CreditValue"];
		[totals setValue:@([totals[@"SNAPValue"] intValue] + re.snap_count) forKey:@"SNAPValue"];
		[totals setValue:@([totals[@"BonusValue"] intValue] + re.bonus_count) forKey:@"BonusValue"];
		[totals setValue:@([totals[@"Total"] intValue] + re.total) forKey:@"Total"];

		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"%@\",%i,%i,%i,%i,%i\n", [(Vendors *)re.vendor businessName], re.credit_count, re.credit_amount, re.snap_count, re.bonus_count, re.total]];
	}

	// totals row
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\n#totals#,%i,%i,%i,%i,%i\n", [totals[@"CreditTokenCount"] intValue], [totals[@"CreditValue"] intValue], [totals[@"SNAPValue"] intValue], [totals[@"BonusValue"] intValue], [totals[@"Total"] intValue]]];

	NSLog(@"prepped redemptions report: {\n%@\n}", writeString);
	return [self writeReportToFile:path contents:writeString];
}

// sales
- (NSString *)generateSalesReport
{
	NSString *path = [self getReportsPathForReportType:salesReportName];
	return [self generateSalesReportAtPath:path] ? path : false;
}

- (bool)generateSalesReportAtPath:(NSString *)path
{
	if (!self.selectedMarketDay)
	{
		NSLog(@"can't create report: no active market day set");
		return false;
	}
	
	NSString *writeString = [[NSString alloc] init];
	NSString *disbursements = @"#Disbursements#\nTokenType,TransactionCount,TokensDisbursed,Value\n";
	writeString = [writeString stringByAppendingString:disbursements];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Transactions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];
	
	NSError *error;
	NSArray *query = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	NSAssert1(!error, @"fetch request failed: %@", error);
	
	NSDictionary *totalsTemplate = @{@"TransactionCount": @0,
									 @"TokensDisbursed":  @0,
									 @"Value":            @0};
	
	NSMutableDictionary *snapTotals = [totalsTemplate mutableCopy];
	NSMutableDictionary *bonusTotals = [totalsTemplate mutableCopy];
	NSMutableDictionary *creditTotals = [totalsTemplate mutableCopy];
	
	NSUInteger creditFeeCount = 0, creditFeeTotal = 0;
	
	// create disbursements table
	for (Transactions *tx in query)
	{
		if (tx.credit_used)
		{
			[creditTotals setValue:@([creditTotals[@"TransactionCount"] intValue] + 1) forKey:@"TransactionCount"];
			[creditTotals setValue:@([creditTotals[@"TokensDisbursed"] intValue] + ceil((tx.credit_total - tx.credit_fee) / 5)) forKey:@"TokensDisbursed"];
			[creditTotals setValue:@([creditTotals[@"Value"] intValue] + (tx.credit_total - tx.credit_fee)) forKey:@"Value"];
			
			if (tx.credit_fee > 0)
			{
				creditFeeCount ++;
				creditFeeTotal += tx.credit_fee;
			}
		}
		if (tx.snap_used)
		{
			[snapTotals setValue:@([snapTotals[@"TransactionCount"] intValue] + 1) forKey:@"TransactionCount"];
			[snapTotals setValue:@([snapTotals[@"TokensDisbursed"] intValue] + (tx.snap_total - tx.snap_bonus)) forKey:@"TokensDisbursed"];
			[snapTotals setValue:@([snapTotals[@"Value"] intValue] + (tx.snap_total - tx.snap_bonus)) forKey:@"Value"];
			
			[bonusTotals setValue:@([bonusTotals[@"TransactionCount"] intValue] + 1) forKey:@"TransactionCount"];
			[bonusTotals setValue:@([bonusTotals[@"TokensDisbursed"] intValue] + tx.snap_bonus) forKey:@"TokensDisbursed"];
			[bonusTotals setValue:@([bonusTotals[@"Value"] intValue] + tx.snap_bonus) forKey:@"Value"];
		}
	}
	
	// create rows
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", @"\"SNAP (Blue)\"", [snapTotals[@"TransactionCount"] intValue], [snapTotals[@"TokensDisbursed"] intValue], [snapTotals[@"Value"] intValue]]];
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", @"\"Bonus (Red)\"", [bonusTotals[@"TransactionCount"] intValue], [bonusTotals[@"TokensDisbursed"] intValue], [bonusTotals[@"Value"] intValue]]];
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", @"\"Credit (Green)\"", [creditTotals[@"TransactionCount"] intValue], [creditTotals[@"TokensDisbursed"] intValue], [creditTotals[@"Value"] intValue]]];
	
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"Token Fee\",%tu,,%tu\n", creditFeeCount, creditFeeTotal]];
	
	NSUInteger transactionCount = [query count], total = ([snapTotals[@"Value"] intValue] + [bonusTotals[@"Value"] intValue] + [creditTotals[@"Value"] intValue]);
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"Total (SNAP + Credit + TokenFee)\",%tu,,%tu\n", transactionCount, total]];
	
	NSUInteger grandtotal = total + creditFeeTotal;
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"Grand Total (SNAP + Bonus + Credit + TokenFee)\",,,%tu\n", grandtotal]];
	
	// create transactions table
	NSString *header = @"\n#Transactions#\nTime,Zipcode,CardLast4,CreditAmount,CreditFee,SNAPAmount,SNAPBonus,Total\n";
	writeString = [writeString stringByAppendingString:header];
	
	NSDateFormatter *txdf = [[NSDateFormatter alloc] init];
	[txdf setDateFormat:@"HH:mm:ss"];
	
	for (Transactions *tx in query)
	{
		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"%@\",\"%@\",%04i,%i,%i,%i,%i,%i\n", [txdf stringFromDate:tx.time], tx.cust_zipcode, tx.cust_id, (tx.credit_total - tx.credit_fee), tx.credit_fee, (tx.snap_total - tx.snap_bonus), tx.snap_bonus, (tx.credit_total + tx.snap_total)]];
	}
	
	NSLog(@"prepped sales report: {\n%@\n}", writeString);
	return [self writeReportToFile:path contents:writeString];
}

// vendors
- (NSString *)generateVendorsReport
{
	NSString *path = [self getReportsPathForReportType:vendorsExportName];
	return [self generateVendorsReportAtPath:path] ? path : false;
}

- (bool)generateVendorsReportAtPath:(NSString *)path
{
	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"BusinessName,ProductTypes,OperatorName,Address,Phone,Email,AcceptsSNAP,AcceptsIncentives,StateTaxID,FederalTaxID\n";
	writeString = [writeString stringByAppendingString:header];
	
	NSError *error;
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Vendors"];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"businessName" ascending:false]]];
	NSArray *query = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	
	for (Vendors *v in query)
	{
		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%i,%i,\"%@\",\"%@\"\n", v.businessName, v.productTypes, v.name, v.address, v.phone, v.email, v.acceptsSNAP, v.acceptsIncentives, v.stateTaxID, v.federalTaxID]];
	}
	
	// TODO: strip null values before they are inserted
	// strip null values
	writeString = [writeString stringByReplacingOccurrencesOfString:@"\"(null)\"" withString:@""];
	
	NSLog(@"prepped vendors export: {\n%@\n}", writeString);
	return [self writeReportToFile:path contents:writeString];
}

// staff
- (NSString *)generateStaffReport
{
	NSString *path = [self getReportsPathForReportType:staffExportName];
	return [self generateStaffReportAtPath:path] ? path : false;
}

- (bool)generateStaffReportAtPath:(NSString *)path
{
	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"Name,Phone,Email,Position\n";
	writeString = [writeString stringByAppendingString:header];
	
	NSError *error;
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MarketStaff"];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:false], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
	NSArray *query = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	
	for (MarketStaff *s in query)
	{
		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",%i\n", s.name, s.phone, s.email, s.position]];
	}
	
	// TODO: strip null values before they are inserted
	// strip null values
	writeString = [writeString stringByReplacingOccurrencesOfString:@"\"(null)\"" withString:@""];
	
	NSLog(@"prepped staff export: {\n%@\n}", writeString);
	return [self writeReportToFile:path contents:writeString];
}

// locations
- (NSString *)generateLocationsReport
{
	NSString *path = [self getReportsPathForReportType:locationsExportName];
	return [self generateLocationsReportAtPath:path] ? path : false;
}

- (bool)generateLocationsReportAtPath:(NSString *)path
{
	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"Name,Address\n";
	writeString = [writeString stringByAppendingString:header];
	
	NSError *error;
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Locations"];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:true]]];
	NSArray *query = [TFMM3_APP_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	
	for (Locations *l in query)
	{
		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\"%@\",\"%@\"\n", l.name, l.address]];
	}
	
	// TODO: strip null values before they are inserted
	// strip null values
	writeString = [writeString stringByReplacingOccurrencesOfString:@"\"(null)\"" withString:@""];
	
	NSLog(@"prepped locations export: {\n%@\n}", writeString);
	return [self writeReportToFile:path contents:writeString];
}

- (NSString *)dump
{
	NSString *path = [self getReportsPathForReportType:dumpName];
	return [self dumpAtPath:path] ? path : false;
}

- (bool)dumpAtPath:(NSString *)path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	@try
	{
		[fm createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
		NSString *dbAt = [[[[TFMM3_APP_DELEGATE.persistentStoreCoordinator persistentStores] lastObject] URL] path];
		
		bool did = [fm copyItemAtPath:dbAt toPath:path error:nil];
		
		NSLog(@"copied database to %@", path);
		return did;
	}
	@catch (NSException *exception)
	{
		NSLog(@"couldn’t copy database: %@", [exception reason]);
		[self setFailureReason:[exception reason]];
	}
	
	if ([fm fileExistsAtPath:path])
	{
		NSDictionary *attribs = [fm attributesOfItemAtPath:path error:nil];
		return [attribs fileSize] > 0;
	}
	else return false;
}

@end
