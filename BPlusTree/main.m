#import <Foundation/Foundation.h>
#import "main.h"

int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        NSString* index = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/AsciiCodeIndex.txt"];
        NSString* binary = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/BinaryCodeIndex.bin"];
        FILE* file = fopen([index UTF8String], "r");
        
        while(!feof(file)) {
            NSString* line = readLineAsNSString(file);
            NSArray* data = [
                [line componentsSeparatedByCharactersInSet:
                [NSCharacterSet characterSetWithCharactersInString:@" \n\r"]]
                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]
            ];
            
            if([data isNotEqualTo:@[]]) {
                switch ([[data objectAtIndex:0] characterAtIndex:0]) {
                    case 'N':
                        // NODE
                        break;
                    case 'L':
                        // LEAF
                        break;
                    default:
                        // HEADER
                        [aggregateHeader(data) writeToFile:binary atomically:NO];
                        break;
                }
            }
        }
        fclose(file);
    }
}