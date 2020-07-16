//
//  MPIFeaturesComparisonViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2020/7/16.
//  Copyright © 2020 美图网. All rights reserved.
//

#import "MPIFeaturesComparisonViewController.h"
#import "MPIExampleHelper.h"
#import <MPITextKit.h>

@interface MPIFeaturesComparisonViewController ()

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic) MPILabel *mpiLabel;
@property (nonatomic) UILabel *uiLabel;

@property (nonatomic) NSMutableAttributedString *text;
@property (nonatomic) NSMutableDictionary *attributes;
@property (nonatomic) NSParagraphStyle *paragraphStyle;
@property (nonatomic) NSInteger maxNumberOfLines;

@end

@implementation MPIFeaturesComparisonViewController


#define ParagraphStyleAttriSet(_attri_) \
NSMutableParagraphStyle *paragraphStyle = self.paragraphStyle.mutableCopy; \
paragraphStyle. _attri_ = _attri_; \
self.paragraphStyle = paragraphStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.hyphenationFactor = 1;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.paragraphSpacing = 0;
    self.paragraphStyle = paragraphStyle;
    self.maxNumberOfLines = 11;
    
    self.attributes =
    [@{NSFontAttributeName : [UIFont systemFontOfSize:18]} mutableCopy];

    [self updateViews];
}


#pragma mark - display views

- (void)displayWithTextKitView:(NSAttributedString *)text {
    MPILabel *mpiLabel = [[MPILabel alloc] initWithFrame:CGRectZero];
    self.mpiLabel = mpiLabel;
    
    mpiLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.contentScrollView addSubview:mpiLabel];

    mpiLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    mpiLabel.preferredMaxLayoutWidth = 200;
    mpiLabel.numberOfLines = self.maxNumberOfLines;
    mpiLabel.attributedText = text;

    [self addContraintToView:mpiLabel];
}

- (void)displayWithUILabel:(NSAttributedString *)text {
    UILabel *uiLabel = [[UILabel alloc] init];
    self.uiLabel = uiLabel;
    uiLabel.alpha = 0.3;
    uiLabel.backgroundColor = [UIColor orangeColor];
    NSMutableAttributedString *t = [text mutableCopy];
    [t addAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(0, t.length)];

    [self.contentScrollView addSubview:uiLabel];
    uiLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    uiLabel.preferredMaxLayoutWidth = 200;
    uiLabel.numberOfLines = self.maxNumberOfLines;
    uiLabel.attributedText = t;
    
    [self addContraintToView:uiLabel];
}

- (void)addContraintToView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *parent = view.superview;
    NSLayoutConstraint *top = [view.topAnchor constraintEqualToAnchor:parent.topAnchor constant:0];
    NSLayoutConstraint *left = [view.leftAnchor constraintEqualToAnchor:parent.leftAnchor constant:0];
    NSLayoutConstraint *bottom = [view.bottomAnchor constraintLessThanOrEqualToAnchor:parent.bottomAnchor constant:0];
    [parent addConstraints:@[top, left, bottom]];
}

- (void)updateText {
    NSMutableDictionary *attributes = self.attributes.mutableCopy;
    attributes[NSParagraphStyleAttributeName] = self.paragraphStyle;
    if (!self.text) {
        self.text = [[NSMutableAttributedString alloc] initWithString:[self textOfIndex:0] attributes:self.attributes];
    } else {
        [self.text addAttributes:attributes range:self.text.mpi_rangeOfAll];
    }
}

- (void)updateViews {
    [self.mpiLabel removeFromSuperview];
    [self.uiLabel removeFromSuperview];
    self.mpiLabel = nil;
    self.uiLabel = nil;
    
    [self updateText];
    [self displayWithTextKitView:self.text];
    [self displayWithUILabel:self.text];
}

- (void)displayValue:(float)value function:(const char *)function {
    NSLog(@"%s: %f", function, value);
    self.valueLabel.text = [NSString stringWithFormat:@"%f", value];
}

