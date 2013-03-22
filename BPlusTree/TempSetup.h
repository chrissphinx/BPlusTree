/*
 *  TempSetup.h                             Colin MacCreery
 *
 *  Header file with four functions for use by the main
 *  TempSetup program. Three of them aggregate data into an
 *  NSData object to be written to the binary file. The last
 *  one reads the text file line-by-line as there is no
 *  method to do so in the standard ObjC API.
 *
 ************************************************************/

NSData* aggregateNode(NSArray* a) {
    NSMutableData* data = [NSMutableData new];
    
    char c = [[a objectAtIndex:0] characterAtIndex:0];
    [data appendBytes:&c length:1];
    
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

NSData* aggregateLeaf(NSArray* a) {
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

NSData* aggregateHeader(NSArray* a) {
    NSMutableData* data = [NSMutableData new];
    
    short n;
    for (int i = 0; i < [a count]; i++) {
        n = CFSwapInt16HostToBig([[a objectAtIndex:i] intValue]);
        [data appendBytes:&n length:2];
    }
    
    return data;
}

NSString* readLineAsNSString(FILE* f)
{
    char b[256];
    NSMutableString* line = [NSMutableString new];
    
    int r;
    do {
        if(fscanf(f, "%256[^\r]%n%*c", b, &r) == 1)
            [line appendFormat:@"%s", b];
        else
            break;
    } while(r == 256);
    
    return line;
}