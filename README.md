# janus-local-run

Create a local operating environment for Janus for Web RTC in a Docker container.


## How to use

Please try image-name with any name you like.
### Souce Clone
git clone git@github.com:pyuta-gh/janus-local-run.git

### Image build method

```shell
docker build -t image-name .
```

### Start container from image
```shell
docker run -itd -p 8088:8088 -p 8000:8000 --name janus -d image-name
```
