---
layout: post
title: Configurations Javascript dynamiques en Symfony
image:
  feature: slides/default.jpg
comments: false
share: false
---

**Attention :** cet article a été rédigé en 2010, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Dans cet article nous allons voir comment accéder à des données dynamiques provenant de symfony, en Javascript. Pour quelle raison ? Car il est parfois nécessaire depuis JS d'avoir à accéder à des données telles que : de l'i18n, des URLs générés à partir du routing, la culture de l'utilisateur, etc.

I18n pour le titre d'une modalbox par exemple, dont le site serait internationalisé. URLs pour des appels Ajax, où il est déconseillé de recopier l'URL en dur dans le fichier JS... Et la culture pour bien configurer certains JS qui proposent des fichiers de traductions.

Pour cela, je vous propose de préparer un **tableau JSON**, en voici un exemple :

{% highlight js %}
var globalConfigs = {
  env                     : '<?php echo sfConfig::get('sf_environment') ?>',
  userCulture             : '<?php echo $sf_user->getCulture() ?>',
  urls: {
    ajaxAutocomplete      : '<?php echo url_for('@homepage') ?>',
    ajaxModalBox          : '<?php echo url_for('@homepage') ?>'
  },
  i18n: {
    example               : "<?php echo esc_specialchars(__('example')) ?>",
    exampleModalboxTitle  : "<?php echo esc_specialchars(__('example_modalbox_title')) ?>"
  }
};
{% endhighlight %}

Nous pouvons ainsi accéder à l'environnement, la culture de l'utilisateur, des URLs et de l'I18n.
**Maintenant, où placer ce JS ?** 2 solutions s'offrent à nous :

* directement dans votre layout.php (via un partial ou component) ;
* dans un module > action avec un routing spécifique.

Personnellement je trouve plus propre la deuxième méthode même si elle est plus complexe à mettre en place ;)

C'est parti, nous créons donc un simpliste module nommé `js`, associé à son action tout aussi simpliste `configs` dont nous imposons le `sf_format`  à `js`, soit un template nommé `configsSuccess.js.php`.

Le routing correspondant :

{% highlight yaml %}
javascript_configs:
  url:    /js/configs.:sf_format
  param:  { module: js, action: configs, sf_format: js }
{% endhighlight %}

Il ne reste plus qu'à inclure ce JS dans toutes nos pages. Pour cela nous pouvons utiliser le système d'événement de Symfony. Etant donné que j'ai besoin à la fois de la `sfWebResponse` et de `sfRouting` je vais passer par l'event `context.load_factories`. Même si j'aurai préféré proposer un event plus approprié, car on a tendance à `overused` cet event pour tout et n'importe quoi...

Vous pouvez placer ce code dans votre `ProjectConfiguration` ou plutôt dans la configuration de votre application :

{% highlight php startinline %}
public function configure()
{
  $this->dispatcher->connect('context.load_factories', array($this, 'listenToContextLoadFactoriesEvent'));
}

public function listenToContextLoadFactoriesEvent(sfEvent $event)
{
  $event->getSubject()->getResponse()->addJavascript($event->getSubject()->getRouting()->generate('javascript_configs'));
}
{% endhighlight %}

La configuration JS est dorénavant accessible, voici quelques exemples d'utilisation :

{% highlight js %}
// env condition:
if (globalConfigs.env == 'dev') {}

// jQuery DOM manipulation:
$('#example').html(globalConfigs.i18n.example);

// jQuery ajax call:
$.get(globalConfigs.urls.ajaxAutocomplete, function(data) {});

// enjoy!
{% endhighlight %}

En allant plus loin, vous pouvez par exemple piloter les éditeurs wysiwygs de vos applications et cloisoner leurs configurations. Dans l'exemple ci-dessous, les boutons de l'éditeur sont configurés via le `app.yml`, vous pouvez ainsi offrir une configuration différente pour vos applications.

{% highlight js %}
var globalConfigs = {
  // ...

  wysiwyg: {
    script_url: '/js/tiny_mce/tiny_mce.js',
    theme: "advanced",
    element_format : "xhtml",
    cleanup : true,
    theme_advanced_buttons1: "<?php echo sfConfig::get('app_tinymce_theme_advanced_buttons1') ?>",
    theme_advanced_buttons2: "<?php echo sfConfig::get('app_tinymce_theme_advanced_buttons2') ?>",
    theme_advanced_buttons3: "<?php echo sfConfig::get('app_tinymce_theme_advanced_buttons3') ?>",
    theme_advanced_buttons4: "<?php echo sfConfig::get('app_tinymce_theme_advanced_buttons4') ?>",
    theme_advanced_toolbar_location: "top",
    theme_advanced_toolbar_align: "left",
    width: "100%",
    paste_auto_cleanup_on_paste : true
  }
};
{% endhighlight %}

De plus cela permet de centraliser des configurations pour éviter de se répéter (<abbr title="Don't repeat yourself">DRY</abbr>) :

{% highlight js %}
// TinyMCE via jQuery plugin:
$('#wysiwyg').tinymce(globalConfigs.wysiwyg);
{% endhighlight %}

Voilà, qu'en pensez vous ? Utilisez vous des systèmes similaires ? Ou pas ? ;)
