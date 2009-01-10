To test this server, download my remoting tester from <http://www.nesium.com/blog/2007/08/15/flash-remoting-tester-with-json-input/>.

1. Start the Server (Cmd-R)
2. Open the remoting tester
3. Fill in the fields in the remoting tester:
	- ServiceURL: http://localhost:1234
	- Service: DirectoryService
	- click "connect" to enable the further fields
	- Function: directoryContentsAtPath
	- Arguments: ["/"]
4. Click "call"
5. You should now see the contents of your root directory in the remoting tester