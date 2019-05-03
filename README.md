# frontend-provisions

## Set environment variables
```bash
$ vi .env
```

## Backend initailize
```bash
$ docker-compose run terraform init -backend-config="token=<token>"
```

## Run command
```bash
$ docker-compose run terraform <command>
```

> To run locally without aws.prod access key, use `-target=module.dev` option
