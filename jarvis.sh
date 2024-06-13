#!/bin/bash

# function to create an entity
create_entity() {
    PACKAGE_NAME=$1
    ENTITY_NAME=$2
    ENTITY_FILE=src/main/java/${PACKAGE_NAME//.//}/entity/${ENTITY_NAME}.java

    # check if the entity folder exists, if not create it
    if [ ! -d "src/main/java/${PACKAGE_NAME//.//}/entity" ]; then
        mkdir -p src/main/java/${PACKAGE_NAME//.//}/entity
    fi

    cat <<EOL > $ENTITY_FILE
package ${PACKAGE_NAME}.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import io.quarkus.hibernate.orm.panache.PanacheEntity;
import lombok.Data;

@Entity
@Data
public class ${ENTITY_NAME} extends PanacheEntity {

    // Add your fields here
    private String name;

}
EOL
    echo "Entity ${ENTITY_NAME} created successfully."
}

# function to create a repository
create_repository() {
    PACKAGE_NAME=$1
    ENTITY_NAME=$2
    REPOSITORY_NAME=${ENTITY_NAME}Repository
    REPOSITORY_FILE=src/main/java/${PACKAGE_NAME//.//}/repository/${REPOSITORY_NAME}.java

    # check if the repository folder exists, if not create it
    if [ ! -d "src/main/java/${PACKAGE_NAME//.//}/repository" ]; then
        mkdir -p src/main/java/${PACKAGE_NAME//.//}/repository
    fi

    cat <<EOL > $REPOSITORY_FILE
package ${PACKAGE_NAME}.repository;

import ${PACKAGE_NAME}.entity.${ENTITY_NAME};
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ${REPOSITORY_NAME} implements PanacheRepository<${ENTITY_NAME}> {
    // Custom repository methods can be added here
}
EOL
    echo "Repository ${REPOSITORY_NAME} created successfully."
}

# function to create a service
create_service() {
    PACKAGE_NAME=$1
    SERVICE_NAME=$2
    SERVICE_FILE=src/main/java/${PACKAGE_NAME//.//}/service/${SERVICE_NAME}Service.java

    # Check if the service folder exists, if not create it
    if [ ! -d "src/main/java/${PACKAGE_NAME//.//}/service" ]; then
        mkdir -p src/main/java/${PACKAGE_NAME//.//}/service
    fi

    cat <<EOL > $SERVICE_FILE
package ${PACKAGE_NAME}.service;

import ${PACKAGE_NAME}.entity.${SERVICE_NAME};
import ${PACKAGE_NAME}.repository.${SERVICE_NAME}Repository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.util.List;

@ApplicationScoped
public class ${SERVICE_NAME}Service {

    @Inject
    ${SERVICE_NAME}Repository ${SERVICE_NAME,,}Repository;

    public List<${SERVICE_NAME}> findAll() {
        return ${SERVICE_NAME,,}Repository.listAll();
    }

    @Transactional
    public void add(${SERVICE_NAME} ${SERVICE_NAME,,}) {
        ${SERVICE_NAME,,}Repository.persist(${SERVICE_NAME,,});
    }

    // Other service methods can be added here
}
EOL
    echo "Service ${SERVICE_NAME}Service created successfully."
}

# Function to create a controller
create_controller() {
    PACKAGE_NAME=$1
    CONTROLLER_NAME=$2
    CONTROLLER_FILE=src/main/java/${PACKAGE_NAME//.//}/controller/${CONTROLLER_NAME}Controller.java

    # Check if the controller folder exists, if not create it
    if [ ! -d "src/main/java/${PACKAGE_NAME//.//}/controller" ]; then
        mkdir -p src/main/java/${PACKAGE_NAME//.//}/controller
    fi

    cat <<EOL > $CONTROLLER_FILE
package ${PACKAGE_NAME}.controller;

import ${PACKAGE_NAME}.entity.${CONTROLLER_NAME};
import ${PACKAGE_NAME}.service.${CONTROLLER_NAME}Service;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import java.util.List;

@Path("/${CONTROLLER_NAME,,}s")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ${CONTROLLER_NAME}Controller {

    @Inject
    ${CONTROLLER_NAME}Service ${CONTROLLER_NAME,,}Service;

    @GET
    public List<${CONTROLLER_NAME}> getAll() {
        return ${CONTROLLER_NAME,,}Service.findAll();
    }

    @POST
    public void add(${CONTROLLER_NAME} ${CONTROLLER_NAME,,}) {
        ${CONTROLLER_NAME,,}Service.add(${CONTROLLER_NAME,,});
    }

    // Other endpoints can be added here
}
EOL
    echo "Controller ${CONTROLLER_NAME}Controller created successfully."
}

# Function to call the Python AI assistant script
call_openai() {
    local prompt=$1
    python3 ai_assistant.py "$prompt"
}

# Function to create or update a repository with CRUD operations
create_or_update_repository() {
    PACKAGE_NAME=$1
    ENTITY_NAME=$2
    REPOSITORY_NAME=${ENTITY_NAME}Repository
    REPOSITORY_FILE=src/main/java/${PACKAGE_NAME//.//}/repository/${REPOSITORY_NAME}.java

    mkdir -p src/main/java/${PACKAGE_NAME//.//}/repository

    CRUD_CODE=$(call_openai "Generate the CRUD operations for the ${ENTITY_NAME} model in Java using Quarkus and Panache")

    if [ -f "$REPOSITORY_FILE" ]; then
        echo "Repository file ${REPOSITORY_FILE} already exists. Appending CRUD operations."
        # Append CRUD methods inside the class
        sed -i "/^}/i \\$CRUD_CODE" $REPOSITORY_FILE
    else
        cat <<EOL > $REPOSITORY_FILE
package ${PACKAGE_NAME}.repository;

import ${PACKAGE_NAME}.entity.${ENTITY_NAME};
import io.quarkus.hibernate.orm.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ${REPOSITORY_NAME} implements PanacheRepository<${ENTITY_NAME}> {
    // Custom repository methods can be added here

$CRUD_CODE
}
EOL
        echo "Repository with CRUD operations for ${ENTITY_NAME} created successfully."
    fi
}

# Function to perform HTTP GET request
http_get() {
    echo "Enter the URL for GET request:"
    read url
    curl -X GET "$url" -H "Accept: application/json"
}

# Function to perform HTTP POST request
http_post() {
    echo "Enter the URL for POST request:"
    read url
    echo "Enter the JSON data for the POST request:"
    read data
    curl -X POST "$url" -H "Content-Type: application/json" -d "$data"
}

# Function to perform HTTP PUT request
http_put() {
    echo "Enter the URL for PUT request:"
    read url
    echo "Enter the JSON data for the PUT request:"
    read data
    curl -X PUT "$url" -H "Content-Type: application/json" -d "$data"
}

# Function to perform HTTP DELETE request
http_delete() {
    echo "Enter the URL for DELETE request:"
    read url
    curl -X DELETE "$url" -H "Accept: application/json"
}

# Function to handle HTTP requests
http_request() {
    echo "Choose the HTTP method (GET, POST, PUT, DELETE):"
    read method
    case $method in
        GET)
            http_get
            ;;
        POST)
            http_post
            ;;
        PUT)
            http_put
            ;;
        DELETE)
            http_delete
            ;;
        *)
            echo "Invalid HTTP method selected."
            ;;
    esac
}


########################################################################################################################
# Detect project language and framework
detect_project_info() {
    PROJECT_DIR=$1
    CONFIG_FILE=$2

    # Initialize variables
    LANGUAGE=""
    FRAMEWORK=""
    PACKAGE_NAME=""

    # Detect the language and framework based on file extensions and contents
    if [ "$(find $PROJECT_DIR -name '*.java' | wc -l)" -gt 0 ]; then
        LANGUAGE="Java"
        if grep -q "spring-boot" $(find $PROJECT_DIR -name 'pom.xml' -o -name 'build.gradle'); then
            FRAMEWORK="Spring Boot"
        elif grep -q "quarkus" $(find $PROJECT_DIR -name 'pom.xml' -o -name 'build.gradle'); then
            FRAMEWORK="Quarkus"
        fi
        PACKAGE_NAME=$(grep -oP 'package \K[\w\.]+' $(find $PROJECT_DIR -name '*.java' | head -n 1))
    elif [ "$(find $PROJECT_DIR -name '*.py' | wc -l)" -gt 0 ]; then
        LANGUAGE="Python"
        if grep -q "flask" $(find $PROJECT_DIR -name 'requirements.txt'); then
            FRAMEWORK="Flask"
        elif grep -q "django" $(find $PROJECT_DIR -name 'requirements.txt'); then
            FRAMEWORK="Django"
        fi
    fi

    # Generate the configuration file
    cat <<EOL > $CONFIG_FILE
{
  "project_name": "$(basename $PROJECT_DIR)",
  "language": "$LANGUAGE",
  "framework": "$FRAMEWORK",
  "package_name": "$PACKAGE_NAME",
  "entity_path": "$PROJECT_DIR/src/main/java/${PACKAGE_NAME//.//}/entity",
  "repository_path": "$PROJECT_DIR/src/main/java/${PACKAGE_NAME//.//}/repository",
  "service_path": "$PROJECT_DIR/src/main/java/${PACKAGE_NAME//.//}/service",
  "controller_path": "$PROJECT_DIR/src/main/java/${PACKAGE_NAME//.//}/controller"
}
EOL

    echo "Configuration file $CONFIG_FILE created successfully."
}

PROJECT_DIR="path_to_your_project"
CONFIG_FILE="project_config.json"
detect_project_info $PROJECT_DIR $CONFIG_FILE

########################################################################################################################
# Main menu
while true; do
    echo "Choose an option:"
    echo "1. Generate Code with AI"
    echo "2. Create Controller"
    echo "3. Create Service"
    echo "4. Create Entity"
    echo "5. Create Repository"
    echo "6. HTTP Request"
    echo "7. Exit"
    read choice
    case $choice in
        1)
            echo "Enter your prompt for code generation:"
            read prompt
            call_openai "$prompt"
            ;;
        2)
            echo "Enter package name for controller:"
            read package_name
            echo "Enter controller name:"
            read controller_name
            create_controller $package_name $controller_name
            ;;
        3)
            echo "Enter package name for service:"
            read package_name
            echo "Enter service name:"
            read service_name
            create_service $package_name $service_name
            ;;
        4)
            echo "Enter package name for entity:"
            read package_name
            echo "Enter entity name:"
            read entity_name
            create_entity $package_name $entity_name
            ;;
        5)
            echo "Enter package name for repository:"
            read package_name
            echo "Enter entity name:"
            read entity_name
            create_repository $package_name $entity_name
            ;;
        6)
            http_request
            ;;
        7)
            echo "Exiting Jarvis. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done



