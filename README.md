# mpuller
## A lightweight companion on your Maven journeys
mpuller is an attempt to (loosely) port to my
everyday experience with Maven, some of the awesomeness I could find in
other worlds like Node.js with `npm`, Python with `pip`, common web
development with `bower` or `yeoman`, and so on.

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

You could (and **should**) head to http://search.maven.org/ and see if it's
available on Maven Central.  
If it's not, you should then read this: `__insert link to sonatype OSS guide here__`

Then, if all in all you just want to have it installed from sources, 
**who you gonna call?**

`mpuller install git://github.com/entando/entando-core-engine.git --verbose`

mpuller will then:

* clone a local copy of the git repository in `~/.mpuller/cache/`
* run `mvn clean install -DskipTests`
* print out a basic XML snippet for the `pom.xml`
* copy that XML snippet to your clipboard using `xclip -selection clipboard`

mpuller will also create `~/.mpuller/cache/` if needed.

## Credits
Oskar Schöldström for [oxyc/bash-boilerplate](https://github.com/oxyc/bash-boilerplate)
