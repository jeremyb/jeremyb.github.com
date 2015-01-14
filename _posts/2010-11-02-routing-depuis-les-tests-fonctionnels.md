---
layout: post
title: Du routing depuis les tests fonctionnels
image:
  feature: slides/default.jpg
comments: false
share: false
---

**Attention :** cet article a été rédigé en 2010, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Lorsque l'on développe des tests fonctionnels en symfony avec lime, on se rend compte du lien fort qu'il y à la fois entre la sémantique HTML et les tests mais également entre les URLs et les tests. Voici un exemple :

{% highlight php startinline %}
$browser->get('/category/index');
{% endhighlight %}

Utiliser des URL comme celle-ci dans les tests fonctionnels peut être handicapant si en fin de projet votre client demande une optimisation des URLs. Vous allez probablement retravailler votre routing en conséquence. Et dès lors une bonne part de vos tests fonctionnels risquent de ne plus fonctionner. Alors, pourquoi ne pas tout simplement utiliser des routes dans vos tests fonctionnels ? D'autant plus que le routing.yml référence l'intégralité des URLs de votre application, ce serait dommage de s'en priver !

Voici 2 méthodes pour utiliser le routing symfony depuis vos tests fonctionnels :

{% highlight php startinline %}
$app = 'frontend';
include(dirname(__FILE__).'/../../bootstrap/functional.php');

$browser = new sfTestFunctional(new sfBrowser());

$context = sfContext::getInstance();

$browser->
  info(sprintf('Context way: %s', $context->getRouting()->generate('example_route')));

$configuration->loadHelpers(array('Url'));

$browser->
  info(sprintf('Helper way: %s', url_for('@example_route')));
{% endhighlight %}

Dans ces 2 techniques, inutile de modifier quoi que ce soit dans votre bootstrap `functional.php`. A part si le `sfContext::getInstance()` vous pique les yeux, ce que je comprendrai allègrement, vous pouvez modifier `functional.php`, en remplaçant :

{% highlight php startinline %}
// replace:
sfContext::createInstance($configuration);
// by:
$context = sfContext::createInstance($configuration);
{% endhighlight %}

Vous pouvez maintenant utiliser `$context`.

Personnellement, j'utilise la méthode via le helper URL ;-)
