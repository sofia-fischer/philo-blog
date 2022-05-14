# Philodev Blog

See the Blog: [www.blog.philodev.one](https://www.blog.philodev.one/)

## Info About the Side

### Hugo

Hugo is a static site generator written in Go. Consequently releases ship as a single binary and there is support for
every major platform.

> [Hugo Documentation](https://gohugo.io/documentation/)

### Theme Congo

The Theme I used was Congo - main reason was because it supports Tailwind so I could change and overwrite the tailwind
conf when needed. 

> [Congo Documentation](https://jpanther.github.io/congo/)
> 
> [Congo GitHub](https://github.com/jpanther/congo)

## Development

For local development run: 
```shell
hugo server
```

Development Server will start at `http://localhost:1313/`

If tailwind is not working, start the npm watch: 
```shell
 npm run watch
```

### Adding Content

To add a new blog page you may use the command: 

```shell
 hugo new posts/2022-05-11-new-side.md
```

## Deployment

The Deployment uses Github Actions, which are triggered by pushing to master and inspired
by [This Blog Post](https://jgandrews.com/posts/build-and-deploy-a-blog/#self-hosting), but also my other Deployment
Pipelines. The following steps are required to deploy:

1. Build the side

```shell
hugo --minify
```

2Push to master

