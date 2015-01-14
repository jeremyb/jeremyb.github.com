---
layout: post
title: Halte aux hacks CSS IE
image:
  feature: slides/default.jpg
comments: false
share: false
---

**Attention :** cet article a été rédigé en 2010, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Autant pendant un temps ils n'avaient plus la côte, autant ces derniers mois je trouve qu'on lit trop d'articles sur les hacks CSS pour IE...

Que ce soit [ici][hack1] ou [là][hack2] ou encore [là][hack3], on lit les louanges des `* html` et autres `*+html`, `_` ou encore pire avec l'utilisation de `\9`... mais wtf?!

Le principal problème lié à l'utilisation d'un hack CSS, c'est que son **périmètre d'application n'est pas maîtrisé**, étant donné qu'il exploite une faille, son comportement futur ne peut pas être contrôlé...

Imaginons un instant qu'IE corrige son interprétation des CSS, même si ce n'est pas leur genre... Ou encore que gecko ou webkit se retrouve impacté par l'une de ses failles, il récoltera alors les propriétés initialement prévue pour IE, pas sûr qu'il apprécie... En plus bien souvent les hacks rendent vos CSS invalides au validateur W3C.

**Pour résumer ces hacks ne sont pas une solution pérenne.** D'autant plus lorsqu'on peut exploiter une **réelle `feature`** pour cibler différentes versions d'IE via les [commentaires conditionnels][cond1] [(article en français)][cond2]. Et si comme moi, créer une CSS avec les règles spécifiques pour une version d'IE vous rebute, il existe depuis déjà longtemps la technique du `<body>` conditionnel, un exemple :

{% highlight html %}
<!--[if lt IE 7]> <body id="ie6"><![endif]-->
<!--[if IE 7]>    <body id="ie7"><![endif]-->
<!--[if IE 8]>    <body id="ie8"><![endif]-->
<!--[if IE 9]>    <body id="ie9"><![endif]-->
<!--[if gt IE 9]> <body><![endif]-->
<!--[if !IE]><!--><body><!--<![endif]-->
{% endhighlight %}

J'utilise cette technique sur la plupart de mes sites depuis 2 ans et j'en suis ravi. Je l'ai découverte via [ce post][bodycond1] et ensuite via [un article bien plus complet de Paul Irish][bodycond2].

L'inconvénient majeur que je trouvais aux commentaires conditionnels, c'était de devoir créer différentes CSS et de devoir dupliquer certains sélecteurs pour compenser certaines défaillances d'IE. Ca peut vite devenir compliqué à maintenir dans le temps.

Avec un `<body>` conditionnel, j'édite mes conditions directement dans ma CSS :

{% highlight css %}
#test { min-height: 100px; }
#ie6 #test { height: 100px; }
{% endhighlight %}

Et comme dans l'absolu votre CSS ne devrait pas nécessiter de hacks, nous pourrions simplifier l'identifiant conditionnel à :

{% highlight html %}
<!--[if lt IE 7]> <body id="ie6"><![endif]-->
<!--[if IE 7]>    <body id="ie7"><![endif]-->
<!--[if gt IE 7]> <body><![endif]-->
<!--[if !IE]><!--><body><!--<![endif]-->
{% endhighlight %}

Ca vous laisse la possibilité de spécifier pour IE 6 et 7, ce qui est largement suffisant.

Voyons maintenant un petit exemple appliqué à Symfony :

{% highlight html %}
<!--[if lt IE 7]> <body id="ie6" class="ie lang-<?php echo $sf_user->getCulture() ?> env-<?php echo sfConfig::get('sf_environment') ?>"><![endif]-->
<!--[if IE 7]>    <body id="ie7" class="ie lang-<?php echo $sf_user->getCulture() ?> env-<?php echo sfConfig::get('sf_environment') ?>"><![endif]-->
<!--[if gt IE 7]> <body class="ie lang-<?php echo $sf_user->getCulture() ?> env-<?php echo sfConfig::get('sf_environment') ?>"><![endif]-->
<!--[if !IE]><!--><body class="lang-<?php echo $sf_user->getCulture() ?> env-<?php echo sfConfig::get('sf_environment') ?>"><!--<![endif]-->
{% endhighlight %}

Comme vous voyez, en plus des attributs liés à IE, je fais passer la culture et l'environnement de l'utilisateur. Cela permet de gérer d'éventuels background liés à la langue d'affichage. Et pour l'environnement, je m'en sers pour modifier le background du body d'un site pour son environnement de pré-production, cela permet au client de bien différencier les 2 sites.

Pour finir, c'est ok pour tout le monde ? Fini les hacks CSS, hein ? ;)

[hack1]: http://dimox.net/personal-css-hacks-for-ie6-ie7-ie8/
[hack2]: http://net.tutsplus.com/tutorials/html-css-techniques/quick-tip-how-to-target-ie6-ie7-and-ie8-uniquely-with-4-characters/
[hack3]: http://www.lafermeduweb.net/billet/-memo-selectionnez-ie6-ie7-et-ie8-en-css-en-quelques-caracteres-804.html
[cond1]: http://msdn.microsoft.com/en-us/library/ms537512(VS.85).aspx
[cond2]: http://www.blog-and-blues.org/articles/Les_syntaxes_de_commentaires_conditionnels_pour_IE_Windows
[bodycond1]: http://www.paulhammond.org/2008/10/conditional/
[bodycond2]: http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/
