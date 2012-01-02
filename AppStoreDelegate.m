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

@synthesize openRequests = _openRequests;
@synthesize validProducts = _validProducts;
@synthesize transactionStore = _transactionStore;
@synthesize products = _products;

- (id)initWithDictionary:(NSDictionary *)transactionStore {
	if ((self = [super init])) {
		self.transactionStore = [NSMutableDictionary dictionaryWithDictionary:transactionStore];
		self.products = [NSMutableDictionary dictionaryWithCapacity:0];
		self.openRequests = [NSMutableSet setWithCapacity:0];
		self.validProducts = [NSMutableArray arrayWithCapacity:0];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

#pragma mark -
#pragma mark Store handling

- (BOOL)canMakePayments {
	return [SKPaymentQueue canMakePayments];
}

- (BOOL)hasDataForAllProducts {
	return ([self.products count] == [self.validProducts count]);
}

- (BOOL)hasDataForAnyProducts {
	return ([self.validProducts count]);
}

- (BOOL)hasProductData:(NSString *)productIdentifier {
	return ([self productData:productIdentifier]) ? YES : NO;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	for (SKProduct *product in response.products) {
		[self.products setObject:product forKey:product.productIdentifier];
		if (![self.validProducts containsObject:product.productIdentifier]) {
			[self.validProducts addObject:product.productIdentifier];
		}
		[self.openRequests removeObject:product.productIdentifier];
	}
	for (NSString *productIdentifier in response.invalidProductIdentifiers) {
		[self.openRequests removeObject:productIdentifier];
		[self.validProducts removeObject:productIdentifier];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreDidReceiveProductsList
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:self.validProducts
																						   forKey:AXAppStoreProducts]];
}

- (SKProduct *)productData:(NSString *)productIdentifier {
	if (![self.products objectForKey:productIdentifier]) {
		// ensure product is in self.products so that self.products count can be compared to self.transactionStore count
		[self.products setObject:[NSNull null] forKey:productIdentifier];
	}
	return [self.products objectForKey:productIdentifier];
}

- (void)requestProductData:(NSString *)productIdentifier {
	if (![self.openRequests containsObject:productIdentifier]) {
		SKProductsRequest *request = [[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productIdentifier]] autorelease];
		request.delegate = self;
		// ensure product is in self.products so that self.products count can be compared to self.transactionStore count
		if (![self.products objectForKey:productIdentifier]) {
			[self.products setObject:[NSNull null] forKey:productIdentifier];
		}
		[request start];
		[self.openRequests addObject:productIdentifier];
	} else {
	}
}

- (void)requestProductData:(NSString *)productIdentifier ifHasTransaction:(BOOL)hasTransaction {
	if (![self hasTransactionForProduct:productIdentifier]) {
		[self requestProductData:productIdentifier];
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreRequestFailed
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:error
																						   forKey:AXAppStoreRequestError]];
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

- (BOOL)hasTransactionsForAllProducts {
	return ([self.transactionStore count] == [self.products count]);
}

- (BOOL)hasTransactionForProduct:(NSString *)productIdentifier {
	// ensure product is in self.products so that self.products count can be compared to self.transactionStore count
	[self productData:productIdentifier];
	return ([self.transactionStore valueForKey:productIdentifier]) ? YES : NO;
}

- (void)provideContent:(NSString *)productIdentifier {
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreNewContentShouldBeProvided
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:productIdentifier
																						   forKey:AXAppStoreProductIdentifier]];
}

- (void)queuePaymentForProduct:(SKProduct *)product {
	[self queuePaymentForProduct:product withQuantity:1];
}

- (void)queuePaymentForProduct:(SKProduct *)product withQuantity:(NSUInteger)quantity {
	SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
	payment.quantity = quantity;
	[[SKPaymentQueue defaultQueue] addPayment:payment];	
}

- (void)queuePaymentForProductIdentifier:(NSString *)productIdentifier {
	[self queuePaymentForProductIdentifier:productIdentifier withQuantity:1];
}

- (void)queuePaymentForProductIdentifier:(NSString *)productIdentifier withQuantity:(NSUInteger)quantity {
	SKMutablePayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
	payment.quantity = quantity;
	[[SKPaymentQueue defaultQueue] addPayment:payment];	
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
