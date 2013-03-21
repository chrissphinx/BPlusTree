#import <Foundation/Foundation.h>
#import "main.h"

int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        NSString* txtPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/AsciiCodeIndex.txt"];
        NSString* binPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/BinaryCodeIndex.bin"];
        FILE* txtFile = fopen([txtPath UTF8String], "r");
        
        while(!feof(txtFile)) {
            NSString* lineRead = readLineAsNSString(txtFile);
            NSArray* dataArray = [
                [lineRead componentsSeparatedByCharactersInSet:
                [NSCharacterSet characterSetWithCharactersInString:@" \n\r"]]
                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]
            ];
            
            if([dataArray isNotEqualTo:@[]]) {
                switch ([[dataArray objectAtIndex:0] characterAtIndex:0]) {
                    case 'N':
                        // NODE
                        break;
                    case 'L':
                        // LEAF
                        break;
                    default:
                        // HEADER
                        [aggregateHeader(dataArray) writeToFile:binPath atomically:NO];
                        break;
                }
            }
        }
        fclose(txtFile);
    }
}