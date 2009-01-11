# CocoaAMF

### Description

CocoaAMF is a set of classes which can make AMF0 and AMF3 remoting calls or act as a server to handle AMF requests.


### Examples

For sending a remoting call see SimpleRemotingCallExample.
For setting up a server see ServerExample.

For testing an existing AMF server a more complex tool is provided, namely AMFClient, so be sure to check it out!

If you're comfortable with Flash's ByteArray class it should be pretty easy to use AMFByteArray if you need to, for example in combination with a socket connection.


### iPhone Support

I haven't tested the code on the iPhone yet, it may run, but in any case I plan to make it work on the iPhone too.


### Disclaimer

Beware that is more or less a beta release and the API is subject to change!


### Todo

- Full test coverage
- Robust error handling (eg. passing a NSError through all methods)
- Split AMFByteArray into AMFByteArray and AMFMutableByteArray


### Contact

If you have any questions or ideas, let me know at mb@nesium.com.


### Thanks

Deusty Designs for CocoaAsyncSocket (<http://code.google.com/p/cocoaasyncsocket/>)
Binary God for BGHUDAppKit (<http://code.google.com/p/bghudappkit/>)
The PyAMF Team for PyAMF (<http://pyamf.org/>) and therefor letting me have a reference and unit tests which I can steal shamelessly