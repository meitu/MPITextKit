//
//  MPITextCustomAttributeViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/4/19.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextCustomAttributeViewController.h"
#import <MPITextKit/MPITextKit.h>
#import "MPIExampleAttachment.h"
#import "MPIExampleBackground.h"
#import "MPIExampleHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MPITextCustomAttributeViewController () <MPILabelDelegate>

@end

@implementation MPITextCustomAttributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
    
    UIFont *font = [UIFont systemFontOfSize:30];
    UIImage *image = [UIImage imageNamed:@"icon_text_tag_link"];
    
    MPIExampleAttachment *attachment = [[MPIExampleAttachment alloc] initWithImage:image];
    attachment.contentSize = CGSizeMake(font.pointSize, font.pointSize);
    NSAttributedString *attachmentAttributedString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attributedText appendAttributedString:attachmentAttributedString];
    
    MPITextAttachment *spacingAttachment = [MPITextAttachment new];
    spacingAttachment.contentSize = CGSizeMake(5, 0);
    NSAttributedString *spacingAttachmentAttributedString = [NSAttributedString attributedStringWithAttachment:spacingAttachment];
    [attributedText appendAttributedString:spacingAttachmentAttributedString];
    
    NSAttributedString *linkAttributedText = [[NSAttributedString alloc] initWithString:@"Tap Me"];
    [attributedText appendAttributedString:linkAttributedText];
    
    UIColor *textColor = [UIColor colorWithRed:56 / 255.0 green:146 / 255.0 blue:224 / 255.0 alpha:1.0];
    [attributedText addAttribute:NSForegroundColorAttributeName value:textColor range:attributedText.mpi_rangeOfAll];
    [attributedText addAttribute:NSFontAttributeName value:font range:attributedText.mpi_rangeOfAll];
    [attributedText addAttribute:MPITextLinkAttributeName value:MPITextLink.new range:attributedText.mpi_rangeOfAll];
    
    MPILabel *label = [MPILabel new];
    label.highlightedLinkTextAttributes = nil;
    label.delegate = self;
    label.attributedText = attributedText;
    [label sizeToFit];
    label.center = self.view.center;
    
    [self.view addSubview:label];
    
    /*
    MPIExampleBackground *background = [MPIExampleBackground backgroundWithFillColor:[UIColor redColor] cornerRadius:5];
    background.height = 30; // fixed height.
     **/
}

#pragma mark - MPITextViewDelegate

- (NSDictionary *)label:(MPILabel *)label highlightedTextAttributesWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange {
    UIColor *textColor = [attributedText attribute:NSForegroundColorAttributeName
                                           atIndex:characterRange.location
                                    effectiveRange:NULL];
    textColor = [textColor colorWithAlphaComponent:0.5];
    if (textColor) {
        return @{NSForegroundColorAttributeName: textColor};
    }
    
    return nil;
}

@end
