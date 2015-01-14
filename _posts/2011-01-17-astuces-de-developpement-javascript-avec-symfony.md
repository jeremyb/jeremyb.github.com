---
layout: post
title: Astuces de développement javascript avec symfony
excerpt:
    Dans cet article nous allons voir quelques astuces et bonnes pratiques, non 
    pas directement de développement symfony mais de développement javascript 
    au sein d’un projet symfony.
image:
  feature: slides/default.jpg
comments: false
share: false
---

[Cet article a été intialement publié sur le blog de Lexik][lexik_blog]
{: .alert .alert-warning}

**Attention :** cet article a été rédigé en 2011, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Dans cet article nous allons voir quelques astuces et bonnes pratiques, non pas directement de développement symfony mais de développement javascript au sein d’un projet symfony.

Si l'on reprend quelques bases de bonnes pratiques de développement javascript, on constate :

* que vos javascripts doivent être non-intrusifs, autrement dit là pour améliorer l'expérience utilisateur et en aucun cas être indispensable au fonctionnement d'une page ;
* que les javascript doivent être combinés en 1 seul fichier et minifié (ceci afin de limiter le nombre de requête HTTP et car le chargement de la page est arrêté à chaque balise script, notamment à cause d'un éventuel `document.write();` ;
* que l'appel au javascript doit être en bas de page ;

**Cette liste est bien entendu non exhaustive, vous trouverez une [liste plus détaillée par ici](http://developer.yahoo.com/performance/rules.html).**

Toutes ces bonnes pratiques de développement Javascript n’ont pas toujours été facilitées dans symfony, notamment à la grande époque des helpers link_to_remote() & co. qui en ont ravi certains et fait cauchemarder d’autres. Et aujourd'hui encore bon nombre de widgets de formulaire retournent directement du code javascript (dépendant de jQuery ou autre) et qui ne fonctionneront évidemment plus dès lors que vos javascripts se trouveront en bas de page.

### 1. Où placer les javascripts dans le document

Idéalement et selon les recommandations de Yslow, en bas de page, donc juste avant la balise fermante `<body>` de votre layout.php. Ceci afin de ne pas ralentir inutilement le début du chargement de votre page, puisque chaque balise script bloque le chargement de la page (notamment pour gérer le `document.write();`).

Source : [http://developer.yahoo.com/performance/rules.html#js_bottom](http://developer.yahoo.com/performance/rules.html#js_bottom)

Si cette méthode ne vous gênera pas pour les librairies tierces telles que jQuery, qu'en est-il par contre de vos codes javascript ? Ils doivent également se trouver dans des fichiers séparés, dissociés de votre document HTML. Néanmoins comme je vois souvent le besoin pour les développeurs d'avoir le code javascript au sein du template symfony, voici une technique pour qu'il soit tout de même placé en fin de page : via un slot.

Un petit exemple de code :

{% highlight php startinline %}
// indexSuccess.php :
<?php slot('javascript') ?>
<script type="text/javascript">
  console.log('javascript @ bottom');
</script>
<?php end_slot() ?>

// layout.php :
<?php include_javascripts() ?>
<?php include_slot('javascript') ?>
{% endhighlight %}

Vous pourrez ainsi éditer votre code javascript depuis votre template PHP, bénéficier par exemple de valeurs dynamiques de PHP et pour autant que le code soit bien inclus en bas de page. Toutefois je vous recommande d'écrire du javascript là où il doit se trouver, à savoir dans un fichier JS...

De plus l'inconvénient majeur du slot est qu'il ne peut contenir qu'une valeur, il est écrasé à chaque utilisation. La technique fonctionne mais est très limitée. Pour ces besoins nous avons écrit chez Lexik un petit plugin "lxJavascript", très similaire à l'utilisation d'un slot mais optimisé pour l'inclusion de javascripts. Il gère donc le multiple ajout, supprime les éventuelles multiples balises script pour en conserver qu'une seule, etc. Vous en saurez plus demain, le plugin sort en OpenSource sur le [Github de Lexik](https://github.com/lexik).

### 2. Compression

La compression des javascripts (c'est valable aussi pour les CSS) est une des tâches d'optimisations les plus importantes et également une des plus simples, du moins via les plugins symfony. Cette technique consiste à compresser tous vos fichiers javascript en 1 seul et surtout d'y appliquer un numéro de version (un timestamp le plus souvent) afin de prévenir des problèmes de cache dans vos mises à jour.

Les principaux plugins :

* [sfCombinePlugin](http://www.symfony-project.org/plugins/sfCombinePlugin)
* [npAssetsOptimizerPlugin](http://www.symfony-project.org/plugins/npAssetsOptimizerPlugin)
* [swCombinePlugin](http://www.symfony-project.org/plugins/swCombinePlugin)

Chez Lexik, nous utilisons [npAssetsOptimizerPlugin](http://www.symfony-project.org/plugins/npAssetsOptimizerPlugin), un plugin de [Nicolas Perriault](http://www.akei.com/), extrêmement simple à installer et paramétrer. Sur votre environnement de production, vous obtiendrez ainsi un fichier javascript compressé `/js/optimized.js?1294759429` qui contient un timestamp permettant à chaque modifications des fichiers d'être prises en compte sans problème de cache.

Nous n'appliquons pas la compression pour les librairies externes telles que jQuery que nous déléguons aux [serveurs CDN de Google](http://code.google.com/apis/libraries/devguide.html), cela apporte ces avantages notables :

* l'avantage du CDN, à savoir de proposer des données statiques via un réseau de multiples serveurs dans de multiples points géographiques, afin de permettre un accès très court ;
* les navigateurs sont limités sur le nombre de connexions HTTP simultanées sur un même domaine, le téléchargement d'un javascript sur les serveurs de Google se fera en parallèle ;
* les librairies du CDN ont les bonnes en-têtes de cache, par exemple la version 1.4.4 de jQuery restera en cache pendant 1 an sur le client, cela signifie également qu'un internaute peut bénéficier du cache téléchargé depuis un autre site, pas forcément sur le votre.

### 3. Accéder à certaines données dynamiques depuis javascript

Il peut parfois être très utile depuis javascript d'accéder à certaines données dynamiques telles que la culture de l'utilisateur, du routing pour des appels Ajax ou encore de l'i18n. Il suffit de s'appuyer sur un simple fichier de configuration via un tableau de données JSON généré depuis une action symfony. J'ai écrit sur mon blog personnel un article détaillé sur le sujet [Configurations Javascript dynamiques en Symfony](http://blog.jeremybarthe.com/post/1465024153/configurations-javascript-dynamiques-en-symfony).

### 4. Javascript depuis les widget

Maintenant que vos inclusions de javascripts se trouvent en bas de page, jQuery par exemple, que faire de nos chers widgets jQuery Autocompleter `sfWidgetFormJQueryAutocompleter` et autre Datepicker `sfWidgetFormJQueryDate` qui retournent des champs de formulaire et le javascript d’initialisation du composant ? Eh bien, ne plus les utiliser... Simplement car ils seront inclus avant jQuery et vous aurez donc droit à l’erreur "jQuery is not defined". Sans être aussi extrême, vous pouvez charger jQuery en haut de page (via les CDN de Google) et votre script compressé en bas de page, les widgets de formulaire seront alors à nouveau fonctionnels.

Cela fait déjà quelques temps que chez Lexik nous avons fait le choix d'enlever tous ces widgets pour les ré-écrire et les adapter à nos besoins. Les javascripts des widgets passent par notre plugin lxJavascript ce qui permet de les inclure là où on le souhaite. Egalement, le javascript retourné par ces widgets correspond à une utilisation basique du composant, dans un cas concrêt il est souvent nécessaire d'en ré-écrire une bonne part. Il peut être pratique par contre que le widget retourne seulement la sémantique HTML adaptée, par exemple dans le cas d'un Autocomplete un champ hidden pour stocker la valeur et un champ texte pour l'autocomplete, aussi nos widgets ont une option pour retourner ou non le code javascript.

### 5. Optimisation frontend

Presque aussi important que la compression, la configuration d'apache pour mettre en cache certains de vos fichiers statiques. Typiquement, maintenant que vos fichiers javascripts et CSS sont compressés en 1 seul et possèdent un timestamp unique par version, il serait dommage de les recharger à chaque chargement de page... Vous devez donc configurer le module Expires d'apache via le fichier de config du vhost ou via le .htaccess, en voici un exemple :

{% highlight apache %}
<IfModule mod_expires.c>
  ExpiresActive on
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType text/javascript "access plus 1 year"
</IfModule>
{% endhighlight %}

Vos fichiers javascript et CSS seront ainsi en cache pendant 1 an, attention du coup à ne pas avoir de fichier sans numéro de version, car ils resteraient en cache et vos internautes ne bénéficieraient pas de vos mises à jour...

Dernière chose, si ce n'est pas encore fait, installez et testez [Yslow](http://developer.yahoo.com/yslow/) pour trouver des pistes d'optimisations de performance de vos sites.

*[CDN]: Content Delivery Network

[lexik_blog]: http://devblog.lexik.fr/symfony/astuces-de-developpement-javascript-avec-symfony-1382
