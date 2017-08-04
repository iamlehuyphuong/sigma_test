# sigma_test
## callback on main thread

Callback method form AFNetwork & CoreLocation handle on Main Thread.

The dispatch queue for completionBlock. If NULL (default), the main queue is used
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

dispatch_queue_t not NSThread, so can't make it callback on new thread if not use dispatch_queue_t for handle multithread.

is the same with Location update callback?? 

## crash issue at invitation

Test list L count over 1k, still run well
