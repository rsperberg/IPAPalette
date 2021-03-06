#import <Cocoa/Cocoa.h>
#import "KeylayoutParser.h"

@interface NSObject (KeylayoutParser)
-(void)keylayoutParser:(KeylayoutParser*)kp foundSequence:(NSString*)seq
       forOutput:(NSString*)string;
@end

int main(int argc, char *argv[])
{
  #pragma unused(argc,argv)
  NSAutoreleasePool* arp = [[NSAutoreleasePool alloc] init];
  KeylayoutParser* klp = [[KeylayoutParser alloc] init];
  unsigned type = [klp matchingKeyboardType];
  NSObject* obj = [[NSObject alloc] init];
  [klp parseKeyboardType:type withObject:obj selector:@selector(keylayoutParser:foundSequence:forOutput:)];
  //[klp dumpKeyboardType:type];
  [klp release];
  /*unsigned i;
  for (i = 0; i < 127; i++)
  {
    char* name = VKKName(i);
    char* sym = VKKSymbol(i);
    NSString* str = [[NSString alloc] initWithCString:sym encoding:NSUTF8StringEncoding];
    NSLog(@"%d: %s = %@", i, name, str);
    [str release];
  }*/
  [obj release];
  [arp release];
  return 0;
}

@implementation NSObject (KeylayoutParser)
-(void)keylayoutParser:(KeylayoutParser*)kp foundSequence:(NSString*)seq
       forOutput:(NSString*)output
{
  #pragma unused (kp)
  #pragma unused (kp)
  // The following combos are officially uninteresting:
  // 1. Anything yielding an empty string.
  // 2. Anything yielding a single character of 0x20 (space) or below, or 0x7F (delete).
  // 3. Unmodified 'A' yields 'a' or 'A'
  // 4. Sequence with a cmd modifier
  if ([seq length] != 0 && [output length] != 0)
  {
    BOOL interesting = YES;
    unichar ch1 = [seq characterAtIndex:0];
    unichar ch2 = [output characterAtIndex:0];
    if (ch2 <= 0x0020 || ch2 == 0x007F) interesting = NO;
    if ([seq length] == 1 && [output length] == 1)
    {
      if (ch1 == ch2 || (ch1 >= 'A' && ch1 <= 'Z' && ch2 - 0x0020 == ch1))
        interesting = NO;
    }
    if ([seq length] == 2 && [output length] == 1)
    {
      if (ch1 == kShiftUnicode || ch1 == kControlUnicode || ch1 == 0x21EA)
        ch1 = [seq characterAtIndex:1];
      if (ch1 == ch2 || (ch1 >= 'A' && ch1 <= 'Z' && ch2 - 0x0020 == ch1))
        interesting = NO;
    }
    unsigned i;
    for (i = 0; i < [seq length]; i++)
    {
      if ([seq characterAtIndex:i] == kCommandUnicode)
      {
        interesting = NO;
        break;
      }
    }
    if (interesting) NSLog(@"      seq '%@' produces '%@' (U+%04X)", seq, output, ch2);
  }
}
@end