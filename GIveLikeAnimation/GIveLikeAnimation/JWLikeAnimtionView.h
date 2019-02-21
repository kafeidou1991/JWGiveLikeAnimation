//
//  JWLikeAnimtionView.h
//  GIveLikeAnimation
//
//  Created by 张竟巍 on 2019/2/20.
//  Copyright © 2019 张竟巍. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 点赞操作处理回调

 @param isLike 是否是点赞
 */
typedef void(^JWLikeExcuBlock)(BOOL isLike);

@interface JWLikeAnimtionView : UIView
/**
 动画持续时间 默认是0.5
 */
@property (nonatomic, assign) NSTimeInterval animationDurtion;

/**
 三角形 圆圈颜色
 */
@property (nonatomic, strong) UIColor * shapeFillColor;

/**
 操作回调，可用于网络请求
 */
@property (nonatomic, copy) JWLikeExcuBlock  likeBlock;

@end

NS_ASSUME_NONNULL_END
