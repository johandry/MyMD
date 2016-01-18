# MyMD (My Movies Dashboard)

My Movies Dashboard is a web application with my private collection of movies. This dashboard is updated weekly from my movies in iTunes and manually for my movies in DVD and BR.

## Development

The application is encapsulated in a Vagrant box or a Docker container. 

### Vagrant

To start up the development with Vagrant you need to have Vagrant and VirtualBox installed. The clone the repository, build the Vagrant box and login into it.

```
git clone git@github.com:johandry/MyMD.git
cd MyMDB
vagrant up
vagrant ssh
```
In case this is a new development using yeoman, you have to:

```
cd ~/workspace
mkdir src
cd src
yo
```
Select the application type you will develop (i.e. angular) and Yeoman will create everything. In case of angular you may select everything but using Sass.

Execute the vagrant/puppet provisioning again in your host to fix the Gruntfile.js. 

```
vagrant provision
```
In the vagrant box now you can run the server to watch the application and see every change you do in the code. You can code in your host 

```
vagrant ssh
cd ~/workspace/src
grunt serve
```
In your host:

```
open http://localhost:9000/
```
Code your files with sublime text in your host and whatch the changes in your broweser.

##Testing

###Vagrant
Go to the Vagrant box and run:

```
vagrant ssh
cd ~/workspace/src
grunt test
```

##Deployment
###Vagrant
Go to the Vagrant box and run:

```
vagrant ssh
cd ~/workspace/src
grunt
``` 
The production code is ready in ~/workspace/dist. This will will be in the ~/workspace later.

##Clean Up

###Vagrant
To cleanup everything just do:

```
vagrant destroy -f
rm -rf .vagrant
rm -rf src/bower_components
rm -rf src/dist
rm -rf src/node_modules
```
