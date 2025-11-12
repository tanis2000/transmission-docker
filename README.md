# Transmission Docker image for x64, armv7 and arm64

Running the image

```sh
docker run -d \
  --name=transmission \
  -p 45556:45556 \
  -p 9091:9091 \
  -v /data/transmission:/transmission/config \
  -v /data/transmission/incomplete:/incomplete \
  -v /data/transmission/downloads:/downloads \
  -v /data/transmission/watch:/watch \
  --restart unless-stopped \
  tanis2000/transmission:4.0.5
```
