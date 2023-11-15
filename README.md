<h1>GitOps Deployer</h1>

> First thing first, what is **GitOPS**?
> GitOPS is the best practice of DevOPS.

https://www.atlassian.com/git/tutorials/gitops

https://about.gitlab.com/topics/gitops/

![workflow.jpeg](workflow.jpeg)

Credit to: Andy Ng www.webcoder.io

Golang-powered Gin API, a DevOps powerhouse, excels in Git-to-server deployment, overcoming Rsync/SCP limitations and tailored for scenarios restricting SSH access, making it ideal for Docker microservices. Seamlessly integrate with GitHub Action pipelines for the fastest, Jenkins-killer bash-driven CI/CD in restricted environments, enhancing security constraints by pulling from GitHub releases. Master deployment with speed, security, and microservices finesse.

Features:
- `make init` to initialize everythign for the first time only. (Do not run this again or it will remove all your service containers.)
- One-Command `make` to bring everything up: Docker, The deployer service.
- `make ssh` to exec the container, `make down` to bring the service down
- Port is on `8080` open and exposed. You may use nginx `proxy` or traefik redirect for redirect traffic if you cannot open extra port in your AWS.




<h2>Proxy Options</h2>
  
***Nginx***

```
server {
    listen 80;
    server_name example.com;

    location ~ ^/deploy/(\d+)$ {
        proxy_pass http://localhost:8080/deploy/$1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Add additional configurations if needed

    location / {
        # Your other configurations for the root path
    }
```

***Apache***

```
<VirtualHost *:80>
    ServerName example.com
    ProxyPass /deploy/queries http://localhost:8080/deploy
    ProxyPassReverse /deploy/queries http://localhost:8080/deploy
</VirtualHost>
```

***Traefik***

```
app:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dynamicPathRouter.rule=Path(`/deploy/{path:.*}`)"
      - "traefik.http.routers.dynamicPathRouter.entrypoints=web"
      - "traefik.http.routers.dynamicPathRouter.middlewares=dynamicPathStrip"
      - "traefik.http.services.dynamicPathService.loadbalancer.server.port=8080"
      - "traefik.http.services.dynamicPathService.loadbalancer.server.scheme=http"
      - "traefik.http.middlewares.dynamicPathStrip.stripprefix.prefixes=/deploy/"
```


