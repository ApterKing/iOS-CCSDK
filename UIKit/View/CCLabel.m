//
//  CCLabel.m
//  CCSDK
//
//  Created by wangcong on 15/10/29.
//  Copyright © 2015年 wangcong. All rights reserved.
//

#import "CCLabel.h"

NSString * const CCLabelLinkTypeKey = @"linkType";
NSString * const CCLabelRangeKey = @"range";
NSString * const CCLabelLinkKey = @"link";

#define PATTERN_AT @"@([\\w\\_]+)?"
#define PATTERN_TAG @"#([\\w\\_]+)?#"

#pragma mark - Private Interface

@interface CCLabel()

@property (nonatomic, retain) NSLayoutManager *layoutManager;

@property (nonatomic, retain) NSTextContainer *textContainer;

@property (nonatomic, retain) NSTextStorage *textStorage;

@property (nonatomic, copy) NSArray *linkRanges;

@property (nonatomic, assign) BOOL isTouchMoved;

// During a touch, range of text that is displayed as selected
@property (nonatomic, assign) NSRange selectedRange;

@end

#pragma mark - Implementation

@implementation CCLabel
{
    NSMutableDictionary *_linkTypeAttributes;
}

#pragma mark - Construction

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextSystem];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupTextSystem];
    }
    
    return self;
}

// Common initialisation. Must be done once during construction.
- (void)setupTextSystem
{
    _textContainer = [[NSTextContainer alloc] init];
    _textContainer.lineFragmentPadding = 0;
    _textContainer.maximumNumberOfLines = self.numberOfLines;
    _textContainer.lineBreakMode = self.lineBreakMode;
    _textContainer.size = self.frame.size;
    
    _layoutManager = [[NSLayoutManager alloc] init];
    _layoutManager.delegate = self;
    [_layoutManager addTextContainer:_textContainer];
    
    // Attach the layou manager to the container and storage
    [_textContainer setLayoutManager:_layoutManager];
    
    // Make sure user interaction is enabled so we can accept touches
    self.userInteractionEnabled = YES;
    
    // Don't go via public setter as this will have undesired side effect
    _automaticLinkDetectionEnabled = YES;
    
    // All links are detectable by default
    _linkTypeOptions = CCLinkTypeOptionAll;
    
    // Link Type Attributes. Default is empty (no attributes).
    _linkTypeAttributes = [NSMutableDictionary dictionary];
    
    // Don't underline URL links by default.
    _systemURLStyle = NO;
    
    // By default we hilight the selected link during a touch to give feedback that we are
    // responding to touch.
    _selectedLinkBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    // Establish the text store with our current text
    [self updateTextStoreWithText];
}

#pragma mark - Text and Style management

- (void)setAutomaticLinkDetectionEnabled:(BOOL)decorating
{
    _automaticLinkDetectionEnabled = decorating;
    
    // Make sure the text is updated properly
    [self updateTextStoreWithText];
}

- (void)setlinkTypeOptions:(CCLinkTypeOption)linkTypeOptions
{
    _linkTypeOptions = linkTypeOptions;
    
    // Make sure the text is updated properly
    [self updateTextStoreWithText];
}

- (NSDictionary *)linkAtPoint:(CGPoint)location
{
    // Do nothing if we have no text
    if (_textStorage.string.length == 0) {
        return nil;
    }
    
    // Work out the offset of the text in the view
    CGPoint textOffset = [self calcGlyphsPositionInView];
    
    // Get the touch location and use text offset to convert to text cotainer coords
    location.x -= textOffset.x;
    location.y -= textOffset.y;
    
    NSUInteger touchedChar = [_layoutManager glyphIndexForPoint:location inTextContainer:_textContainer];
    
    // If the touch is in white space after the last glyph on the line we don't
    // count it as a hit on the text
    NSRange lineRange;
    CGRect lineRect = [_layoutManager lineFragmentUsedRectForGlyphAtIndex:touchedChar effectiveRange:&lineRange];
    if (CGRectContainsPoint(lineRect, location) == NO)
        return nil;
    
    // Find the word that was touched and call the detection block
    for (NSDictionary *dictionary in self.linkRanges) {
        NSRange range = [[dictionary objectForKey:CCLabelRangeKey] rangeValue];
        
        if ((touchedChar >= range.location) && touchedChar < (range.location + range.length)) {
            return dictionary;
        }
    }
    
    return nil;
}

