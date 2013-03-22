#import <Foundation/Foundation.h>
#import "TempSetup.h"

int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        NSString* txtPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/AsciiCodeIndex.txt"];
        NSString* binPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/BinaryCodeIndex.bin"];
        NSString* logPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/Log.txt"];

        [@"*** TempSetup program started\n"
            writeToFile:logPath
            atomically:NO
            encoding:NSUTF8StringEncoding
            error:NULL
        ];
        
        NSFileHandle* binHandle = [NSFileHandle fileHandleForUpdatingAtPath:binPath];
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
                        [binHandle seekToEndOfFile];
                        [binHandle writeData:aggregateNode(dataArray)];
                        break;
                    case 'L':
                        [binHandle seekToEndOfFile];
                        [binHandle writeData:aggregateLeaf(dataArray)];
                        break;
                    default:
                        [aggregateHeader(dataArray) writeToFile:binPath atomically:NO];
                        break;
                }
            }
        }
        [binHandle closeFile];
        fclose(txtFile);
        
        [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:NULL]
            stringByAppendingString:@"*** TempSetup program completed\n\n"]
                writeToFile:logPath
                atomically:NO
                encoding:NSUTF8StringEncoding
                error:NULL
        ];
    }
}