//
//  AppStoreDelegate.m
//  Doing Time
//
//  Created by Randall Wood on 4/4/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "AppStoreDelegate.h"

NSString *const AXAppStoreDidReceiveProductsList = @"AXAppStoreDidReceiveProductsList";
NSString *const AXAppStoreNewContentShouldBeProvided = @"AXAppStoreNewContentShouldBeProvided";
NSString *const AXAppStoreProducts = @"AXAppStoreProducts";
NSString *const AXAppStoreProductIdentifier = @"AXAppStoreProductIdentifier";
NSString *const AXAppStoreRequestError = @"AXAppStoreRequestError";
NSString *const AXAppStoreRequestFailed = @"AXAppStoreRequestFailed";
NSString *const AXAppStoreTransactionCancelled = @"AXAppStoreTransactionCancelled";
NSString *const AXAppStoreTransactionError = @"AXAppStoreTransactionError";
NSString *const AXAppStoreTransactionFailed = @"AXAppStoreTransactionFailed";
NSString *const AXAppStoreTransactionShouldBeRecorded = @"AXAppStoreTransactionShouldBeRecorded";
NSString *const AXAppStoreTransactionStore = @"AXAppStoreTransactionStore";

@implementation AppStoreDelegate

@synthesize transactionStore = _transactionStore;
@synthesize products = _products;

- (id)initWithDictionary:(NSDictionary *)transactionStore {
	if (self = [super init]) {
		self.transactionStore = [NSMutableDictionary dictionaryWithDictionary:transactionStore];
		self.products = [NSMutableArray arrayWithCapacity:0];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

#pragma mark -
#pragma mark Store handling

- (BOOL)canMakePayments {
	return [SKPaymentQueue canMakePayments];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	[self.products addObjectsFromArray:response.products];
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreDidReceiveProductsList
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:self.products
																						   forKey:AXAppStoreProducts]];
	[request release];
}

- (void)requestProductData:(NSString *)productIdentifier {
	SKProductsRequest *request = [[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productIdentifier]] autorelease];
	request.delegate = self;
	[request start];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreRequestFailed
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:error
																						   forKey:AXAppStoreRequestError]];
	[request release];
}

#pragma mark -
#pragma mark Payment transaction handling

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
			default:
				break;
		}
	}
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
	[self recordTransaction:transaction];
	[self provideContent:transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	if (transaction.error.code != SKErrorPaymentCancelled) {
		[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionFailed
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:transaction.payment.productIdentifier,
																	AXAppStoreProductIdentifier,
																	transaction.error,
																	AXAppStoreTransactionError,
																	nil]];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionCancelled
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:transaction.payment.productIdentifier
																							   forKey:AXAppStoreProductIdentifier]];
	}
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (BOOL)hasTransactionForProduct:(NSString *)productIdentifier {
	return ([self.transactionStore valueForKey:productIdentifier]) ? YES : NO;
}

- (void)provideContent:(NSString *)productIdentifier {
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreNewContentShouldBeProvided
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:productIdentifier
																						   forKey:AXAppStoreProductIdentifier]];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
	if (transaction.transactionState == SKPaymentTransactionStateRestored) {
		[self.transactionStore setValue:transaction.transactionReceipt forKey:transaction.originalTransaction.payment.productIdentifier];
	} else {
		[self.transactionStore setValue:transaction.transactionReceipt forKey:transaction.payment.productIdentifier];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionShouldBeRecorded
														object:self
													  userInfo:nil];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
	[self recordTransaction:transaction];
	[self provideContent:transaction.originalTransaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
