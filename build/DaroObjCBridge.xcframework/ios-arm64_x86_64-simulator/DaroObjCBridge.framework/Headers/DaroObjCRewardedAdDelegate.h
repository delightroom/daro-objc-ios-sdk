//
//  DaroObjCRewardedAdDelegate.h
//  DaroObjCBridge
//
//  Created by Daro SDK Team
//

#import <Foundation/Foundation.h>

@class DaroObjCRewardedAd;
@class DaroObjCAdInfo;
@class DaroObjCRewardedItem;

NS_ASSUME_NONNULL_BEGIN

/// 리워드 광고 이벤트를 처리하는 델리게이트 프로토콜
@protocol DaroObjCRewardedAdDelegate <NSObject>

@optional

/// 광고 로드 성공
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)rewardedAdDidLoad:(DaroObjCRewardedAd *)ad
                   adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 로드 실패
/// @param ad 광고 인스턴스
/// @param error 에러 정보
- (void)rewardedAdDidFailToLoad:(DaroObjCRewardedAd *)ad
                          error:(NSError *)error;

/// 광고 표시됨
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)rewardedAdDidShow:(DaroObjCRewardedAd *)ad
                   adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 표시 실패
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
/// @param error 에러 정보
- (void)rewardedAdDidFailToShow:(DaroObjCRewardedAd *)ad
                         adInfo:(DaroObjCAdInfo * _Nullable)adInfo
                          error:(NSError *)error;

/// 리워드 획득 (가장 중요한 콜백)
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
/// @param item 리워드 아이템 정보
- (void)rewardedAdDidEarnReward:(DaroObjCRewardedAd *)ad
                         adInfo:(DaroObjCAdInfo * _Nullable)adInfo
                   rewardedItem:(DaroObjCRewardedItem *)item;

/// 광고 클릭됨
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)rewardedAdDidClick:(DaroObjCRewardedAd *)ad
                    adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 노출 기록됨 (impression)
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)rewardedAdDidRecordImpression:(DaroObjCRewardedAd *)ad
                               adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 닫힘
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)rewardedAdDidDismiss:(DaroObjCRewardedAd *)ad
                      adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

@end

NS_ASSUME_NONNULL_END
