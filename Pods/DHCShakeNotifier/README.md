DHCShakeNotifier
================

A tiny category, with a single method to send out a NSNotifiatication if a shake is detected :)

##Installation

###Cocoapods (preferred)  
add the following to your Podfile

```
pod "DHCShakeNotifier"
```

###Manual
add contents of `DHCShakeNotifier` to your project

##Usage  

Clone/ download the repo and take a quick look at the demo.

1. import DHCShakeNotifier:

    ```
    #import "UIWindow+DHCShakeRecognizer.h"
    ```

2. listen for shake notification by adding an NSNotification observer :

    ```
    @implementation YourObject

    ...

    -(id)init{
        if (self==[super init]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(methodThatIsCalledAfterShake) name:@"CONJUShakeNotification" object:nil];
        }
       return self;
    }

    ...

    -(void)methodThatIsCalledAfterShake{
     NSLog(@"\"I have just been shaken\" - A martini after being ordered by James Bond");
    }

    ...

    -(void)dealloc{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DHCSHakeNotifName object:nil];
    }

    ...

    @end
    ```
