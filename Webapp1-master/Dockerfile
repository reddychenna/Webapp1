#Dockefile for creating a docker image : Ubuntu + Apache + Pyhton + Flask
#Commnet
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y python python-pip wget gcc phantomjs firefox

RUN apt-get install -y xvfb

RUN apt-get install -y lynx

RUN apt-get install sudo 

RUN sudo apt install  -y apache2

RUN sudo apt install -y vim

RUN sudo pip install Flask

RUN pip install robotframework
RUN pip install robotframework-sshlibrary
RUN pip install robotframework-selenium2library
RUN pip install Flask-SqlAlchemy
EXPOSE 4000

WORKDIR  /home

RUN  mkdir -pv /home/templates/
ADD app1.py /home
ADD app2.py /home
ADD app3.py /home
ADD app4.py /home
RUN chmod +x /home/app4.py
ADD dummy.py /home
ADD tabledef.py /home
ADD test1.robot /home
RUN /usr/bin/python  tabledef.py
RUN /usr/bin/python  dummy.py
 
ADD index.html /home/templates
ADD login1.html /home/templates

RUN mkdir -pv /home/static/
ADD style.css /home/static
#ADD  /sbin/ifconfig /home
#ENTRYPOINT ["/usr/bin/python", "app4.py"]
ENTRYPOINT ["nohup", "/usr/bin/python","/home/app4.py", "&"]
#Added comment to checkin the file.
