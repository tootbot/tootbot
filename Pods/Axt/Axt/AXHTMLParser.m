//
//  AXHTMLParser.m
//  AXHTMLParser
//
//  Created by Matthias Hochgatterer on 13/05/14.
//  Copyright (c) 2014 Matthias Hochgatterer. All rights reserved.
//

#import "AXHTMLParser.h"

#import <libxml2/libxml/parser.h>
#import <libxml2/libxml/HTMLparser.h>
#import <libxml2/libxml/xmlreader.h>

// Callback functions
static void start_document(void *user_data);
static void end_document(void *user_data);
static void characters_found(void *user_data, const xmlChar *ch, int len);
static void start_element(void *user_data, const xmlChar *name, const xmlChar **attrs);
static void end_element(void *user_data, const xmlChar *name);
static void warning(void *user_data, const char *msg, ...);
static void error(void *user_data, const char *msg, ...);

static xmlSAXHandler _saxHandler = {
    NULL,           // internalSubsetSAXFunc internalSubset;
    NULL,           // isStandaloneSAXFunc isStandalone;
    NULL,           // hasInternalSubsetSAXFunc hasInternalSubset;
    NULL,           // hasExternalSubsetSAXFunc hasExternalSubset;
    NULL,           // resolveEntitySAXFunc resolveEntity;
    NULL,           // getEntitySAXFunc getEntity;
    NULL,           // entityDeclSAXFunc entityDecl;
    NULL,           // notationDeclSAXFunc notationDecl;
    NULL,           // attributeDeclSAXFunc attributeDecl;
    NULL,           // elementDeclSAXFunc elementDecl;
    NULL,           // unparsedEntityDeclSAXFunc unparsedEntityDecl;
    NULL,           // setDocumentLocatorSAXFunc setDocumentLocator;
    start_document, // startDocumentSAXFunc startDocument;
    end_document,   // endDocumentSAXFunc endDocument;
    start_element,  // startElementSAXFunc startElement;
    end_element,    // endElementSAXFunc endElement;
    NULL,           // referenceSAXFunc reference;
    characters_found, // charactersSAXFunc characters;
    NULL,           // ignorableWhitespaceSAXFunc ignorableWhitespace;
    NULL,           // processingInstructionSAXFunc processingInstruction;
    NULL,           // commentSAXFunc comment;
    warning,        // warningSAXFunc warning;
    warning,        // errorSAXFunc error;
    error,          // fatalErrorSAXFunc fatalError;
    NULL,           // getParameterEntitySAXFunc getParameterEntity;
    NULL,           // cdataBlockSAXFunc cdataBlock;
    NULL,           // externalSubsetSAXFunc externalSubset;
    0,              // unsigned int initialized;
    /* The following fields are extensions available only on version 2 */
    NULL,           // void *_private;
    NULL,           // startElementNsSAX2Func startElementNs;
    NULL,           // endElementNsSAX2Func endElementNs;
    NULL            // xmlStructuredErrorFunc serror;
};

@interface AXHTMLParser ()

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, assign) BOOL parsing;
@property (nonatomic, assign) BOOL abort;

@property (nonatomic, assign) htmlParserCtxtPtr context;

@end

@implementation AXHTMLParser

- (instancetype)initWithHTMLString:(NSString *)string
{
    NSStringEncoding encoding = [string fastestEncoding];
    return [self initWithStream:[NSInputStream inputStreamWithData:[string dataUsingEncoding:encoding]]];
}

- (instancetype)initWithStream:(NSInputStream *)stream;
{
    self = [super init];
    
    if (self) {
        _inputStream = stream;
        [_inputStream open];
    }
    
    return self;
}

- (void)dealloc
{
    htmlFreeParserCtxt(_context);
}

- (BOOL)parse
{
    NSAssert(!_parsing, @"Calling parse while parse process is active is not supported.");
    _parsing = YES;
    [self _parse];
    
    return _parserError == nil;
}

- (void)abortParsing
{
    _abort = YES;
}

#pragma mark - Private

