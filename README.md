maven-helper
============

Tool written in Perl to help with maven commands to be run on multiple profiles or binding profiles to env's.

```
usage: mvnhlp (options) maven_command_list

Examles:
         mvnhlp --env=prod --app=CoolApp clean install
         mvnhlp --env=test --app=CoolApp clean war:war tomcat:redeploy
         mvnhlp --env=test --pattern=Service clean war:war tomcat:redeploy
         mvnhlp -P tomcat1 --pattern=all clean war:war tomcat:redeploy
         mvnhlp --list


Parameters:
        -P MVN_PROFILE to specify profile
        --env=ENV to specify environment to target
        --app=APP_NAME tto specify application to work on, or use
        --pattern=APP_NAME_PATTERN command will be used to each application, which name matches pattern. use 'all' to run command list on every application
        --list lists evailable applications and envs
        --help shows this message
```