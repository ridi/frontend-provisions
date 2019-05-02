# frontend-provisions

## Set environment variables
```bash
$ vi .env
```

## Initailize
```bash
$ docker-compose run terraform workspace select <prod|dev>
$ docker-compose run terraform init -backend-config="token=<token>"
```

## Run command
```bash
$ docker-compose run terraform <command>
```
