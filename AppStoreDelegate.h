//
//  AppStoreDelegate.h
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

@interface AppStoreDelegate : NSObject {

	NSMutableSet *_openRequests;
	NSMutableArray *_validProducts;
	NSMutableDictionary *_transactionStore;
	NSMutableDictionary *_products;

}

- (id)initWithDictionary:(NSDictionary *)transactionStore;

#pragma mark - Store handling

@property (readonly) BOOL canMakePayments;
@property (nonatomic, strong) NSMutableSet *openRequests;
@property (nonatomic, strong) NSMutableArray *validProducts;
- (BOOL)hasDataForAllProducts;
- (BOOL)hasDataForAnyProducts;
- (BOOL)hasProductData:(NSString *)productIdentifier;
- (SKProduct *)productData:(NSString *)productIdentifier;
- (void)requestProductData:(NSString *)productIdentifier;
- (void)requestProductData:(NSString *)productIdentifier ifHasTransaction:(BOOL)hasTransaction;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;

#pragma mark - Payment transaction handling

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (BOOL)hasTransactionsForAllProducts;
- (BOOL)hasTransactionForProduct:(NSString *)productIdentifier;
- (void)provideContent:(NSString *)productIdentifier;
- (void)queuePaymentForProduct:(SKProduct *)product;
- (void)queuePaymentForProduct:(SKProduct *)product withQuantity:(NSUInteger)quantity;
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreCompletedTransactions;

@property (nonatomic, strong) NSMutableDictionary *transactionStore;
@property (nonatomic, strong) NSMutableDictionary *products;

@end
