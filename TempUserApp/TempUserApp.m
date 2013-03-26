/*
 *  TempUserApp.m                           Colin MacCreery
 *
 ************************************************************/


#import <Foundation/Foundation.h>
#import "CMCodeIndex.h"

// ----- PROTOTYPES -----------------------------------------/
NSString* readLineAsNSString(FILE* f);

// ----- MAIN -----------------------------------------------/
int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        // set paths to files
        NSString* binPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/BinaryCodeIndex.bin"];
        NSString* tnsPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/A4TransData.txt"];
        NSString* logPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/Log.txt"];
        
        // log a starting message
        [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil]
            stringByAppendingString:@"*** TempUserApp program started\n\n"]
            writeToFile:logPath
            atomically:NO
            encoding:NSUTF8StringEncoding
            error:NULL
         ];

        // create & initialize CMCodeIndex object with binary file
        CMCodeIndex* index = [[CMCodeIndex alloc] initWithFile:binPath];
        
        // open ascii file using fopen(), needed to read line-by-line
        FILE* tnsFile = fopen([tnsPath UTF8String], "r");
        
        // stream processing loop, runs until EOF reached
        while(!feof(tnsFile))
        {
            // read in line and separate the elements into an array, filter the
            // array to remove empty elements (due to PC-style line endings)
            NSString* lineRead = readLineAsNSString(tnsFile);
            NSArray* queryArray = [
                [lineRead componentsSeparatedByCharactersInSet:
                [NSCharacterSet characterSetWithCharactersInString:@" \n\r"]]
                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]
            ];
            
            // confirm the array is not empty
            if([queryArray isNotEqualTo:@[]])
            {
                // if the transaction is a code query ...
                if([[queryArray objectAtIndex:0] isEqualToString:@"QC"])
                {
                    // echo the query
                    [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil]
                        stringByAppendingString: [
                            NSString stringWithFormat:@"%@ %@\n", [queryArray objectAtIndex:0], [queryArray objectAtIndex:1]]
                        ]
                        writeToFile:logPath
                        atomically:NO
                        encoding:NSUTF8StringEncoding
                        error:NULL
                    ];

                    // send query message to CMCodeIndex object
                    NSDictionary* result = [index query:@""];
 
                    // build output string for appending to log file
                    NSString* output;
                    if([result isNotEqualTo:nil]) {
                        output = [
                            NSString stringWithFormat:@">> DRP: %@ – %@ nodes read in – %@ key-comparisons done\n",
                            [result objectForKey:@"pointer"],
                            [result objectForKey:@"nodes"],
                            [result objectForKey:@"comparisons"]
                        ];
                    } else {
                        output = [
                            NSString stringWithFormat:@">> NO MATCH – %@ nodes read in – %@ key-comparisons done\n",
                            [result objectForKey:@"nodes"],
                            [result objectForKey:@"comparisons"]
                        ];
                    }

                    // append result of transaction to log file
                    [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil]
                        stringByAppendingString:output]
                        writeToFile:logPath
                        atomically:NO
                        encoding:NSUTF8StringEncoding
                        error:NULL
                    ];
                }
                // if the transaction is to list all countries ...
                else if([[queryArray objectAtIndex:0] isEqualToString:@"LC"])
                {
                    NSString* output = [NSString stringWithFormat:@"LC\n%@", [index list]];
                    [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil]
                        stringByAppendingString:output]
                        writeToFile:logPath
                        atomically:NO
                        encoding:NSUTF8StringEncoding
                        error:NULL
                    ];
                }
            }
        }

        // send close message to CMCodeIndex object
        [index close];
        
        // log a finishing message
        [[[NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil]
            stringByAppendingString:@"*** TempUserApp program completed (# transactions)\n\n"]
            writeToFile:logPath
            atomically:NO
            encoding:NSUTF8StringEncoding
            error:NULL
        ];
    }
}

// ----- FUNCTIONS ------------------------------------------/

//  readLineAsNSString
//
//  this should be familiar

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