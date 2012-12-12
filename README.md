# zmore
## A lightweight companion on your Maven journeys
zmore (read it like "Zeddemore") is an attempt to (loosely) port to my
everyday experience with Maven, some of the awesomeness I could find in
other worlds like Node.js with `npm`, Python with `pip`, common web
development with `bower` or `yeoman`, and so on.

## Install zmore
To run zmore, obviously enough you will first need Maven, a JDK, and Bash.
You will also need:

* `wget` to install zmore itself
* `git` and `xclip` to use `zmore install $GIT_REPO`

When you are ready to go, installing zmore is as easy as opening a terminal, 
and launching this:  
```
wget http://---------raw/zmore-install.sh | sudo bash
```

The installer will:

* download zmore
* copy it in `/usr/local/bin` (it will create the directories as needed)
* make it executable with a `chmod 777`

If you feel uncomfortable with scripts executing other scripts with `sudo`, 
you can just download `zmore.sh` and put it where you want it, how you want
it.

## Install a Maven artifact from sources
This is zmore's specialty.

Found an interesting Java library, developed and taken care of using Maven, on
GitHub | BitBucket | Gitorious | Whatever?

You could (and **should**) head to http://search.maven.org/ and see if it's
available on Maven Central.  
If it's not, you should then read this: <insert link to sonatype OSS guide here>

Then, if all in all you just want to have it installed from sources, 
**who you gonna call?**

`zmore install git://github.com/entando/entando-core-engine.git --verbose`

zmore will then:

* clone a local copy of the git repository in `~/.zmore/cache/`
* run `mvn clean install -DskipTests`
* print out a basic XML snippet for the `pom.xml`
* copy that XML snippet to your clipboard using `xclip -selection clipboard`

zmore will also create `~/.zmore/cache/` if needed.