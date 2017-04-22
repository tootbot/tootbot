# Axt

A forgiving HTML SAX Parser for iOS inspired by `NSXMLParser`.

> Axt is the German word for [Ono (斧)][Ono].

Axt is highly inspired by `NSXMLParser` which is great for parsing XML but not for HTML. HTML is often not well-formed which makes it not suitable for `NSXMLParser`. In this cases `AXHTMLParser` provides a robust and reliable behavior.

### Why a SAX parser?

[SAX](http://www.saxproject.org) parser in general **need less memory** and are **faster** than [DOM](http://en.wikipedia.org/wiki/Document_Object_Model)-style parser which makes them better suitable where memory and speed is key.

# Installation


### Podfile

```ruby
pod 'Axt'
```

# Features

- Designed to forgive not well-formed HTML (unlike `NSXMLParser`)
- Inspired by `NSXMLParser` (same methods and delegate protocol)
- Powered by `libxml`
- Complete documentation
- Unit tested:

# Usage

```objective-c
#import "Axt.h"
    
NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:...];
AXHTMLParser *parser = [[AXHTMLParser alloc] initWithStream:stream];
parser.delegate = ... // set the delegate

BOOL success = [parser parse];
```

## Unit Test

Run the unit test with [xctool](https://github.com/facebook/xctool)

    xctool -find-target AxtTests -sdk iphonesimulator test
    
# Contact

Matthias Hochgatterer

Github: [https://github.com/brutella/](https://github.com/brutella/)

Twitter: [https://twitter.com/brutella](https://twitter.com/brutella)


# License

Axt is available under the MIT license. See the LICENSE file for more info.

[Ono]: https://github.com/mattt/Ono