// Applies background color to selected range. Used to hilight touched links
- (void)setSelectedRange:(NSRange)range
{
    // Remove the current selection if the selection is changing
    if (self.selectedRange.length && !NSEqualRanges(self.selectedRange, range)) {
        [_textStorage removeAttribute:NSBackgroundColorAttributeName range:self.selectedRange];
    }
    
    // Apply the new selection to the text
    if (range.length && _selectedLinkBackgroundColor != nil) {
        [_textStorage addAttribute:NSBackgroundColorAttributeName value:_selectedLinkBackgroundColor range:range];
    }
    
    // Save the new range
    _selectedRange = range;
    
    [self setNeedsDisplay];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    [super setNumberOfLines:numberOfLines];
    
    _textContainer.maximumNumberOfLines = numberOfLines;
}

- (void)setText:(NSString *)text
{
    // Pass the text to the super class first
    [super setText:text];
    
    // Update our text store with an attributed string based on the original
    // label text properties.
    if (!text) {
        text = @"";
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self attributesFromProperties]];
    [self updateTextStoreWithAttributedString:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    // Pass the text to the super class first
    [super setAttributedText:attributedText];
    
    [self updateTextStoreWithAttributedString:attributedText];
}

- (void)setSystemURLStyle:(BOOL)systemURLStyle
{
    _systemURLStyle = systemURLStyle;
    
    // Force refresh
    self.text = self.text;
}

- (NSDictionary*)attributesForLinkType:(CCLinkType)linkType
{
    NSDictionary *attributes = _linkTypeAttributes[@(linkType)];
    if (!attributes) {
        attributes = @{NSForegroundColorAttributeName : self.tintColor};
    }
    return attributes;
}

- (void)setAttributes:(NSDictionary*)attributes forLinkType:(CCLinkType)linkType
{
    if (attributes) {
        _linkTypeAttributes[@(linkType)] = attributes;
    } else {
        [_linkTypeAttributes removeObjectForKey:@(linkType)];
    }
    
    // Force refresh text
    self.text = self.text;
}

#pragma mark - Text Storage Management

- (void)updateTextStoreWithText
{
    // Now update our storage from either the attributedString or the plain text
    if (self.attributedText) {
        [self updateTextStoreWithAttributedString:self.attributedText];
    } else if (self.text) {
        [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:self.text attributes:[self attributesFromProperties]]];
    } else {
        [self updateTextStoreWithAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:[self attributesFromProperties]]];
    }
    [self setNeedsDisplay];
}

- (void)updateTextStoreWithAttributedString:(NSAttributedString *)attributedString
{
    if (attributedString.length != 0) {
        attributedString = [CCLabel sanitizeAttributedString:attributedString];
    }
    
    if (self.isAutomaticLinkDetectionEnabled && (attributedString.length != 0)) {
        self.linkRanges = [self getRangesForLinks:attributedString];
        attributedString = [self addLinkAttributesToAttributedString:attributedString linkRanges:self.linkRanges];
    } else {
        self.linkRanges = nil;
    }
    
    if (_textStorage) {
        // Set the string on the storage
        [_textStorage setAttributedString:attributedString];
    } else {
        // Create a new text storage and attach it correctly to the layout manager
        _textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager setTextStorage:_textStorage];
    }
}

