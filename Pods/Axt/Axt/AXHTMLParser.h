//
//  AXHTMLParser.h
//  AXHTMLParser
//
//  Created by Matthias Hochgatterer on 13/05/14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//

#import <Foundation/Foundation.h>

// http://www.jamesh.id.au/articles/libxml-sax/libxml-sax.html

@protocol AXHTMLParserDelegate;
@interface AXHTMLParser : NSObject

@property (nonatomic, strong) NSError *parserError;
@property (nonatomic, weak) id<AXHTMLParserDelegate> delegate;

- (instancetype)initWithHTMLString:(NSString *)string;
- (instancetype)initWithStream:(NSInputStream *)stream;

/** Starts synchronous parsing
 
 @returns YES when no parsing error occured, otherwise NO.
 */
- (BOOL)parse;

/** Stops parsing
 
 This method triggers the delegate method `parser:parseErrorOccurred:` with error code AXHTMLErrorAborted.
 */
- (void)abortParsing;

@end

@protocol AXHTMLParserDelegate <NSObject>

/** Called when the document parsing started
 
 @param parser The parser
 */
- (void)parserDidStartDocument:(AXHTMLParser *)parser;

/** Called when the document parsing ended.
 
 The method is also called when an parse error occurred.
 The method is not called when `abortParsing` is called.
 
 @param parser The parser
 */
- (void)parserDidEndDocument:(AXHTMLParser *)parser;

/** Called when the opening tag of an element is found.
 
 @param parser The parser
 @param elementName The element/tag name
 */
- (void)parser:(AXHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict;

/** Called when the closing tag of an element is found.
 
 @param parser The parser
 @param elementName The element/tag name
 */
- (void)parser:(AXHTMLParser *)parser didEndElement:(NSString *)elementName;

/** Called when character are found.
 
 This method may be called successively for the characters between tags.
 
 @param parser The parser
 @param string The characters found so far
 */
- (void)parser:(AXHTMLParser *)parser foundCharacters:(NSString *)string;

/** Called when a parse error occured.
 
 After this method is called, the parser continues.
 
 @param parser The parser
 @param parserError The parse error
 */
- (void)parser:(AXHTMLParser *)parser parseErrorOccurred:(NSError *)parseError;

@end

static NSString *const AXHTMLErrorDomain = @"at.mah.axhtmlparser";

typedef NS_ENUM(NSInteger, AXHTMLError) {
    AXHTMLErrorUndefined = -1,
    AXHTMLErrorAborted = 1
};
