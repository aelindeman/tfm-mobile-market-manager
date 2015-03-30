//
//  ReportGenerator.m
//  TFMMobileMarketManager
//

#import "ReportGenerator.h"

@implementation ReportGenerator

static NSString *reportsSubfolder = @"Reports"; // relative to application's documents directory
static NSString *marketDaySubfolder = @"%@"; // relative to reports subfolder, replace token with market day name

// relative to market day subfolder
// replace token with timestamp of report generation
static NSString *demographicsReportName = @"Demographics-%@.csv";
static NSString *salesReportName = @"Sales-%@.csv";
static NSString *redemptionsReportName = @"Redemptions-%@.csv";

// allow init using delegate's active market day
- (id)init
{
	NSAssert([TFM_DELEGATE activeMarketDay], @"No active market day set! Use -initWithMarketDay:marketDay to specify one if not active");
	return [self initWithMarketDay:[TFM_DELEGATE activeMarketDay]];
}

// market day needs to be specified before generating a report
- (id)initWithMarketDay:(MarketDays *)marketDay
{
	if (self = [super init])
	{
		//NSAssert(marketDay, @"No active market day set! Use -initWithMarketDay:marketDay to specify one if not active");
		_selectedMarketDay = marketDay;
	}
	return self;
}

// creates demographics report at default path; returns path
- (NSString *)generateDemographicsReport
{
	NSString *path = [NSString pathWithComponents:@[[TFM_DELEGATE.applicationDocumentsDirectory path],
													reportsSubfolder,
													[NSString stringWithFormat:marketDaySubfolder, [self.selectedMarketDay description]],
													[NSString stringWithFormat:demographicsReportName, round(NSTimeIntervalSince1970)]]];
	[self generateDemographicsReportAtPath:path];
	return path;
}

// creates demographics report at specific path
- (void)generateDemographicsReportAtPath:(NSString *)path
{
	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"CustomerType,Credit,SNAP,Total\n";
	writeString = [writeString stringByAppendingString:header];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Transactions"];
	//[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];
	
	NSError *error;
	NSArray *query = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	NSAssert1(!error, @"fetch request failed: %@", error);
	
	// NSDictionary maybe isn't the best data type for this but I don't feel like making a new one just yet
	NSDictionary *totalsTemplate = @{@"EthnicityWhite":     @0,
									 @"EthnicityBlack":     @0,
									 @"EthnicityAsian":     @0,
									 @"EthnicityHispanic":  @0,
									 @"EthnicityOther":     @0,
									 @"GenderFemale":       @0,
									 @"GenderMale":         @0,
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
		
		if (tx.cust_gender) [activeSet setValue:@([activeSet[@"GenderMale"] intValue] + 1) forKey:@"GenderMale"];
		else [activeSet setValue:@([activeSet[@"GenderFemale"] intValue] + 1) forKey:@"GenderFemale"];
		
		if (tx.cust_senior) [activeSet setValue:@([activeSet[@"Seniors"] intValue] + 1) forKey:@"Seniors"];
	
		if (tx.cust_frequency == FrequencyFirstTime) [activeSet setValue:@([activeSet[@"FrequencyFirstTime"] intValue] + 1) forKey:@"FrequencyFirstTime"];
	}
	
	// create the csv string
	for (NSString *key in totalsTemplate)
	{
		int creditValue = [[creditTotals objectForKey:key] intValue];
		int snapValue = [[snapTotals objectForKey:key] intValue];
		int totalValue = creditValue + snapValue;
		
		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", key, creditValue, snapValue, totalValue]];
	}
	
	NSLog(@"prepped demographics report: {\n%@\n}", writeString);
	
	// write the csv
	NSFileHandle *fh;
	@try
	{
		// create demographics report directory and csv file
		NSFileManager *fm = [NSFileManager defaultManager];
		[fm createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
		[fm createFileAtPath:path contents:nil attributes:nil];
		
		// open the file for writing
		fh = [NSFileHandle fileHandleForWritingAtPath:path];
		[fh truncateFileAtOffset:[fh seekToEndOfFile]];
		[fh writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
		
		//NSLog(@"wrote demographics report to %@", path);
	}
	@catch (NSException *exception)
	{
		NSLog(@"couldn’t write demographics report: %@", [exception reason]);
	}
	@finally
	{
		[fh closeFile];
	}
}

// redemptions
- (NSString *)generateRedemptionsReport
{
	NSString *path = [NSString pathWithComponents:@[[TFM_DELEGATE.applicationDocumentsDirectory path],
													reportsSubfolder,
													[NSString stringWithFormat:marketDaySubfolder, [self.selectedMarketDay description]],
													[NSString stringWithFormat:redemptionsReportName, round(NSTimeIntervalSince1970)]]];
	[self generateRedemptionsReportAtPath:path];
	return path;
}

- (void)generateRedemptionsReportAtPath:(NSString *)path
{

}

// sales
- (NSString *)generateSalesReport
{
	NSString *path = [NSString pathWithComponents:@[[TFM_DELEGATE.applicationDocumentsDirectory path],
													reportsSubfolder,
													[NSString stringWithFormat:marketDaySubfolder, [self.selectedMarketDay description]],
													[NSString stringWithFormat:salesReportName, round(NSTimeIntervalSince1970)]]];
	[self generateSalesReportAtPath:path];
	return path;
}

- (void)generateSalesReportAtPath:(NSString *)path
{
	
}

@end
