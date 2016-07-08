# Correspondence Tools - Public

A simple application to allow public users to submit correspondence. A present this only forwards the request to a set email address.

##Local development

###Clone this repository change to the new directory

```bash
$ git clone git@github.com:ministryofjustice/correspondence_tool_public.git
$ cd correspondence_tool_public
```

### Setup Docker 

The reason Docker is used in while in development is to overcome issues with Ruby,Rails, Postgres version conflicts and time to set these up for new developers.

Majority of the team uses Docker Toolbox. Docker for Mac is currently in beta but for the time being just use Docker Toolbox. Download and follow the [installation instructions](https://docs.docker.com/toolbox/toolbox_install_mac/)

###Build Docker Image and bring the Docker Containers up
First build the initial docker image that will be used for the container.

In the root directory of the project run the following

```
$ docker-compose build

...Loads of installation output ...

Successfully built -- Random image ID --

$ docker-compose up

...outputs the following
Recreating correspondencetoolpublic_web_1
Attaching to correspondencetoolpublic_web_1
web_1  | Puma starting in single mode...
web_1  | * Version 3.4.0 (ruby 2.3.1-p112), codename: Owl Bowl Brawl
web_1  | * Min threads: 5, max threads: 5
web_1  | * Environment: development
web_1  | * Listening on tcp://0.0.0.0:3000
web_1  | Use Ctrl-C to stop

```

To access the site you need to find the IP address of the docker machine.

```
$ docker-machine ip
192.168.99.100
$ 
```
So if you open your favourite web browser and go to https://192.168.99.100:3000 (obviously substitute the ip with the docker machines ip)

You should be greeted with the services home page

###Questions about Docker

#### 1. Where should I make the changes?
The docker containers use a symlink to your local machine so any changes you make to the project files will automatically be synced with the docker containers. However if you if you need to ```bundle install``` then its best to SSH into the docker container and run it from there. The reason for this is that it will then us the docker containers version of Ruby/Rails to install the gems.

####2. Do I have to rebuild the Docker Image after I made changes to the local files?
No, as mentioned in question 1. the rails files are sync automatically with your local machine.