//
//  AppStoreDelegate.h
//  Doing Time
//
//  Created by Randall Wood on 4/4/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Constants.h"

extern NSString *const AXAppStoreDidReceiveProductsList;
extern NSString *const AXAppStoreNewContentShouldBeProvided;
extern NSString *const AXAppStoreProductIdentifier;
extern NSString *const AXAppStoreProducts;
extern NSString *const AXAppStoreRequestError;
extern NSString *const AXAppStoreRequestFailed;
extern NSString *const AXAppStoreTransactionCancelled;
extern NSString *const AXAppStoreTransactionError;
extern NSString *const AXAppStoreTransactionFailed;
extern NSString *const AXAppStoreTransactionShouldBeRecorded;
extern NSString *const AXAppStoreTransactionStore;

@interface AppStoreDelegate : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate> {

	NSMutableDictionary *_transactionStore;
	NSMutableArray *_products;

}

#pragma mark -
#pragma mark Store handling

@property (readonly) BOOL canMakePayments;
- (void)requestProductData:(NSString *)productIdentifier;
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;

#pragma mark -
#pragma mark Payment transaction handling

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (BOOL)hasTransactionForProduct:(NSString *)productIdentifier;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)provideContent:(NSString *)productIdentifier;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

@property (nonatomic, retain) NSMutableDictionary *transactionStore;
@property (nonatomic, retain) NSMutableArray *products;

@end
