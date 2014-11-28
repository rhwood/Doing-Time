//
//  AppStoreDelegate.m
//  Doing Time
//
//  Created by Randall Wood on 4/4/2011.
//
//  Copyright (c) 2011-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AppStoreDelegate.h"
#import "CargoBay.h"

#if TARGET_IPHONE_SIMULATOR
    #define BYPASS_STORE 0 // 0 to see as without purchases 1 to see as with purchases
#else
    #define BYPASS_STORE 0
#endif

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
        [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
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
        }];
        [[CargoBay sharedManager] setPaymentQueueRestoreCompletedTransactionsWithSuccess:nil
                                                                                 failure:^(SKPaymentQueue *queue, NSError *error) {
                                                                                     if (error.code != SKErrorPaymentCancelled) {
                                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionFailed
                                                                                                                                             object:self
                                                                                                                                           userInfo:@{AXAppStoreTransactionError: error}];
                                                                                     } else {
                                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionCancelled
                                                                                                                                             object:self
                                                                                                                                           userInfo:nil];
                                                                                     }
                                                                                 }];
 		[[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
	}
	return self;
}

#pragma mark - Store handling

- (BOOL)canMakePayments {
    NSLog(@"SKPaymentQueue canMakePayments:%i", [SKPaymentQueue canMakePayments]);
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

- (SKProduct *)productData:(NSString *)productIdentifier {
	if (![self.products objectForKey:productIdentifier]) {
		// ensure product is in self.products so that self.products count can be compared to self.transactionStore count
		[self.products setObject:[NSNull null] forKey:productIdentifier];
	}
	return [self.products objectForKey:productIdentifier];
}

- (void)requestProductData:(NSString *)productIdentifier {
    [[CargoBay sharedManager] productsWithIdentifiers:[NSSet setWithObject:productIdentifier]
                                              success:^(NSArray *products, NSArray *invalidIdentifiers) {
                                                  for (SKProduct *product in products) {
                                                      [self.products setObject:product forKey:product.productIdentifier];
                                                      if (![self.validProducts containsObject:product.productIdentifier]) {
                                                          [self.validProducts addObject:product.productIdentifier];
                                                      }
                                                  }
                                                  for (NSString *productIdentifier in invalidIdentifiers) {
                                                      [self.validProducts removeObject:productIdentifier];
                                                  }
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreDidReceiveProductsList
                                                                                                      object:self
                                                                                                    userInfo:@{AXAppStoreProducts: self.validProducts}];
                                                  
                                              }
                                              failure:^(NSError *error) {
                                                  [self request:nil didFailWithError:error];
                                              }];
}

- (void)requestProductData:(NSString *)productIdentifier ifHasTransaction:(BOOL)hasTransaction {
	if (![self hasTransactionForProduct:productIdentifier]) {
		[self requestProductData:productIdentifier];
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreRequestFailed
                                                            object:self
                                                          userInfo:@{AXAppStoreRequestError: error}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreRequestFailed
                                                            object:self];
    }
}

#pragma mark - Payment transaction handling

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
	[self recordTransaction:transaction];
	[self provideContent:transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	if (transaction.error.code != SKErrorPaymentCancelled) {
		[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionFailed
															object:self
														  userInfo:@{
                                       AXAppStoreProductIdentifier: (transaction.payment.productIdentifier) ? transaction.payment.productIdentifier : [NSNull null],
                                        AXAppStoreTransactionError: (transaction.error) ? transaction.error : [NSNull null]}
         ];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreTransactionCancelled
															object:self
														  userInfo:@{AXAppStoreProductIdentifier: transaction.payment.productIdentifier}];
	}
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (BOOL)hasTransactionsForAllProducts {
	return ([self.transactionStore count] == [self.products count]);
}

- (BOOL)hasTransactionForProduct:(NSString *)productIdentifier {
	// ensure product is in self.products so that self.products count can be compared to self.transactionStore count
	[self productData:productIdentifier];
    // TODO: Ensure that this logic cannot be fouled by moving BYPASS_STORE to a #if precompilation test
	return ([self.transactionStore valueForKey:productIdentifier] || BYPASS_STORE) ? YES : NO;
}

- (void)provideContent:(NSString *)productIdentifier {
	[[NSNotificationCenter defaultCenter] postNotificationName:AXAppStoreNewContentShouldBeProvided
														object:self
													  userInfo:@{AXAppStoreProductIdentifier: productIdentifier}];
}

- (void)queuePaymentForProduct:(SKProduct *)product {
	[self queuePaymentForProduct:product withQuantity:1];
}

- (void)queuePaymentForProduct:(SKProduct *)product withQuantity:(NSUInteger)quantity {
	SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
	payment.quantity = quantity;
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
	if (transaction.transactionState == SKPaymentTransactionStateRestored) {
		[self.transactionStore setValue:transaction.transactionIdentifier forKey:transaction.originalTransaction.payment.productIdentifier];
	} else {
		[self.transactionStore setValue:transaction.transactionIdentifier forKey:transaction.payment.productIdentifier];
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

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
