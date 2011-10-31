# CocoaAMF

### Description

CocoaAMF is a set of classes which can make AMF0 and AMF3 remoting calls or act as a server to handle AMF requests.


### Examples

For sending a remoting call see SimpleRemotingCallExample.
For setting up a server see ServerExample.

For testing an existing AMF server a more complex tool is provided, namely AMFClient, so be sure to check it out!

If you want to send custom classes from Cocoa make sure to implement the NSCoding protocol. You can encode keyed and non-keyed, where the latter means you're encoding an [externalizable](http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/utils/IExternalizable.html) class.

While deserializing, if no class with the classname of the received object is found, CocoaAMF creates an instance of ASObject which will contain all attributes of that object and its classname as the ivar 'type'.

### Todo

- Full test coverage


### Contact

Sorry, I'm not actively maintaining the project right now!


### Thanks

- Deusty Designs for CocoaAsyncSocket (<http://code.google.com/p/cocoaasyncsocket/>)
- Binary God for BGHUDAppKit (<http://code.google.com/p/bghudappkit/>)
- Jonathan Wight for TouchJSON (<http://code.google.com/p/touchcode/>)
- The PyAMF Team for PyAMF (<http://pyamf.org/>) and therefor letting me have a reference and unit tests which I can steal shamelessly