//
//  MPITextAttributesSeparationViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2020/4/13.
//  Copyright © 2020 美图网. All rights reserved.
//

#import "MPITextAttributesSeparationViewController.h"
#import <MPITextKit.h>

@interface MPITextAttributesSeparationViewController () <MPILabelDelegate>

@end

@implementation MPITextAttributesSeparationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    /**
     Importance: We should use MPITextEntity to separate attachText1's  attributes and attachText2's  attributes, if attachText1's attributes are equal to attachText2's attributes, then attributes wll be merged.
     e.g.1
        NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
        UIFont *font = [UIFont systemFontOfSize:15];
        {
            NSAttributedString *part1 = [[NSAttributedString alloc] initWithString:@"part1" attributes:@{NSFontAttributeName: font}];
            [attributedText appendAttributedString:part1];
        }
        {
            NSAttributedString *part2 = [[NSAttributedString alloc] initWithString:@"part2" attributes:@{NSFontAttributeName: font}];
            [attributedText appendAttributedString:part2];
        }
        NSLog(@"attributedText: %@", attributedText);
        Prints: 『
            attributedText: part1part2{
                NSFont = "<UICTFont: 0x7f8173c08650> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 15.00pt";
            }
        』
        NSFontAttributeName is merged.
     
     e.g.2
         NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
         UIFont *font1 = [UIFont systemFontOfSize:15];
         UIFont *font2 = [UIFont systemFontOfSize:16];
         {
             NSAttributedString *part1 = [[NSAttributedString alloc] initWithString:@"part1" attributes:@{NSFontAttributeName: font1}];
             [attributedText appendAttributedString:part1];
         }
         {
             NSAttributedString *part2 = [[NSAttributedString alloc] initWithString:@"part1" attributes:@{NSFontAttributeName: font2}];
             [attributedText appendAttributedString:part2];
         }
         NSLog(@"attributedText: %@", attributedText);
        Prints: 『
            attributedText: part1{
                NSFont = "<UICTFont: 0x7fb3c9513750> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 15.00pt";
            }part2{
                NSFont = "<UICTFont: 0x7fb3c950aba0> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 16.00pt";
            }
        』
     NSFontAttributeName is not merged because font1 is not equal to font2.
    */
    /** --------------------------------- */
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
    
    UIImage *image = [UIImage imageNamed:@"dribbble64_imageio"];
    image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
    
    MPITextAttachment *attach1 = [MPITextAttachment new];
    attach1.content = image;
    NSMutableAttributedString *attachText1 = [[NSAttributedString attributedStringWithAttachment:attach1] mutableCopy];
    [attachText1 addAttribute:MPITextBackedStringAttributeName value:[MPITextBackedString stringWithString:@"[dribbble]"] range:attachText1.mpi_rangeOfAll];
    
    MPITextEntity *entity1 = [MPITextEntity entityWithValue:@(attributedText.length)];
    [attachText1 addAttribute:MPITextEntityAttributeName value:entity1 range:attachText1.mpi_rangeOfAll];
    
    [attributedText appendAttributedString:attachText1];
    /** --------------------------------- */
    MPITextAttachment *attach2 = [MPITextAttachment new];
    attach2.content = image;
    NSMutableAttributedString *attachText2 = [[NSAttributedString attributedStringWithAttachment:attach2] mutableCopy];
    [attachText2 addAttribute:MPITextBackedStringAttributeName value:[MPITextBackedString stringWithString:@"[dribbble]"] range:attachText1.mpi_rangeOfAll];
    /** Notice:
     - attach1 is equal to attach2
     - entity1 is *not* equal to entity2
     */
    MPITextEntity *entity2 = [MPITextEntity entityWithValue:@(attributedText.length)];
    [attachText2 addAttribute:MPITextEntityAttributeName value:entity2 range:attachText2.mpi_rangeOfAll];
    
    [attributedText appendAttributedString:attachText2];
    
    MPILabel *label = [MPILabel new];
    label.selectable = YES;
    label.delegate = self;
    label.attributedText = attributedText;
    [label sizeToFit];
    label.center = self.view.center;
    [self.view addSubview:label];
    
    NSString *plainText = [attributedText mpi_plainTextForRange:attributedText.mpi_rangeOfAll];
    NSLog(@"plainText: %@", plainText);
}

#pragma mark - MPILabelDelegate

- (void)labelWillBeginSelection:(MPILabel *)label selectedRange:(NSRangePointer)selectedRange {
    *selectedRange = label.attributedText.mpi_rangeOfAll;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
