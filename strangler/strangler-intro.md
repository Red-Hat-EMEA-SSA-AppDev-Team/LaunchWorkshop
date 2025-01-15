## Strangler app

To begin our journey, we'll assume the “Strangler” application.

It's a Spring-based legacy monolith, packaged as a .war that can be deployed on a Tomcat 9 server.

It supports Java 11.

## Running the monolith locally

git clone …

alternative…

export JAVA\_HOME=

mvn clean package 

mvn spring-boot:run

Access http://localhost:8080/