// Returns attributed string attributes based on the text properties set on the label.
// These are styles that are only applied when NOT using the attributedText directly.
- (NSDictionary *)attributesFromProperties
{
    // Setup shadow attributes
    NSShadow *shadow = shadow = [[NSShadow alloc] init];
    if (self.shadowColor) {
        shadow.shadowColor = self.shadowColor;
        shadow.shadowOffset = self.shadowOffset;
    } else {
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowColor = nil;
    }
    
    // Setup color attributes
    UIColor *color = self.textColor;
    if (!self.isEnabled) {
        color = [UIColor lightGrayColor];
    } else if (self.isHighlighted) {
        color = self.highlightedTextColor;
    }
    
    // Setup paragraph attributes
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = self.textAlignment;
    
    // Create the dictionary
    NSDictionary *attributes = @{NSFontAttributeName : self.font,
                                 NSForegroundColorAttributeName : color,
                                 NSShadowAttributeName : shadow,
                                 NSParagraphStyleAttributeName : paragraph,
                                 };
    return attributes;
}

/**
 *  Returns array of ranges for all special words, user handles, hashtags and urls in the specfied
 *  text.
 *
 *  @param text Text to parse for links
 *
 *  @return Array of dictionaries describing the links.
 */
- (NSArray *)getRangesForLinks:(NSAttributedString *)text
{
    NSMutableArray *rangesForLinks = [[NSMutableArray alloc] init];
    
    if (self.linkTypeOptions & CCLinkTypeOptionCustom) {
        [rangesForLinks addObjectsFromArray:[self getRangesForCustomHandles:text.string]];
    }
    
    if (self.linkTypeOptions & CCLinkTypeOptionUserHandle) {
        [rangesForLinks addObjectsFromArray:[self getRangesForUserHandles:text.string]];
    }
    
    if (self.linkTypeOptions & CCLinkTypeOptionHashtag) {
        [rangesForLinks addObjectsFromArray:[self getRangesForHashtags:text.string]];
    }
    
    if (self.linkTypeOptions & CCLinkTypeOptionURL) {
        [rangesForLinks addObjectsFromArray:[self getRangesForURLs:self.attributedText]];
    }
    
    return rangesForLinks;
}

- (NSArray *)getRangesForCustomHandles:(NSString *)text
{
    NSMutableArray *rangesForUserHandles = [[NSMutableArray alloc] init];
    
    // 不存在自定义RegexPattern
    if (self.regexPattern == nil || [self.regexPattern isEqualToString:@""]) {
        return rangesForUserHandles;
    }
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:self.regexPattern options:0 error:nil];
    
    // Run the expression and get matches
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        if (![self ignoreMatch:matchString]) {
            [rangesForUserHandles addObject:@{CCLabelLinkTypeKey : @(CCLinkTypeCustom),
                                              CCLabelRangeKey : [NSValue valueWithRange:matchRange],
                                              CCLabelLinkKey : matchString
                                              }];
        }
    }
    return rangesForUserHandles;
}

- (NSArray *)getRangesForUserHandles:(NSString *)text
{
    NSMutableArray *rangesForUserHandles = [[NSMutableArray alloc] init];
    
    // Setup a regular expression for user handles and hashtags
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:PATTERN_AT options:0 error:&error];
    });
    
    // Run the expression and get matches
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        if (![self ignoreMatch:matchString]) {
            [rangesForUserHandles addObject:@{CCLabelLinkTypeKey : @(CCLinkTypeUserHandle),
                                              CCLabelRangeKey : [NSValue valueWithRange:matchRange],
                                              CCLabelLinkKey : matchString
                                              }];
        }
    }
    
    return rangesForUserHandles;
}

- (NSArray *)getRangesForHashtags:(NSString *)text
{
    NSMutableArray *rangesForHashtags = [[NSMutableArray alloc] init];
    
    // Setup a regular expression for user handles and hashtags
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:PATTERN_TAG options:0 error:&error];
    });
    
    // Run the expression and get matches
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSString *matchString = [text substringWithRange:matchRange];
        
        if (![self ignoreMatch:matchString]) {
            [rangesForHashtags addObject:@{CCLabelLinkTypeKey : @(CCLinkTypeHashtag),
                                           CCLabelRangeKey : [NSValue valueWithRange:matchRange],
                                           CCLabelLinkKey : matchString,
                                           }];
        }
    }
    
    return rangesForHashtags;
}


