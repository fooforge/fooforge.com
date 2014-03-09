server {
  listen 8000;
  root /var/www/fooforge.com/_site;
  index index.html;

  server_name localhost;

  location / {
    try_files $uri $uri/ /index.html;
  }
}