- (NSString *)textOfIndex:(NSInteger)index {
    switch (index % 7) {
        case 0:
            return @""
            "The withdrawn and mysterious pilot of Evangelion Unit-00 🤖, Rei Ayanami, is a clone made from the salvaged remains of Yui and is plagued by a sense of negative self-worth stemming from the realization that she is an expendable asset 🤔. \nShe at one time despised Shinji for his lack of trust in his father Gendo 😎, with whom Rei is very close. However, after Shinji and Rei successfully defeat the Angel Ramiel, she takes a friendly liking to him. Towards the end of the series it is revealed that she is one of many clones, whose use is to replace the currently existing Rei if she is killed.";
        case 1:
            return @""
            "iCloud 能将你的 GarageBand 创作进度在你所有的 iOS 设备间保持更新。它还可以让你在 iPad、iPhone 或 iPod touch 上开始勾勒一首歌的灵感，然后用 iCloud Drive 将音轨导入 Mac 做进一步创作，再将完成的作品共享到你的任何设备。你还可以导入 Logic Pro 项目的便携版本，接着创作其他音轨。当你重新在 Logic Pro 打开该项目时，所有原始音轨以及在 GarageBand 中另外添加的音轨，都将同时显示出来。";
        case 2:
            return @""
            "iCloud 能将你的 GarageBand 创作进度在你所有的 iOS 设备间保持更新。\n它还可以让你在 iPad、iPhone 或 iPod touch 上开始勾勒一首歌的灵感，然后用 iCloud Drive 将音轨导入 Mac 做进一步创作，再将完成的作品共享到你的任何设备。你还可以导入 Logic Pro 项目的便携版本，接着创作其他音轨。当你重新在 Logic Pro 打开该项目时，所有原始音轨以及在 GarageBand 中另外添加的音轨，都将同时显示出来。";
        case 3:
            return @""
            "iCloud 🤗能将你的 GarageBand 创作进度在你所有的 iOS 设备间保持更新🤗。\n它还可以让你在 iPad、iPhone 或 iPod touch 上开始勾勒一首歌的灵感，然后用 iCloud Drive 将音轨导入 Mac 做进一步创作，再将完成的作品共享到你的任何设备。你还可以导入 Logic Pro 项目的便携版本，接着创作其他音轨。\n\n当你重新在 Logic Pro 打开该项目时，所有原始音轨以及在 GarageBand 中另外添加的音轨，都将同时显示出来。Hello world";
        case 4:
            return @""
            "2012年12月。エヴァ：Qの公開後🤗、僕は EVA 壊れました。 Hello world 所謂、鬱状態となりました。 ６年間、自分の魂を削って再びエヴァを作っていた事への、当然の報いでした。明けた2013年。その一年間は精神的な負の波が何度も揺れ戻してくる年でした。自分が代表を務め、自分が作品 work を背負っているスタジオにただの１度も近づく事が出来ませんでした。\n他者や世間との関係性がおかしくなり、まるで回復しない疲労困憊も手伝って、ズブズブと精神的な不安定感に取り込まれていきました。その間、様々な方々に迷惑をかけました。が、妻や友人らの御蔭で、この世に留まる事が出来、宮崎駿氏に頼まれた声の仕事がアニメ制作へのしがみつき行為として機能した事や、友人らが僕のアニメファンの源になっていた作品の新作をその時期に作っていてくれた御蔭で、アニメーションから心が離れずにすみました。友人が続けている戦隊シリーズも、特撮ファンとしての心の支えになっていました。The series contains numerous allusions to the Kojiki and the Nihongi, the sacred texts of Shinto. The Shinto vision of the primordial cosmos is referenced in the series, and the mythical lances of the Shinto deities Izanagi and Izanami are used as weapons in battles between Evangelions and Angels.[63] Elements of the Judeo-Christian tradition also feature prominently throughout the series, including references to Adam, Lilith, Eve, the Lance of Longinus,[64]";
        case 5:
            return @""
            "중국조선어에 관한 망🤗라적인 언어 I don't know what the text means. 규범은 동북3성조선어문사업협의소조가 1977년에 작성한 ‘조선말규범집’이 처음이다. 이 규 This will test Korean and English mix layout 범집에는 표준발음법, 맞춤법, 띄어쓰기, 문장부호에 관한 규범이 수록되었다. ‘조선말규범집’은 어휘에 관한 규범을 덧붙이고, 일부를 가필 수정한 개정판이 1984년에 만들어졌다.[1]\n 중국조선말은 1949년 중화인민공화국 건국 이래, 조선민주주의인민공화국(이하 북조선)의 언어에 규범의 토대를 두어 온 경위로, 중국조선말의 언어 규범은 모두 북조선의 규범(조선말규범집 등)과  hello 거의 동일하며, 1992년 한중수교 이후에는 대한민국으로부터 진출한 기업이나 한국어 교육 기관의 영향력이 커짐에 따라 남한식 한국어의 사용이 확대되고 있다.";
        case 6:
            return @""
            "للغة العربية هي🤗 أكثر اللغات تحدثاً ونطقاً ضمن مجموعة اللغات hello world السامية، وإحدى أكثر اللغات انتشاراً في العالم، يتحدثها أكثر من 422 مليون نسمة،[2](1) ويتوزع متحدثوها في الوطن العربي، بالإضافة إلى العديد من المناطق الأخرى المجاورة كالأحواز وتركيا وتشاد ومالي والسنغال وإرتيريا و إثيوبيا و جنوب السودان و إيران. اللغة العربية ذات أهمية قصوى لدى المسلمين، فهي لغة مقدسة (لغة القرآن)، ولا تتم الصلاة (وعبادات أخرى) في الإسلام إلا بإتقان بعض من كلماتها.[4][5] العربية هي أيضاً لغة شعائرية رئيسية لدى عدد من الكنائس المسيحية في الوطن العربي، كما كتبت بها كثير من أهم الأعمال الدينية والفكرية اليهودية في العصور الوسطى. وأثّر انتشار الإسلام، وتأسيسه دولاً، ";
        default:return @"";
    }
}


