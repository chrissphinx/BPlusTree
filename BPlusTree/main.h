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