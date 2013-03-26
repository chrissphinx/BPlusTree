/*
 *  TempSetup.m                             Colin MacCreery
 *
 *  FILES READ:     AsciiCodeIndex.txt
 *  FILES WRITTEN:  BinaryCodeIndex.txt
 *                  Log.txt
 *  
 *  Reads AsciiCodeIndex.txt line-by-line and then writes
 *  the BinaryCodeIndex.txt file one entry at a time.
 *
 ************************************************************/


#import <Foundation/Foundation.h>

// ----- PROTOTYPES -----------------------------------------/
//NSData* aggregateNode(NSArray* a);
NSData* aggregateLeafOrNode(NSArray* a);
NSData* aggregateHeader(NSArray* a);
NSString* readLineAsNSString(FILE* f);

// ----- MAIN -----------------------------------------------/
int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        // set paths to files
        NSString* txtPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/AsciiCodeIndex.txt"];
        NSString* binPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/BinaryCodeIndex.bin"];
        NSString* logPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/Log.txt"];

        // log a starting message
        [@"*** TempSetup program started\n"
            writeToFile:logPath
            atomically:NO
            encoding:NSUTF8StringEncoding
            error:nil
        ];
        
        // create an empty file and handle it for writing
        [@"" writeToFile:binPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        NSFileHandle* binHandle = [NSFileHandle fileHandleForWritingAtPath:binPath];
        
        // open ascii file using fopen(), needed to read line-by-line
        FILE* txtFile = fopen([txtPath UTF8String], "r");
        
        // stream processing loop, runs until EOF reached
        while(!feof(txtFile))
        {
            // read in line and separate the elements into an array, filter the
            // array to remove empty elements (due to PC-style line endings)
            NSString* lineRead = readLineAsNSString(txtFile);
            NSArray* dataArray = [
                [lineRead componentsSeparatedByCharactersInSet:
                [NSCharacterSet characterSetWithCharactersInString:@" \n\r"]]
                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]
            ];
            
            // confirm the array is not empty
            if([dataArray isNotEqualTo:@[]])
            {
                // switch checks initial char, otherwise it's the header
                // aggregate the data appropriately and append it to
                // the binary file
                switch ([[dataArray objectAtIndex:0] characterAtIndex:0]) {
                    case 'N':
                        [binHandle seekToEndOfFile];
                        [binHandle writeData:aggregateLeafOrNode(dataArray)];
                        break;
                    case 'L':
                        [binHandle seekToEndOfFile];
                        [binHandle writeData:aggregateLeafOrNode(dataArray)];
                        break;
                    default:
                        [binHandle seekToEndOfFile];
                        [binHandle writeData:aggregateHeader(dataArray)];
                        break;
                }
            }
        }
        [binHandle closeFile];
        fclose(txtFile); // close files
        
        // log a finishing message
        [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil]
            stringByAppendingString:@"*** TempSetup program completed\n"]
                writeToFile:logPath
                atomically:NO
                encoding:NSUTF8StringEncoding
                error:NULL
        ];
    }
}

// ----- FUNCTIONS ------------------------------------------/

//  aggregateNode
//
//  loops through the given array, appending bytes
//  to a mutable data object. Country codes are
//  written in one large section and then the tree
//  pointers. Swap endianness for readability

//NSData* aggregateNode(NSArray* a)
//{
//    NSMutableData* data = [NSMutableData new];
//    
//    char c = [[a objectAtIndex:0] characterAtIndex:0];
//    [data appendBytes:&c length:1];
//    
//    const char* o;
//    for (int i = 1; i < [a count] - 1; i = i + 2) {
//        o = [[a objectAtIndex:i] UTF8String];
//        [data appendBytes:o length:3];
//    }
//    
//    short p;
//    for (int i = 2; i < [a count] - 1; i = i + 2) {
//        p = CFSwapInt16HostToBig([[a objectAtIndex:i] intValue]);
//        [data appendBytes:&p length:2];
//    }
//    
//    return data;
//}

//  aggregateLeaf
//
//  loops through the given array, appending bytes
//  to a mutable data object. Writes next leaf pointer
//  as well as country codes and then record pointers.
//  Swap endianness for readability

NSData* aggregateLeafOrNode(NSArray* a)
{
    NSMutableData* data = [NSMutableData new];
    
    char c = [[a objectAtIndex:0] characterAtIndex:0];
    [data appendBytes:&c length:1];
    short l = CFSwapInt16HostToBig([[a objectAtIndex:15] intValue]);
    [data appendBytes:&l length:2];
    
    const char* o;
    for (int i = 1; i < [a count] - 1; i = i + 2) {
        o = [[a objectAtIndex:i] UTF8String];
        [data appendBytes:o length:3];
    }
    
    short p;
    for (int i = 2; i < [a count] - 1; i = i + 2) {
        p = CFSwapInt16HostToBig([[a objectAtIndex:i] intValue]);
        [data appendBytes:&p length:2];
    }
    
    return data;
}

//  aggregateHeader
//
//  loops through the given array, appending bytes
//  to a mutable data object. Swap endianness for
//  readability

NSData* aggregateHeader(NSArray* a)
{
    NSMutableData* data = [NSMutableData new];
    
    short n;
    for (int i = 0; i < [a count]; i++) {
        n = CFSwapInt16HostToBig([[a objectAtIndex:i] intValue]);
        [data appendBytes:&n length:2];
    }
    
    return data;
}

//  readLineAsNSString
//
//  function utilizing fscanf() to read from the file
//  until \n is reached. Returns contents of buffer up
//  to that point

NSString* readLineAsNSString(FILE* f)
{
    char b[256];
    NSMutableString* line = [NSMutableString new];
    
    int r;
    do {
        if(fscanf(f, "%256[^\n]%n%*c", b, &r) == 1)
            [line appendFormat:@"%s", b];
        else
            break;
    } while(r == 256);
    
    return line;
}