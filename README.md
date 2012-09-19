# Very simple FRAMEWORK to learn how to play with Amazon Web Services' workflow engine : SWF #

WFL is a command line utility that helps define and run (very) simple workflows based on Amazon's SWF service. 
You'll be able to learn how to use it in a simple way and, at the same time, leverage the great asynchonous capabilities
of nodejs!

Thanks to WFL you'll be able to:
* create a SWF domain
* create a SWF workflow
* create SWF tasks

and, *above all*
* run your workflows directy from the command line!

# How to install WFL #

    $ git clone https://github.com/pierreg256/wfl.git

# Dependencies #
wfl uses various flatiron utilities from nodejitsu and the awssum library. Be sure to npm them before use.

# Create a WFL application (an Amazon SWF instance)#

    var wfl = require('wfl');
    app = wfl();

    app.listen();

This will create an AWS SWF domain and a workflow type for that domain. The ```listen()``` command will start the workflow engine to begin to accept requests
To work correctly, ```wfl```needs your AWS credentials (secret access key and access key id). 
You can provide them through an ```options```object :
*Note* : For your own security I strongly encourage you to create a dedicated, limited SWF user account in the IAM section of your Amazon account and use its keys.
This will ensure that, if you get stolen your keys you just need to regenerate them for this specific account ;-)

    var wfl = require('wfl');
    var options = {
        secretAccessKey: "/YBzjQIExFEXAMPLEum0ZxKEYjIVCS",
        accessKeyId: "AKACCESSL3JKEYDEDPID"
    }
    app = wfl(options);

    app.listen();

But you can also provide options via the command line :

    node app.js --accessKeyId "AKACCESSL3JKEYDEDPID" --secretAccessKey "/YBzjQIExFEXAMPLEum0ZxKEYjIVCS"

More options can be provided in the same way :
* force : entitles SWF to create the domain, workflow types, activity types if/when necessary for you. Default value is ```false```
* region : the AWS region endpoint to reach when calling AWS APIs. Default value is ```us-east-1```
* domain : the name of the AWS domain you want to work with. Default value is ```sample-domain```
* name : the name of the workkflow type you want to work with. Default value is ```sample-workflow```

# Describe an activity Task  #

**TODO**

# Decision Routing #

**TODO**

# How to code your own workflow activities with WFL

**TODO**


# Author #

Written by Pierre Gilot - [Twitter](https://twitter.com/pierreg256).

# License #

The MIT License : http://opensource.org/licenses/MIT

Copyright &copy; 2012 Pierre Gilot

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


