//
//  MPITextAttachmentsInfo.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MPITextAttachment;

@interface MPITextAttachmentInfo : NSObject

@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, assign, readonly) NSUInteger characterIndex;

- (instancetype)initWithFrame:(CGRect)frame characterIndex:(NSUInteger)characterIndex;

@end

@interface MPITextAttachmentsInfo : NSObject

/**
 Array of `MPITextAttachment`
 */
@property (nonatomic, strong, readonly) NSArray<MPITextAttachment *> *attachments;

@property (nonatomic, strong, readonly) NSArray<MPITextAttachmentInfo *> *attachmentInfos;

- (instancetype)initWithAttachments:(NSArray<MPITextAttachment *> *)attachments
                    attachmentInfos:(NSArray<MPITextAttachmentInfo *> *)attachmentInfos;

@end

NS_ASSUME_NONNULL_END
