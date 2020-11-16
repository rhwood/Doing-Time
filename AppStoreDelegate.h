//
//  AppStoreDelegate.h
//  Doing Time
//
//  Created by Randall Wood on 4/4/2011.
//
//  Copyright 2011-2014, 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
