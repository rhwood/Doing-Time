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
	NSMutableDictionary *_products;

}

#pragma mark -
#pragma mark Store handling

@property (readonly) BOOL canMakePayments;
- (BOOL)hasDataForAllProducts;
- (BOOL)hasProductData:(NSString *)productIdentifier;
- (SKProduct *)productData:(NSString *)productIdentifier;
- (void)requestProductData:(NSString *)productIdentifier;
- (void)requestProductData:(NSString *)productIdentifier ifHasTransaction:(BOOL)hasTransaction;
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;

#pragma mark -
#pragma mark Payment transaction handling

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (BOOL)hasTransactionsForAllProducts;
- (BOOL)hasTransactionForProduct:(NSString *)productIdentifier;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)provideContent:(NSString *)productIdentifier;
- (void)queuePaymentForProduct:(SKProduct *)product;
- (void)queuePaymentForProduct:(SKProduct *)product withQuantity:(NSUInteger)quantity;
- (void)queuePaymentForProductIdentifier:(NSString *)productIdentifier;
- (void)queuePaymentForProductIdentifier:(NSString *)productIdentifier withQuantity:(NSUInteger)quantity;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

@property (nonatomic, retain) NSMutableDictionary *transactionStore;
@property (nonatomic, retain) NSMutableDictionary *products;

@end
