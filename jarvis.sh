#!/bin/bash

# Function to create an entity
create_entity() {
    PACKAGE_NAME=$1
    ENTITY_NAME=$2
    ENTITY_FILE=src/main/java/${PACKAGE_NAME//.//}/entity/${ENTITY_NAME}.java

    # Check if the entity folder exists, if not create it
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

# Function to create a repository
create_repository() {
    PACKAGE_NAME=$1
    ENTITY_NAME=$2
    REPOSITORY_NAME=${ENTITY_NAME}Repository
    REPOSITORY_FILE=src/main/java/${PACKAGE_NAME//.//}/repository/${REPOSITORY_NAME}.java

    # Check if the repository folder exists, if not create it
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

# Function to create a service
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

# Main script logic
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 create {controller|service|entity|repository} <Package.Name> <Name>"
    exit 1
fi

COMMAND=$1
TYPE=$2
PACKAGE_NAME=$3
NAME=$4

case $TYPE in
    controller)
        create_controller $PACKAGE_NAME $NAME
        ;;
    service)
        create_service $PACKAGE_NAME $NAME
        ;;
    entity)
        create_entity $PACKAGE_NAME $NAME
        ;;
    repository)
        create_repository $PACKAGE_NAME $NAME
        ;;
    *)
        echo "Invalid type. Valid types are: controller, service, entity, repository."
        exit 1
        ;;
esac

############################################################################################



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

# Main script logic
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 prompt openai <your_prompt>"
    exit 1
fi

ACTION=$1
TYPE=$2
PROMPT=$3

case $TYPE in
    openai)
        if [ "$ACTION" == "prompt" ]; then
            create_or_update_repository "com.example" "$PROMPT"
        else
            echo "Invalid action. Valid action is: prompt"
            exit 1
        fi
        ;;
    *)
        echo "Invalid type. Valid type is: openai"
        exit 1
        ;;
esac