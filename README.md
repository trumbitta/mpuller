# mpuller
## A lightweight companion on your Maven journeys
mpuller is an attempt to (loosely) port to my
everyday experience with Maven, some of the awesomeness I could find in
other worlds like Node.js with `npm`, Python with `pip`, common web
development with `bower` or `yeoman`, and so on.

## A gentle warning and a plea
mpuller is still young and thus a mess.  
It works, but it's ugly and incomplete.

So please be gentle, but also use it and get in touch!  
Use the issues, fork it and submit pull-requests, blame me.

## Install mpuller
To run mpuller, obviously enough you will first need Maven, a JDK, and Bash.
You will also need:

* `wget` to install mpuller itself
* `git` and `xclip` to use `mpuller install $GIT_REPO`

When you are ready to go, installing mpuller is as easy as opening a terminal, 
and launching this:  
```
wget http://---------raw/mpuller-install.sh | sudo bash
```

The installer will:

* download mpuller
* copy it in `/usr/local/bin` (it will create the directories as needed)
* make it executable with a `chmod 777`

If you feel uncomfortable with scripts executing other scripts with `sudo`, 
you can just download `mpuller.sh` and put it where you want it, how you want
it.

## Install a Maven artifact from sources
This is mpuller's specialty.

Found an interesting Java library, developed and taken care of using Maven, on
GitHub | BitBucket | Gitorious | Whatever?

You should head to http://search.maven.org/ and see if it's
available on Maven Central.  
If it's not, you should then read *[Uploading 3rd-party Artifacts to The Central Repository](https://docs.sonatype.org/display/Repository/Uploading+3rd-party+Artifacts+to+The+Central+Repository)*.

Then, if all in all what you really want is just to have it installed from sources, 
**who you gonna call?**

`mpuller install git://github.com/entando/entando-core-engine.git`

mpuller will then:

* clone a local copy of the git repository in `~/.mpuller/cache/`
* checkout master
* run `mvn clean install -DskipTests`
* print out a basic XML snippet for the `pom.xml`
* copy that XML snippet to your clipboard using `xclip -selection clipboard`

mpuller will also create `~/.mpuller/cache/` if needed.

### Other examples

`mpuller install git://github.com/entando/entando-core-engine.git -b develop`  
install the `develop` branch instead of `master`

## Credits
Oskar Schöldström for [oxyc/bash-boilerplate](https://github.com/oxyc/bash-boilerplate)

##Copyright and license
Copyright 2012 William Ghelfi (trumbitta @ github)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.