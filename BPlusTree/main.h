NSData* aggregateHeader(NSArray* a) {
    NSMutableData* data = [NSMutableData new];
    short number;
    
    for (int i = 0; i < [a count]; i++) {
        number = CFSwapInt16HostToBig([[a objectAtIndex:i] intValue]);
        [data appendBytes:&number length:2];
    }
    
    return data;
}

NSString* readLineAsNSString(FILE* file)
{
    char buffer[256];
    NSMutableString* result = [NSMutableString new];
    
    int charsRead;
    do {
        if(fscanf(file, "%256[^\r]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 256);
    
    return (NSString*)result;
}