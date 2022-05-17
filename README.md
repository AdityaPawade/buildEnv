# buildEnv

### Sample Usage

"$BUILD_ENV"/make.sh **app** build_env

"$BUILD_ENV"/make.sh **app** build_jar linux

"$BUILD_ENV"/make.sh **app** run_jar linux **mainModule** **1.0.0** '**-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Dconfig=conf/local/app.properties**' **com.adtsw.app.MainClass** **app_arg**

"$BUILD_ENV"/make.sh **app** stop linux **mainModule**

"$BUILD_ENV"/make.sh **app** package linux **mainModule** **1.0.0** **server** **user/repo:tag**

"$BUILD_ENV"/make.sh **app** publish_to_docker linux **user/repo:tag**