{
    "name": "Go",
    "build": {
		"dockerfile": "Dockerfile.go",
		// "args": {
		// 	// Update the VARIANT arg to pick a version of Go: 1, 1.15, 1.14
		// 	"VARIANT": "1.14",
		// 	// Options
		// 	"INSTALL_NODE": "false",
        //     "NODE_VERSION": "lts/*",
		// }
	},
    "settings": { 
		"terminal.integrated.shell.linux": "/bin/bash",
		"go.useGoProxyToCheckForToolUpdates": false,
		"go.useLanguageServer": true,
		"go.gopath": "/go",
		"go.goroot": "/usr/local/go",
		"go.toolsGopath": "/go/bin"
	},
    "forwardPorts": [
        "8080"
    ],
    "extensions": [ 
       "golang.Go"
    ],
    "containerEnv": {
        "DATABASE_URL": "postgres://postgres:postgres@host.docker.internal:5432/public"
    }
 }