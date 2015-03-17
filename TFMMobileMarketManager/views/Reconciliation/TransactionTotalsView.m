//
//  TransactionTotalsView.m
//  TFMMobileMarketManager
//

#import "TransactionTotalsView.h"

@implementation TransactionTotalsView

// removes anything that isn't a number, because the iPad is dumb and keyboard will always have letter keys
- (void)sanitize:(UITextField *)field
{
	[field setText:[[[field text] componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""]];
}

- (void)appendField1Units:(UITextField *)field
{
	[field setText:[[field text] stringByAppendingString:self.field1Prefix]];
	[field setText:[self.field1Suffix stringByAppendingString:[field text]]];
}
- (void)removeField1Units:(UITextField *)field
{
	if ([[field text] rangeOfString:self.field1Prefix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field1Prefix withString:@""]];
	
	if ([[field text] rangeOfString:self.field1Suffix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field1Suffix withString:@""]];
}

- (void)appendField2Units:(UITextField *)field
{
	[field setText:[[field text] stringByAppendingString:self.field2Prefix]];
	[field setText:[self.field2Suffix stringByAppendingString:[field text]]];
}
- (void)removeField2Units:(UITextField *)field
{
	if ([[field text] rangeOfString:self.field2Prefix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field2Prefix withString:@""]];
	
	if ([[field text] rangeOfString:self.field2Suffix].location != NSNotFound)
		[field setText:[[field text] stringByReplacingOccurrencesOfString:self.field2Suffix withString:@""]];
}

// snapField1
- (IBAction)snapField1EditingDidBegin:(id)sender { [self removeField1Units:self.snapField1]; [self sanitize:self.snapField1]; }
- (IBAction)snapField1EditingDidEnd:(id)sender { [self sanitize:self.snapField1]; [self appendField1Units:self.snapField1]; }

// snapField2
- (IBAction)snapField2EditingDidBegin:(id)sender { [self removeField2Units:self.snapField2]; [self sanitize:self.snapField2]; }
- (IBAction)snapField2EditingDidEnd:(id)sender { [self sanitize:self.snapField2]; [self appendField2Units:self.snapField2]; }

// creditField1
- (IBAction)creditField1EditingDidBegin:(id)sender { [self removeField1Units:self.creditField1]; [self sanitize:self.creditField1]; }
- (IBAction)creditField1EditingDidEnd:(id)sender { [self sanitize:self.creditField1]; [self appendField1Units:self.creditField1]; }

// creditField2
- (IBAction)creditField2EditingDidBegin:(id)sender { [self removeField2Units:self.creditField2]; [self sanitize:self.creditField2]; }
- (IBAction)creditField2EditingDidEnd:(id)sender { [self sanitize:self.creditField2]; [self appendField2Units:self.creditField2]; }

// totalField1
- (IBAction)totalField1EditingDidBegin:(id)sender { [self removeField1Units:self.totalField1]; [self sanitize:self.totalField1]; }
- (IBAction)totalField1EditingDidEnd:(id)sender { [self sanitize:self.totalField1]; [self appendField1Units:self.totalField1]; }

// totalField2
- (IBAction)totalField2EditingDidBegin:(id)sender { [self removeField2Units:self.totalField2]; [self sanitize:self.totalField2]; }
- (IBAction)totalField2EditingDidEnd:(id)sender { [self sanitize:self.totalField2]; [self appendField2Units:self.totalField2]; }

@end
