//
//  MPITextAttachmentsInfo.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextAttachmentsInfo.h"

@implementation MPITextAttachmentInfo

- (instancetype)initWithFrame:(CGRect)frame characterIndex:(NSUInteger)characterIndex {
    self = [super init];
    if (self) {
        _frame = frame;
        _characterIndex = characterIndex;
    }
    return self;
}

@end

@implementation MPITextAttachmentsInfo

- (instancetype)initWithAttachments:(NSArray<MPITextAttachment *> *)attachments
                    attachmentInfos:(NSArray<MPITextAttachmentInfo *> *)attachmentInfos {
    self = [super init];
    if (self) {
        _attachments = attachments;
        _attachmentInfos = attachmentInfos;
    }
    return self;
}

@end