- (NSArray *)getRangesForURLs:(NSAttributedString *)text
{
    NSMutableArray *rangesForURLs = [[NSMutableArray alloc] init];;
    
    // Use a data detector to find urls in the text
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSString *plainText = text.string;
    
    NSArray *matches = [detector matchesInString:plainText
                                         options:0
                                           range:NSMakeRange(0, text.length)];
    
    // Add a range entry for every url we found
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        
        // If there's a link embedded in the attributes, use that instead of the raw text
        NSString *realURL = [text attribute:NSLinkAttributeName atIndex:matchRange.location effectiveRange:nil];
        if (realURL == nil)
            realURL = [plainText substringWithRange:matchRange];
        
        if (![self ignoreMatch:realURL]) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                [rangesForURLs addObject:@{CCLabelLinkTypeKey : @(CCLinkTypeURL),
                                           CCLabelRangeKey : [NSValue valueWithRange:matchRange],
                                           CCLabelLinkKey : realURL,
                                           }];
            }
        }
    }
    
    return rangesForURLs;
}

- (BOOL)ignoreMatch:(NSString*)string
{
    return [_ignoredKeywords containsObject:[string lowercaseString]];
}

- (NSAttributedString *)addLinkAttributesToAttributedString:(NSAttributedString *)string linkRanges:(NSArray *)linkRanges
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    for (NSDictionary *dictionary in linkRanges) {
        NSRange range = [[dictionary objectForKey:CCLabelRangeKey] rangeValue];
        CCLinkType linkType = [dictionary[CCLabelLinkTypeKey] unsignedIntegerValue];
        
        NSDictionary *attributes = [self attributesForLinkType:linkType];
        
        // Use our tint color to hilight the link
        [attributedString addAttributes:attributes range:range];
        
        // Add an URL attribute if this is a URL
        if (_systemURLStyle && ((CCLinkType)[dictionary[CCLabelLinkTypeKey] unsignedIntegerValue] == CCLinkTypeURL))
        {
            // Add a link attribute using the stored link
            [attributedString addAttribute:NSLinkAttributeName value:dictionary[CCLabelLinkKey] range:range];
        }
    }
    
    return attributedString;
}

#pragma mark - Layout and Rendering

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    // Use our text container to calculate the bounds required. First save our
    // current text container setup
    CGSize savedTextContainerSize = _textContainer.size;
    NSInteger savedTextContainerNumberOfLines = _textContainer.maximumNumberOfLines;
    
    // Apply the new potential bounds and number of lines
    _textContainer.size = bounds.size;
    _textContainer.maximumNumberOfLines = numberOfLines;
    
    // Measure the text with the new state
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    
    // Position the bounds and round up the size for good measure
    textBounds.origin = bounds.origin;
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height);
    
    if (textBounds.size.height < bounds.size.height) {
        // Take verical alignment into account
        CGFloat offsetY = (bounds.size.height - textBounds.size.height) / 2.0;
        textBounds.origin.y += offsetY;
    }
    
    // Restore the old container state before we exit under any circumstances
    _textContainer.size = savedTextContainerSize;
    _textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines;
    
    return textBounds;
}

- (void)drawTextInRect:(CGRect)rect
{
    // Don't call super implementation. Might want to uncomment this out when
    // debugging layout and rendering problems.
    // [super drawTextInRect:rect];
    
    // Calculate the offset of the text in the view
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    CGPoint glyphsPosition = [self calcGlyphsPositionInView];
    
    // Drawing code
    [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:glyphsPosition];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:glyphsPosition];
}

