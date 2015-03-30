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
static NSString *demographicsReportName = @"Demographics-%.0f.csv";
static NSString *salesReportName = @"Sales-%.0f.csv";
static NSString *redemptionsReportName = @"Redemptions-%.0f.csv";

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
		NSAssert(marketDay, @"No active market day set! Use -initWithMarketDay:marketDay to specify one if not active");
		_selectedMarketDay = marketDay;
	}
	return self;
}

// writes contents to file, creating the file and path on the way
- (void)writeReportToFile:(NSString *)path contents:(NSString *)contents
{
	NSFileHandle *fh;
	@try
	{
		// create report directory and csv file
		NSFileManager *fm = [NSFileManager defaultManager];
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
}

// creates the reports path
- (NSString *)getReportsPathForReportType:(NSString*)reportName
{
	return [NSString pathWithComponents:@[[TFM_DELEGATE.applicationDocumentsDirectory path],
										  reportsSubfolder,
										  [NSString stringWithFormat:marketDaySubfolder, [self.selectedMarketDay description]],
										  [NSString stringWithFormat:reportName, [[NSDate date] timeIntervalSince1970]]]];
}

// creates demographics report at default path; returns path
- (NSString *)generateDemographicsReport
{
	NSString *path = [self getReportsPathForReportType:demographicsReportName];
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
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];

	NSError *error;
	NSArray *query = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	NSAssert1(!error, @"fetch request failed: %@", error);

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
	[self writeReportToFile:path contents:writeString];
}

// redemptions
- (NSString *)generateRedemptionsReport
{
	NSString *path = [self getReportsPathForReportType:redemptionsReportName];
	[self generateRedemptionsReportAtPath:path];
	return path;
}

- (void)generateRedemptionsReportAtPath:(NSString *)path
{
	NSString *writeString = [[NSString alloc] init];
	NSString *header = @"VendorName,CreditTokenCount,CreditValue,SNAPValue,BonusValue,Total\n";
	writeString = [writeString stringByAppendingString:header];

	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Redemptions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];

	NSError *error;
	NSArray *query = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
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

		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"'%@',%i,%i,%i,%i,%i\n", [(Vendors *)re.vendor businessName], re.credit_count, re.credit_amount, re.snap_count, re.bonus_count, re.total]];
	}

	// totals row
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"\n#totals#,%i,%i,%i,%i,%i\n", [totals[@"CreditTokenCount"] intValue], [totals[@"CreditValue"] intValue], [totals[@"SNAPValue"] intValue], [totals[@"BonusValue"] intValue], [totals[@"Total"] intValue]]];

	NSLog(@"prepped redemptions report: {\n%@\n}", writeString);
	[self writeReportToFile:path contents:writeString];
}

// sales
- (NSString *)generateSalesReport
{
	NSString *path = [self getReportsPathForReportType:salesReportName];
	[self generateSalesReportAtPath:path];
	return path;
}

- (void)generateSalesReportAtPath:(NSString *)path
{
	NSString *writeString = [[NSString alloc] init];
	NSString *disbursements = @"#Disbursements#\nTokenType,TransactionCount,TokensDisbursed,Value\n";
	writeString = [writeString stringByAppendingString:disbursements];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Transactions"];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(marketday = %@) and (markedInvalid = false)", [self selectedMarketDay]]];
	
	NSError *error;
	NSArray *query = [TFM_DELEGATE.managedObjectContext executeFetchRequest:request error:&error];
	NSAssert1(!error, @"fetch request failed: %@", error);
	
	NSDictionary *totalsTemplate = @{@"TransactionCount": @0,
									 @"TokensDisbursed":  @0,
									 @"Value":            @0};
	
	NSMutableDictionary *snapTotals = [totalsTemplate mutableCopy];
	NSMutableDictionary *bonusTotals = [totalsTemplate mutableCopy];
	NSMutableDictionary *creditTotals = [totalsTemplate mutableCopy];
	
	unsigned int creditFeeCount = 0, creditFeeTotal = 0;
	
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
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", @"'SNAP (Blue)'", [snapTotals[@"TransactionCount"] intValue], [snapTotals[@"TokensDisbursed"] intValue], [snapTotals[@"Value"] intValue]]];
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", @"'Bonus (Red)'", [bonusTotals[@"TransactionCount"] intValue], [bonusTotals[@"TokensDisbursed"] intValue], [bonusTotals[@"Value"] intValue]]];
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"%@,%i,%i,%i\n", @"'Credit (Green)'", [creditTotals[@"TransactionCount"] intValue], [creditTotals[@"TokensDisbursed"] intValue], [creditTotals[@"Value"] intValue]]];
	
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"'Token Fee',%i,,%i\n", creditFeeCount, creditFeeTotal]];
	
	unsigned int transactionCount = [query count], total = ([snapTotals[@"Value"] intValue] + [bonusTotals[@"Value"] intValue] + [creditTotals[@"Value"] intValue]);
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"'Total (SNAP + Credit + TokenFee)',%i,,%i\n", transactionCount, total]];
	
	unsigned int grandtotal = total + creditFeeTotal;
	writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"'Grand Total (SNAP + Bonus + Credit + TokenFee)',,,%i\n", grandtotal]];
	
	// create transactions table
	NSString *header = @"\n#Transactions#\nuuid,Zipcode,License,CreditAmount,CreditFee,SNAPAmount,SNAPBonus,Total\n";
	writeString = [writeString stringByAppendingString:header];
	
	for (Transactions *tx in query)
	{
		writeString = [writeString stringByAppendingString:[NSString stringWithFormat:@"'%@','%@',%04i,%i,%i,%i,%i,%i\n", [tx objectID], tx.cust_zipcode, tx.cust_id, (tx.credit_total - tx.credit_fee), tx.credit_fee, (tx.snap_total - tx.snap_bonus), tx.snap_bonus, (tx.credit_total + tx.snap_total)]];
	}
	
	NSLog(@"prepped sales report: {\n%@\n}", writeString);
	[self writeReportToFile:path contents:writeString];
}

@end
