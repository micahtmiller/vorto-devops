{
    "dockerFile": "Dockerfile.go",
    "appPort": [
        "8080:8080"
    ],
    "extensions": [ 
       "golang.go" 
    ],
    "containerEnv": {
        "DATABASE_URL": "postgres://postgres:postgres@host.docker.internal:5432/public"
    }
 }