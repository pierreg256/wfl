# Very simple CLI to learn how to play with Amazon Web Services' workflow engine : SWF #

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
wfl uses flatiron from nodejitsu and the awssum library. Be sure to npm them before use.
*Note*: awssum is under active development and I advise to use the latest builds from github instead of npm.

# How to use WFL CLI#
The CLI portion of WFL will help you define the overall workflow architecture. Two options can be used at every command :
* --secretAccessKey, -s  the secret key from your AWS account
* --accessKeyId, -k      the access key from your AWS account

*Note* : For your own security I strongly encourage you to create a dedicated, limited SWF user account in the IAM section of your Amazon account and use its keys.
This will ensure that, if you get stolen your keys you just need to regenerate them for this specific account ;-)

Also, as the usage of keys and secret keys can be cumbersome at one point, you can store those keys in the configuration of the CLI.
Just use the followin lines of code once:

    $ wfl config set secretAccessKey "/YBzjQIExFEXAMPLEum0ZxKEYjIVCS"
    $ wfl config set accessKeyId "AKACCESSL3JKEYDEDPID"
    
All the subsequent call to wfl will use these credentials unless:
* you use specify ones with the ```-k``` and ```-s``` modifiers
* you configure new ones with the ```wfl config set``` commands

## SWF Domain management
Syntax : 

    $ wfl domain
    
    help:    wfl domain * commands allow you manage your worflow
    help:    domains. Valid commands are:
    help:    
    help:    wfl domain list
    help:    wfl domain create <domain-name>
    help:    
    help:    Options:
    help:      --secretAccessKey, -s  your AWS secret key  [string]
    help:      --accessKeyId, -k      your AWS access key  [string]

Use:

    $ wfl domain create <domain-name>
    
To REGISTER a domain in your AWS account.

To get the list of active REGISTERED domains type:

    $ wfl domain list 


## SWF Workflow types management
Syntax :

    $ wfl workflow
    
    help:    wfl workflow * commands allow you manage your worflow
    help:    Valid commands are:
    help:    
    help:    wfl workflow list <domain-name>
    help:    wfl workflow create <domain-name> <workflow-name>
    help:    wfl workflow start <domain-name> <workflow-name> [<input-value>]
    help:    
    help:    Options:
    help:      --secretAccessKey, -s  your AWS secret key  [string]
    help:      --accessKeyId, -k      your AWS access key  [string]

## SWF Activity types management
Syntax :

    $ wfl activity
    
    help:    wfl activity * commands allow you manage your worflow
    help:    activitys. Valid commands are:
    help:    
    help:    wfl activity list <domain-name> <workflow-name>
    help:    wfl activity create <domain-name> <workflow-name> <activity-name>
    help:    
    help:    Options:
    help:      --secretAccessKey, -s  your AWS secret key  [string]
    help:      --accessKeyId, -k      your AWS access key  [string]


## SWF Decider management
Deciders are a specific activity type. For the sakes of simplicity, I decided to limit to one decider process per workflow.
With the CLI you can strart a decider for a specific workflow with the following command :

    $ wfl decider run <domain-name> <workflow-name>

WFL framework will sarch for a nodejs module called **<domain-name>-<workflow-name>-decider.js** in the *workers* directory of WFL.
Development of a decider must follow WFL coding rules (e.g. subclass the Decider 'class' provided by the WFL framework). 
Implementation details in the *"How to code your own workflow activities with WFL"* of this readme file.



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


