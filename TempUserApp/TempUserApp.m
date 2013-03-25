/*
 *  TempUserApp.m                           Colin MacCreery
 *
 ************************************************************/


#import <Foundation/Foundation.h>
#import "CMCodeIndex.h"

int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        NSString* binPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/BPlusTree/BinaryCodeIndex.bin"];
        CMCodeIndex* index = [[CMCodeIndex alloc] initWithFile:binPath];
        
        header* h = [index header];
        
        NSLog(@"%hd, %hd, %hd, %hd, %hd", h->m, h->r, h->e, h->f, h->k);
        
        NSLog(@"%@", [index query:@""]);
        
        [index close];
    }
}