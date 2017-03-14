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

htmlDir=src/main/resources

mkdir -v src
mkdir -v src/main
mkdir -v src/main/scala
mkdir -v src/main/resources
mkdir -v src/test
mkdir -v src/test/scala

#-----------------------------------------------------------

cat > build.sbt << EOL
enablePlugins(ScalaJSPlugin)            // turn this project into a Scala.js project by importing these settings

name := "${project}"

version := "1.0"

scalaVersion := "2.11.7"

scalacOptions ++= Seq(
  "-deprecation",
  "-encoding", "UTF-8",
  "-feature",
  "-unchecked",
  "-Xfatal-warnings",
  "-Xlint"
)

scalaJSStage in Global := FastOptStage

EclipseKeys.withSource := true
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

## Development

Run \`sbt\` and then \`~fastOptJS\`.
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