#pragma mark - actions

- (IBAction)fontSizeSilderChanged:(UISlider *)sender {
    CGFloat size = sender.value;
    [self displayValue:size function:__func__];
    self.attributes[NSFontAttributeName] = [UIFont systemFontOfSize:size];
    [self updateViews];
}

- (IBAction)lineSpacingSliderChanged:(UISlider *)sender {
    CGFloat lineSpacing = sender.value;
    [self displayValue:lineSpacing function:__func__];
    ParagraphStyleAttriSet(lineSpacing)
    [self updateViews];
}

- (IBAction)textSilderChanged:(UISlider *)sender {
    NSInteger value = (NSInteger)sender.value;
    NSString *text = [self textOfIndex:value];
    self.text = [[NSMutableAttributedString alloc] initWithString:text attributes:self.attributes];
    if (value >= 7 ) {
        UIFont *current = (UIFont *)(self.attributes[NSFontAttributeName]);
        [self.text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:current.pointSize * 2] range:NSMakeRange(29
                                                                                                                          , 2)];
    }
    [self updateViews];
}

- (IBAction)lineHeightMultipleChanged:(UISlider *)sender {
    float lineHeightMultiple = sender.value;
    [self displayValue:lineHeightMultiple function:__func__];
    ParagraphStyleAttriSet(lineHeightMultiple)
    [self updateViews];
}

- (IBAction)paragrashSpacingChanged:(UISlider *)sender {
    float paragraphSpacing = sender.value;
    [self displayValue:paragraphSpacing function:__func__];
    ParagraphStyleAttriSet(paragraphSpacing)
    [self updateViews];
}

- (IBAction)firstLineHeadIndentChanged:(UISlider *)sender {
    float firstLineHeadIndent = sender.value;
    [self displayValue:firstLineHeadIndent function:__func__];
    ParagraphStyleAttriSet(firstLineHeadIndent)
    [self updateViews];
}

- (IBAction)headIndentChanged:(UISlider *)sender {
    float headIndent = sender.value;
    [self displayValue:headIndent function:__func__];
    ParagraphStyleAttriSet(headIndent)
    [self updateViews];
}

- (IBAction)tailIndentChanged:(UISlider *)sender {
    float tailIndent = sender.value;
    [self displayValue:tailIndent function:__func__];
    ParagraphStyleAttriSet(tailIndent)
    [self updateViews];
}

- (IBAction)maxNumberOfLinesChanged:(UISlider *)sender {
    int value = (int)sender.value;
    [self displayValue:value function:__func__];
    self.maxNumberOfLines = value;
    [self updateViews];
}

- (IBAction)minimumLineHeightChanged:(UISlider *)sender {
    float minimumLineHeight = sender.value;
    [self displayValue:minimumLineHeight function:__func__];
    ParagraphStyleAttriSet(minimumLineHeight)
    [self updateViews];
}

- (IBAction)maximumLineHeightChanged:(UISlider *)sender {
    float maximumLineHeight = sender.value;
    [self displayValue:maximumLineHeight function:__func__];
    ParagraphStyleAttriSet(maximumLineHeight)
    [self updateViews];
}

- (IBAction)paragraphSpacingBeforeChanged:(UISlider *)sender {
    float paragraphSpacingBefore = sender.value;
    [self displayValue:paragraphSpacingBefore function:__func__];
    ParagraphStyleAttriSet(paragraphSpacingBefore)
    [self updateViews];
}

- (IBAction)BaseWritingDirectionChanged:(UISlider *)sender {
    int baseWritingDirection = (int)sender.value;
    [self displayValue:baseWritingDirection function:__func__];
    ParagraphStyleAttriSet(baseWritingDirection)
    [self updateViews];
}

- (IBAction)hyphenationFactorChanged:(UISlider *)sender {
    float hyphenationFactor = sender.value;
    [self displayValue:hyphenationFactor function:__func__];
    ParagraphStyleAttriSet(hyphenationFactor)
    [self updateViews];
}


@end
