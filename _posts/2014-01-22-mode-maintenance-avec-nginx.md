---
layout: post
title: Mode maintenance avec nginx
tags: [nginx]
image:
  feature: slides/default.jpg
comments: true
share: true
---

Je cherchais une méthode simple pour mettre un site en maintenance, par exemple 
pendant des mises à jour de code. Je voulais une solution la plus simple et la 
plus légère possible, inutile de charger autre chose que du HTML pour une page 
de maintenance.

[Nginx][nginx] propose dans ses fichiers de configuration, un langage de script 
qui permet entre autre de définir des variables ou encore des conditions, afin 
par exemple de tester la présence d'un fichier sur le filesystem. Le mode 
maintenance ci-dessous ne s'activera que sous la présence d'un fichier :

{% highlight nginx %}
server {
    listen 80;
    server_name mysite.com;
    root /home/project/web;
    # etc.

    if (-f /home/project/maintenance.lock) {
        set $maintenance 1;
    }

    # Remplacez ici par votre IP locale
    if ($remote_addr = "127.0.0.1") {
        set $maintenance 0;
    }

    if ($maintenance = 1) {
        return 503;
    }

    error_page 503 @maintenance;

    location @maintenance {
        rewrite ^(.*)$ /maintenance.html break;
    }
}
{% endhighlight %}

Concrêtement la présence du fichier `maintenance.lock` va activer le mode 
maintenance, sauf si l'IP du client est une IP autorisée. Cela vous permettra de 
tester votre site alors que les autres internautes auront un accès coupé au 
site.

Il ne vous reste plus qu'à créer une [simple page][maintenance_html] 
`maintenance.html` pour avertir vos visiteurs.

[nginx]: http://nginx.org/
[maintenance_html]: https://gist.github.com/pitch-gist/2999707
