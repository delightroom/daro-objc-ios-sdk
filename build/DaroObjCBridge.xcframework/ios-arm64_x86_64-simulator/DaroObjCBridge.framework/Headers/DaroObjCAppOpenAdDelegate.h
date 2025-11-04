//
//  DaroObjCAppOpenAdDelegate.h
//  DaroObjCBridge
//
//  Created by Daro SDK Team
//

#import <Foundation/Foundation.h>

@class DaroObjCAppOpenAd;
@class DaroObjCAdInfo;

NS_ASSUME_NONNULL_BEGIN

/// 앱 오픈 광고 이벤트를 처리하는 델리게이트 프로토콜
@protocol DaroObjCAppOpenAdDelegate <NSObject>

@optional

/// 광고 로드 성공
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)appOpenAdDidLoad:(DaroObjCAppOpenAd *)ad
                  adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 로드 실패
/// @param ad 광고 인스턴스
/// @param error 에러 정보
- (void)appOpenAdDidFailToLoad:(DaroObjCAppOpenAd *)ad
                         error:(NSError *)error;

/// 광고 표시됨
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)appOpenAdDidShow:(DaroObjCAppOpenAd *)ad
                  adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 표시 실패
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
/// @param error 에러 정보
- (void)appOpenAdDidFailToShow:(DaroObjCAppOpenAd *)ad
                        adInfo:(DaroObjCAdInfo * _Nullable)adInfo
                         error:(NSError *)error;

/// 광고 클릭됨
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)appOpenAdDidClick:(DaroObjCAppOpenAd *)ad
                   adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 노출 기록됨 (impression)
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)appOpenAdDidRecordImpression:(DaroObjCAppOpenAd *)ad
                              adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

/// 광고 닫힘
/// @param ad 광고 인스턴스
/// @param adInfo 광고 정보
- (void)appOpenAdDidDismiss:(DaroObjCAppOpenAd *)ad
                     adInfo:(DaroObjCAdInfo * _Nullable)adInfo;

@end

NS_ASSUME_NONNULL_END