static NSUInteger const CHUNK_SIZE = 256;
- (void)_parse
{
    uint8_t buffer[CHUNK_SIZE];
    while ([_inputStream hasBytesAvailable] && !_abort) {
        // Create context if not done already
        if (!_context) {
            _context = htmlCreatePushParserCtxt(&_saxHandler, (__bridge void*)self, NULL, 0, NULL, XML_CHAR_ENCODING_UTF8);
            htmlCtxtUseOptions(_context, HTML_PARSE_RECOVER);
        }
        
        NSInteger readBytes = [_inputStream read:buffer maxLength:CHUNK_SIZE];
        BOOL bytesAvailable = readBytes > 0;
        int end = [_inputStream hasBytesAvailable] ? 0 : 1;
        if (bytesAvailable || end == 1) { // parse chunk when bytes are available or end reached
            htmlParseChunk(_context, (const char*)buffer, (int)readBytes, end);
        }
    }
    
    if (_abort) {
        NSError *abortError = [NSError errorWithDomain:AXHTMLErrorDomain code:AXHTMLErrorAborted userInfo:@{}];
        [self.delegate parser:self parseErrorOccurred:abortError];
    }
}

@end

// Converts a char array to NSString
NSString *NSStringFromLibXMLChar(const xmlChar *characters)
{
    if (characters) {
        return [NSString stringWithUTF8String:(const char*)characters];
    }
    
    return nil;
}

// Converts a list of key/value pairs to NSDictionary
NSDictionary *NSDictionaryFromLibXMLKeyValueChar(const xmlChar **values)
{
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    const xmlChar **element = values;
    if (element) {
        do {
            NSString *key = NSStringFromLibXMLChar(*element);
            element++;
            NSString *value = NSStringFromLibXMLChar(*element);
            
            if (key && value) {
                dictionary[key] = value;
            }
        } while (*++element);
    }
    
    return dictionary;
}

// Callback function
static void start_document(void *user_data)
{
    AXHTMLParser *parser = (__bridge AXHTMLParser *)user_data;
    [parser.delegate parserDidStartDocument:parser];
}

static void end_document(void *user_data)
{
    AXHTMLParser *parser = (__bridge AXHTMLParser *)user_data;
    [parser.delegate parserDidEndDocument:parser];
}

void characters_found(void * user_data, const xmlChar * ch, int length)
{
    AXHTMLParser *parser = (__bridge AXHTMLParser *)user_data;
    NSString *string = [[NSString alloc] initWithBytes:ch length:length encoding:NSUTF8StringEncoding];
    [parser.delegate parser:parser foundCharacters:string];
}

void start_element(void * 	user_data, const xmlChar * 	name, const xmlChar ** 	attrs)
{
    AXHTMLParser *parser = (__bridge AXHTMLParser *)user_data;
    NSString *elementName = NSStringFromLibXMLChar(name);
    NSDictionary *attributes = NSDictionaryFromLibXMLKeyValueChar(attrs);
    [parser.delegate parser:parser didStartElement:elementName attributes:attributes];
}

void end_element(void *user_data, const xmlChar *name)
{
    AXHTMLParser *parser = (__bridge AXHTMLParser *)user_data;
    [parser.delegate parser:parser didEndElement:NSStringFromLibXMLChar(name)];
}

void warning(void *user_data, const char *msg, ...) {
    va_list args;
    
    va_start(args, msg);
    NSString *formatString = [NSString stringWithUTF8String:msg];
    NSString *warning = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    NSLog(@"[Warning] %@", warning);
}

void error(void *user_data, const char *msg, ...) {
    AXHTMLParser *parser = (__bridge AXHTMLParser *)user_data;
    
    va_list args;
    va_start(args, msg);
    NSString *formatString = [NSString stringWithUTF8String:msg];
    NSString *errorDescription = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    NSLog(@"[Error] %@", errorDescription);
    
    NSMutableDictionary *userInfo = [@{} mutableCopy];
    if (errorDescription) {
        userInfo[NSLocalizedDescriptionKey] = errorDescription;
    }
    parser.parserError = [NSError errorWithDomain:AXHTMLErrorDomain code:AXHTMLErrorUndefined userInfo:userInfo];
    
    [parser.delegate parser:parser parseErrorOccurred:parser.parserError];
}
