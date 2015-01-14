---
layout: post
title: Exemple d'implémentation d'une API Symfony2 et d'un client AngularJS
tags: [REST, AngularJS]
image:
  feature: slides/leeds1.jpg
comments: true
share: true
---

On parle souvent en ce moment de Single Page Applications (SPA), ces 
applications web riches et interactives à base de Javascript et d'API. Dans cet 
article, j'ai voulu présenter une application complète client / serveur. 
Cependant comme ces 2 aspects sont très différents et complexes, qu'ils 
pourraient faire l'objet d'articles dédiés, j'ai choisi d'utiliser des 
composants permettant de les mettre en place rapidement.

Je vais vous présenter 2 solutions :

* [ng-admin] côté client, il s'agit d'une librairie [AngularJS] réalisée par la 
  société [Marmelab], elle permet de créer une interface d'administration 
  (également appelé CRUD) basée sur les données d'une API REST ;
* [Lionframe] côté serveur, et plus précisemment [SyliusResourceBundle] issu de 
  la solution e-commerce [Sylius], qui permet d'exposer sous la forme d'une API 
  REST des entités Doctrine.

Dans cet article et dans le tutoriel associé 
([que vous trouverez sur Github][api-ng-admin-tutorial]), j'ai repris la version 
de démonstration de ng-admin mais avec une API dynamique en [Symfony2] (à la 
place d'un mock). Il s'agit donc de gérer des posts, des commentaires et enfin 
des tags.

API REST en Symfony2
--------------------

Je ne vais pas présenter la stack classique pour développer une API avec 
[Symfony2], je pense bien sûr aux bundles [FOSRestBundle], 
[JMSSerializerBundle], [Hateoas], [NelmioApiDocBundle], etc. D'autres articles 
s'en chargent très bien et je vous recommande vivement leurs lecture :

* [REST APIs with Symfony2: The Right Way]
* [Symfony2 REST API: the best way]
* [Best practices pour vos APIs REST HTTP avec Symfony2]

Cela faisait quelques semaines que je voulais prendre un moment pour tester 
[SyliusResourceBundle] pour développer une API REST. Les développeurs de 
[Lakion], également principaux développeurs de la solution e-commerce [Sylius], 
l'ont fait avant moi. Leur article [Rapid REST API Development with Lionframe] 
présente comment développer rapidement une API avec [SyliusResourceBundle] et 
indirectement avec [FOSRestBundle] et les librairies [JMSSerializerBundle] et 
[Hateoas].

[SyliusResourceBundle] est évidemment utilisé dans [Sylius], et permet 
d'automatiser toutes les tâches "backend" autour d'une entité Doctrine, en 
d'autres termes le bundle automatise les actions, les formulaires, les listes, 
les filtres, etc. sans pour autant définir de présentation. C'est en ce sens là 
qu'il diffère des autres CRUD et admin generator qu'on peut voir habituellement 
dans [Symfony2]. Et surtout, une de ses fonctionnalités est d'exposer toutes les 
actions "backend" sous la forme d'une API REST.

La mise en place est très simple puisqu'elle se limite à l'installation de 
quelques bundles (voir ci-dessous) et à la définition d'entités Doctrine, des 
validations et la configuration du Serializer.

{% highlight json %}
"require": {
    "sylius/resource-bundle": "0.13.*@dev",
    "sylius/resource": "0.13.*@dev",
    "sylius/storage": "0.13.*@dev",
    "friendsofsymfony/rest-bundle": "1.5.*@dev"
}
{% endhighlight %}

Dans le [projet associé][api-ng-admin-tutorial_entites], j'ai créé les entités 
Post, Tag et Comment, et ajouté les validations ainsi que la configuration du 
Serializer.

Il ne reste plus qu'à demander à [SyliusResourceBundle] d'exposer nos ressources 
dans une API REST. Pour cela, 2 configurations sont nécessaires, au niveau de la 
configuration de [Symfony2] et du routing :

* [`app/config/api.yml`][api-ng-admin-tutorial_server_api] (qu'il faudra penser 
à importer depuis le `config.yml` principal) :

{% highlight yaml %}
sylius_resource:
    resources:
        app.post:
            driver:    doctrine/orm
            classes:
                model: AppBundle\Entity\Post
        app.comment:
            driver:    doctrine/orm
            classes:
                model: AppBundle\Entity\Comment
        app.tag:
            driver:    doctrine/orm
            classes:
                model: AppBundle\Entity\Tag
{% endhighlight %}

La création de ressource dans [SyliusResourceBundle] engendre la création de 
services, et plus spécifiquement de controlleurs, dont le but est de gérer les 
tâches "backend" autour de l'entité Doctrine :

{% highlight bash %}
Service ID              Class name
app.controller.comment  Sylius\Bundle\ResourceBundle\Controller\ResourceController
app.controller.post     Sylius\Bundle\ResourceBundle\Controller\ResourceController
app.controller.tag      Sylius\Bundle\ResourceBundle\Controller\ResourceController
{% endhighlight %}

* [`app/config/routing.yml`][api-ng-admin-tutorial_server_routing] :

{% highlight yaml %}
app_post:
    resource: app.post
    type:     sylius.api
    prefix:   /api

app_comment:
    resource: app.comment
    type:     sylius.api
    prefix:   /api

app_tag:
    resource: app.tag
    type:     sylius.api
    prefix:   /api
{% endhighlight %}

Pour rentrer un peu plus dans les détails, le type de Route `sylius.api` permet 
de charger dynamiquement les différentes routes de notre API REST permettant de 
gérer la ressource sous la forme d'un CRUD (liste, lecture, création, édition, 
suppression). Ci-dessous la liste des routes générées par la 1ère ligne du 
routing `app_post` et associé à la ressource `app.post` (et donc associé à 
l'entité Doctrine `AppBundle\Entity\Post`) :

{% highlight bash %}
Name                Method    Scheme Host Path
app_api_post_index  GET       ANY    ANY  /api/posts/
app_api_post_show   GET       ANY    ANY  /api/posts/{id}
app_api_post_create POST      ANY    ANY  /api/posts/
app_api_post_update PUT|PATCH ANY    ANY  /api/posts/{id}
app_api_post_delete DELETE    ANY    ANY  /api/posts/{id}
{% endhighlight %}

Il aurait été possible de définir ces routes manuellement, mais également d'en 
rajouter, comme par exemple une route permettant de lister les commentaires 
associés à un post 
(cf. [routing.yml sur Github][api-ng-admin-tutorial_server_routing]) :

{% highlight yaml %}
app_api_post_comments:
    path: /api/posts/{id}/comments/
    defaults:
        _controller: app.controller.comment:indexAction
        _sylius:
            filterable: true
            criteria:
                post: $id
{% endhighlight %}

Et voilà ! Nous avons maintenant une API REST fonctionnelle et qui respecte les 
spécifications d'[HAL] pour l'exposition de ressources dans une API. [HAL] nous 
permet d'obtenir une réelle API REST puisque le niveau 3  du 
[Richardson Maturity Model] nous impose d'exposer des liens hypermedias entre 
les ressources, souvent appelé HATEOAS. Vous pouvez d'ailleurs lire 
[mes slides d'introduction à HATEOAS][slides_hateoas].

Client en AngularJS
-------------------

Toujours dans l'idée d'avoir un résultat fonctionnel et rapidement, pour la 
partie client, je vais utiliser [ng-admin] pour gérer les posts, commentaires 
et tags. Je vous recommande la lecture de 
[Add an AngularJS admin GUI to any RESTful API] pour mieux comprendre le 
fonctionnement de [ng-admin]. Comme la version de démonstration de ce dernier 
est basée sur les mêmes données, il va être intéressant de voir les 
modifications à apporter pour rendre notre administration fonctionnelle.

Grâce à [Bower], l'équivalent de [Composer] pour gérer la dépendance vers des 
assets (projets CSS ou Javascript), il est très simple d'installer [ng-admin] :

{% highlight json %}
{
  "name": "api-ng-admin-tutorial",
  "dependencies": {
    "ng-admin": "~0.4.0"
  },
  "resolutions": {
    "angular": "~1.3.8"
  }
}
{% endhighlight %}

L'initialisation de [ng-admin] dans le fichier 
[`index.html` (voir sur Github)][api-ng-admin-tutorial_client_index] est 
également simpliste.

Une fois [ng-admin] initialisé :

{% highlight javascript %}
var app = new Application('ng-admin backend demo')
    .baseApiUrl('http://localhost:8000/api/');

var post    = new Entity('posts');
var comment = new Entity('comments');
var tag     = new Entity('tags').readOnly();

app
    .addEntity(post)
    .addEntity(tag)
    .addEntity(comment);
{% endhighlight %}

Il devient possible d'implémenter une liste des Posts :

{% highlight javascript %}
post.listView()
    .title('All posts')
    .addField(new Field('id').label('ID'))
    .addField(new Field('title'))
    .addField(new ReferenceMany('tags')
        .targetEntity(tag)
        .targetField(new Field('name'))
    )
    .listActions(['show', 'edit', 'delete']);
{% endhighlight %}

Et c'est là que les premiers problèmes se posent :

* notre API expose les données en JSON selon les spécifications [HAL] donc les 
  posts se trouvent dans `_embedded` (et non à la racine comme les attends 
  [ng-admin]) ;
* comment gérer la pagination et le nombre total d'éléments ? ;
* la liste des tags attendue est une liste d'identifiants là où nous exposons 
  pour l'instant une collection d'objet, il faudra voir comment adapter cela ;
* toutes les requêtes sont faites sur l'URL `/posts`, là où notre API nécessite 
  l'ajout du "trailing slash" (notamment pour la requête POST sur `/posts/`) ;
* [SyliusResourceBundle] utilise les formulaires Symfony2 pour la création et la 
  modification d'un élément via l'API, il est donc interdit d'envoyer dans la 
  requête des champs additionnels.

Les 2 premiers problèmes se solutionnent en partie, par exemple pour les données
dans `_embedded` la solution est d'utiliser l'option `interceptor` qui permet de 
transformer le résultat d'une requête :

{% highlight javascript %}
function interceptor(data, operation, what, url, response, deferred) {
    if (operation === 'getList' && angular.isDefined(response.data._embedded)) {
        return response.data._embedded.items;
    }

    return response.data;
}
{% endhighlight %}

Pour la pagination il est également possible de personnaliser les paramètres 
envoyés à l'API. Quant au nombre total d'éléments, je n'ai pas trouvé de 
solution satisfaisante (la variable globale proposée dans 
[l'exemple de l'API de Marvel][ng-admin_example] ne fonctionne pas à 100%).

Toutes ces raisons m'ont poussé à utiliser la version master de [ng-admin] qui 
propose beaucoup plus de flexibilité, notamment dans les interactions avec l'API 
REST. En effet [ng-admin] utilise en interne la librairie [Restangular] pour 
réaliser les requêtes à l'API. Avec la version master, les fonctionnalités 
natives de [Restangular] sont beaucoup plus facilement accessibles, il est ainsi 
possible de personnaliser les requêtes, les réponses, transformer les résultats, 
etc.

Par exemple pour gérer la récupération des données dans `_embedded` et le nombre 
total de résultat retourné par l'API, il suffit de faire :

{% highlight javascript %}
RestangularProvider.addResponseInterceptor(function(data, operation, what, url, response, deferred) {
    if (operation === 'getList' && angular.isDefined(response.data._embedded)) {
        response.totalCount = response.data.total;

        return response.data._embedded.items;
    }

    return response.data;
});
{% endhighlight %}

Les mêmes fonctionnalités existent pour personnaliser la requête à l'API, et par 
exemple supprimer des champs supplémentaires ou gérer la pagination :

{% highlight javascript %}
RestangularProvider.addFullRequestInterceptor(function(element, operation, what, url, headers, params) {
    // ignore id element on update
    if (operation === 'put') {
        delete element.id;
    }

    // custom pagination params
    if (operation == "getList") {
        params.page = params._page;
        delete params._page;
        delete params._perPage;
    }

    return { params: params };
});
{% endhighlight %}

Et enfin une fonctionnalité a été ajouté dans [ng-admin] pour personnaliser 
l'URL d'une ressource, notamment pour gérer le "trailing slash" :

{% highlight javascript %}
// customize Post URL with trailing slash
post.url(function(view, entityId) {
    return 'posts/' + (angular.isDefined(entityId) ? entityId : '');
});
{% endhighlight %}

Le fichier `app.js` complet est 
[disponible sur Github][api-ng-admin-tutorial_client_app].

![ng-admin](/images/2015-01-14-exemple-implementation-api-symfony2-et-client-angularjs/ng-admin.png)

--------------------------------------------------------------------------------

Cet article avait pour but de vous présenter comment réaliser une Single Page 
Application (SPA) avec Symfony2 sur la partie serveur et AngularJS en client. 
Mais surtout comment développer un prototype rapidement grâce à 
`SyliusResourceBundle` qui automatise toutes les opérations "backend" possibles 
sur une entité Doctrine. Et sur la partie AngularJS, comment développer 
rapidement une interface de gestion aux données de l'API. Comme je pouvais m'y 
attendre c'est cette partie qui a été la plus complexe et la plus chronophage 
mais c'est évidemment lié à la jeunesse des outils.

J'espère que ça vous donnera envie de vous lancer dans la création de Single 
Page Applications, d'en apprendre plus sur l'architecture REST, ou encore sur 
le framework AngularJS.

[api-ng-admin-tutorial]: https://github.com/jeremyb/api-ng-admin-tutorial
[api-ng-admin-tutorial_entites]: https://github.com/jeremyb/api-ng-admin-tutorial/tree/master/server/src/AppBundle/Entity
[api-ng-admin-tutorial_server_api]: https://github.com/jeremyb/api-ng-admin-tutorial/blob/master/server/app/config/api.yml
[api-ng-admin-tutorial_server_routing]: https://github.com/jeremyb/api-ng-admin-tutorial/blob/master/server/app/config/routing.yml
[api-ng-admin-tutorial_client_index]: https://github.com/jeremyb/api-ng-admin-tutorial/blob/master/client/public/index.html
[api-ng-admin-tutorial_client_app]: https://github.com/jeremyb/api-ng-admin-tutorial/blob/master/client/public/app.js
[Symfony2]: http://symfony.com/
[AngularJS]: https://angularjs.org/
[Marmelab]: http://marmelab.com/blog/
[Lionframe]: http://lakion.com/lionframe
[SyliusResourceBundle]: https://github.com/Sylius/SyliusResourceBundle
[FOSRestBundle]: https://github.com/FriendsOfSymfony/FOSRestBundle
[JMSSerializerBundle]: https://github.com/schmittjoh/JMSSerializerBundle
[Hateoas]: https://github.com/willdurand/Hateoas
[NelmioApiDocBundle]: https://github.com/nelmio/NelmioApiDocBundle
[HAL]: http://stateless.co/hal_specification.html
[Lakion]: http://lakion.com/
[Rapid REST API Development with Lionframe]: http://lakion.com/blog/rapid-rest-api-development-with-lionframe
[Sylius]: http://sylius.org/
[ng-admin]: https://github.com/marmelab/ng-admin
[ng-admin_example]: https://github.com/marmelab/ng-admin/blob/master/examples/marvel.js
[Bower]: http://bower.io/
[Composer]: https://getcomposer.org/
[Restangular]: https://github.com/mgonto/restangular
[Richardson Maturity Model]: http://martinfowler.com/articles/richardsonMaturityModel.html
[slides_hateoas]: /2013/05/13/introduction-a-hateoas-aux-humantalks/
[REST APIs with Symfony2: The Right Way]: http://williamdurand.fr/2012/08/02/rest-apis-with-symfony2-the-right-way/
[Symfony2 REST API: the best way]: http://welcometothebundle.com/symfony2-rest-api-the-best-2013-way/
[Best practices pour vos APIs REST HTTP avec Symfony2]: http://afsy.fr/avent/2013/06-best-practices-pour-vos-apis-rest-http-avec-symfony2
[Add an AngularJS admin GUI to any RESTful API]: http://marmelab.com/blog/2014/09/15/easy-backend-for-your-restful-api.html
