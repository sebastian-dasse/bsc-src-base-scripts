#!/usr/bin/env bash

# project="my-project"
# title="My Project"

while [ -z "${project}" ]; do
  read -p "Short name for your project: " project
done

read -p "Long name (optional):        " title

if [ -z "${title}" ]; then
  title="${project}"
fi

#-----------------------------------------------------------

mkdir -v ${project}
cd ${project}

#-----------------------------------------------------------

mkdir -v project

#-----------------------------------------------------------

echo "sbt.version=0.13.8" > project/build.properties

#-----------------------------------------------------------

cat > project/plugins.sbt << EOL
addSbtPlugin("org.scala-js" % "sbt-scalajs" % "0.6.4")

addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "4.0.0")
EOL

#-----------------------------------------------------------

srcRootDir=library
htmlDir=${srcRootDir}/js/src/main/resources

mkdir -v ${srcRootDir}
mkdir -v ${srcRootDir}/js
mkdir -v ${srcRootDir}/js/src
mkdir -v ${srcRootDir}/js/src/main
mkdir -v ${srcRootDir}/js/src/main/scala
mkdir -v ${srcRootDir}/js/src/main/resources
# mkdir -v ${srcRootDir}/js/src/test
# mkdir -v ${srcRootDir}/js/src/test/scala
mkdir -v ${srcRootDir}/jvm
mkdir -v ${srcRootDir}/jvm/src
mkdir -v ${srcRootDir}/jvm/src/main
mkdir -v ${srcRootDir}/jvm/src/main/scala
# mkdir -v ${srcRootDir}/jvm/src/test
# mkdir -v ${srcRootDir}/jvm/src/test/scala
mkdir -v ${srcRootDir}/shared
mkdir -v ${srcRootDir}/shared/src
mkdir -v ${srcRootDir}/shared/src/main
mkdir -v ${srcRootDir}/shared/src/main/scala
mkdir -v ${srcRootDir}/shared/src/test
mkdir -v ${srcRootDir}/shared/src/test/scala

#-----------------------------------------------------------

cat > build.sbt << EOL
name := "${project}"

lazy val root = project
  .in(file("."))
  .enablePlugins(ScalaJSPlugin)
  .aggregate(libJS, libJVM)
  .settings(
    publish := {},
    publishLocal := {}
  )

lazy val library = crossProject
  .in(file("./${srcRootDir}"))
  .settings(
    name := "Lib",
    version := "1.0",
    scalaVersion := "2.11.7",
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8",
      "-feature",
      "-unchecked",
      "-Xfatal-warnings",
      "-Xlint"
    ),
    libraryDependencies ++= Seq(
      "com.lihaoyi" %%% "utest" % "0.3.1" % "test"
    ),
    testFrameworks += new TestFramework("utest.runner.Framework")
  ).jsSettings(
    name := "${project}-JS",
    scalaJSStage in Global := FastOptStage, // to use Node.js or PhantomJS for tests
    jsDependencies in Test += RuntimeDOM    // to use PhantomJS for tests
  ).jvmSettings(
    name := "${project}-JVM"
    // JVM-specific settings here
  )

lazy val libJS = library.js
lazy val libJVM = library.jvm
EOL

#-----------------------------------------------------------

createHtml ()
{
  case "${1}" in
    "dev" )
      htmlSuff="-dev"
      jsSuff="fastopt"
      ;;
    "prod" )
      htmlSuff=""
      jsSuff="opt"
      ;;
  esac

cat > ${htmlDir}/index${htmlSuff}.html << EOL
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>"${title}"</title>
</head>
<body>
  <script src="../${project}-${jsSuff}.js"></script>
  <script>
    /* Your main here, e.g.: */
    // hello.HelloApp.main();
  </script>
</body>
</html>
EOL
} # end createHtml

createHtml dev
createHtml prod

#-----------------------------------------------------------

cat > .gitignore << EOL
## SBT ##
target/

## Eclipse ##
.settings/
.classpath
.project
.cache*

## IntelliJ ##
.idea/
#.idea/workspace.xml
.idea_modules/

## Node.js ##
node_modules/

*.log
EOL

#-----------------------------------------------------------

cat > README.md << EOL
# ${title}

## Run tests

Simply run \`sbt test\`.

For a test run with logs run \`sbt test > test.log\`.


## IntelliJ

IntelliJ does not support referencing to the shared directory. But this is just the IDE. The compiler understands the shared code. So it works as it is supposed to.
EOL

#-----------------------------------------------------------

npm -y init
npm install source-map-support --save-dev

#-----------------------------------------------------------

git init
git add -A
git commit -am "Initial commit."

#-----------------------------------------------------------

echo "**********"
echo "A basic setup for '${title}' has been created for you in:"
pwd
echo "The build.sbt is very basic, so you might want to adjust it to your needs."
echo "**********"