// Returns the XY offset of the range of glyphs from the view's origin
- (CGPoint)calcGlyphsPositionInView
{
    CGPoint textOffset = CGPointZero;
    
    CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
    textBounds.size.width = ceil(textBounds.size.width);
    textBounds.size.height = ceil(textBounds.size.height);
    
    if (textBounds.size.height < self.bounds.size.height) {
        CGFloat paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0;
        textOffset.y = paddingHeight;
    }
    
    return textOffset;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _textContainer.size = self.bounds.size;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    _textContainer.size = self.bounds.size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Update our container size when the view frame changes
    _textContainer.size = self.bounds.size;
}

- (void)setIgnoredKeywords:(NSSet *)ignoredKeywords
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:ignoredKeywords.count];
    
    [ignoredKeywords enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [set addObject:[obj lowercaseString]];
    }];
    
    _ignoredKeywords = [set copy];
}

#pragma mark - Interactions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isTouchMoved = NO;
    
    // Get the info for the touched link if there is one
    NSDictionary *touchedLink;
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    touchedLink = [self linkAtPoint:touchLocation];
    
    if (touchedLink) {
        self.selectedRange = [[touchedLink objectForKey:CCLabelRangeKey] rangeValue];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    _isTouchMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    // If the user dragged their finger we ignore the touch
    if (_isTouchMoved) {
        self.selectedRange = NSMakeRange(0, 0);
        return;
    }
    
    // Get the info for the touched link if there is one
    NSDictionary *touchedLink;
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    touchedLink = [self linkAtPoint:touchLocation];
    
    if (touchedLink) {
        NSRange range = [[touchedLink objectForKey:CCLabelRangeKey] rangeValue];
        NSString *touchedSubstring = [touchedLink objectForKey:CCLabelLinkKey];
        CCLinkType linkType = (CCLinkType)[[touchedLink objectForKey:CCLabelLinkTypeKey] intValue];
        
        [self receivedActionForLinkType:linkType string:touchedSubstring range:range];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
    self.selectedRange = NSMakeRange(0, 0);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    // Make sure we don't leave a selection when the touch is cancelled
    self.selectedRange = NSMakeRange(0, 0);
}

- (void)receivedActionForLinkType:(CCLinkType)linkType string:(NSString*)string range:(NSRange)range
{
    switch (linkType)
    {
        case CCLinkTypeCustom:
            if (_customLinkTapHandler) {
                _customLinkTapHandler(self, string, range);
            }
        case CCLinkTypeUserHandle:
            if (_userHandleLinkTapHandler) {
                _userHandleLinkTapHandler(self, string, range);
            }
            break;
            
        case CCLinkTypeHashtag:
            if (_hashtagLinkTapHandler) {
                _hashtagLinkTapHandler(self, string, range);
            }
            break;
            
        case CCLinkTypeURL:
            if (_urlLinkTapHandler) {
                _urlLinkTapHandler(self, string, range);
            }
            break;
    }
}

#pragma mark - Layout manager delegate

-(BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    // Don't allow line breaks inside URLs
    NSRange range;
    NSURL *linkURL = [layoutManager.textStorage attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&range];
    
    return !(linkURL && (charIndex > range.location) && (charIndex <= NSMaxRange(range)));
}

+ (NSAttributedString *)sanitizeAttributedString:(NSAttributedString *)attributedString
{
    // Setup paragraph alignement properly. IB applies the line break style
    // to the attributed string. The problem is that the text container then
    // breaks at the first line of text. If we set the line break to wrapping
    // then the text container defines the break mode and it works.
    // NOTE: This is either an Apple bug or something I've misunderstood.
    
    // Get the current paragraph style. IB only allows a single paragraph so
    // getting the style of the first char is fine.
    NSRange range;
    NSParagraphStyle *paragraphStyle = [attributedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:&range];
    
    if (paragraphStyle == nil) {
        return attributedString;
    }
    
    // Remove the line breaks
    NSMutableParagraphStyle *mutableParagraphStyle = [paragraphStyle mutableCopy];
    mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Apply new style
    NSMutableAttributedString *restyled = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [restyled addAttribute:NSParagraphStyleAttributeName value:mutableParagraphStyle range:NSMakeRange(0, restyled.length)];
    
    return restyled;
}

@end
