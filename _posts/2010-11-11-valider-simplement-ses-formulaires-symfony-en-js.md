---
layout: post
title: Valider simplement ses formulaires Symfony en JS
image:
  feature: slides/default.jpg
comments: false
share: false
---

**Attention :** cet article a été rédigé en 2010, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Dans cet article nous allons voir comment facilement valider un formulaire Symfony via les `sfEvent`.

Il existe de nombreuses méthodes pour valider ses formulaires en Javascript, mais celle que j'apprécie consiste à passer des données à la sémantique HTML des éléments de formulaire pour indiquer au javascript qu'elles sont les conditions à valider. En d'autres termes cela revient par exemple à renseigner un attribut `class` avec des valeurs telles que `required` ou encore `email`, etc. ou encore via un JSON toujours placé dans l'attribut class, récupéré ensuite grâce à [`jquery.metadata`][jquery.metadata].

[VanadiumJS][jquery.validation2], une librairie jQuery, est basée sur ce principe, elle ajoute une couche de validation javascript via des classes CSS de type `:required`, etc. Malheureusement elle souffre de quelques défauts, notamment l'I18N.
Le [jQuery plugin validation][jquery.validation1] permet également de valider sous cette forme, il permet aussi une écriture des règles en javascript, hors de la sémantique HTML.

Le code ci-dessous a été testé avec ces 2 librairies Javascript. J'ai choisi de vous présenter le code correspondant à la librairie [jQuery plugin validation][jquery.validation1] car je la considère plus pérenne et elle gère l'I18N.

Prenons un formulaire d'exemple, avec différents widgets mais surtout un panel variés de validators :

{% highlight php startinline %}
class ExampleDataForm extends BaseForm
{
  public function configure()
  {
    $this->setWidgets(array(
      'name'        => new sfWidgetFormInputText(),
      'email'       => new sfWidgetFormInputText(),
      'number'      => new sfWidgetFormInputText(),
      'price'       => new sfWidgetFormInputText(),
      'description' => new sfWidgetFormTextarea(),
      'url'         => new sfWidgetFormInputText(),
      'cgu'         => new sfWidgetFormInputCheckbox(),
    ));

    $this->setValidators(array(
      'name'        => new sfValidatorString(array('min_length' => 5, 'max_length' => 255)),
      'email'       => new sfValidatorEmail(array('required' => true)),
      'number'      => new sfValidatorInteger(array('required' => false)),
      'price'       => new sfValidatorNumber(array('required' => true)),
      'description' => new sfValidatorString(array('max_length' => 4000)),
      'url'         => new sfValidatorUrl(array('required' => true)),
      'cgu'         => new sfValidatorBoolean(array('required' => true)),
    ));

    $this->widgetSchema->setNameFormat('example_data[%s]');
  }
}
{% endhighlight %}

L'événement [`form.post_configure`][form.post_configure] est notifié lorsque le formulaire est configuré, autrement dit après que les widgets et les validators soient initialisés. A ce moment là, il sera très simple de modifier les attributs des widgets pour leur ajouter quelques classes en fonction du validator et de ses options.

Il faut donc se connecter à l'événement, je vous laisse libre d'implémenter ceci dans votre `ProjectConfiguration` ou encore dans la configuration d'une de vos applications :

{% highlight php startinline %}
$this->dispatcher->connect('form.post_configure', array($this, 'listenToFormPostConfigureEvent'));
{% endhighlight %}

Ci-dessous un exemple d'implémentation de la méthode `listenToFormPostConfigureEvent` pour gérer quelques validators :

{% highlight php startinline %}
public function listenToFormPostConfigureEvent(sfEvent $event)
{
  $validatorSchema = $event->getSubject()->getValidatorSchema();

  // iterates over the widgets:
  foreach ($event->getSubject() as $formField)
  {
    $widget = $formField->getWidget();

    // retrieve validator associated to widget:
    $validator = $validatorSchema[$formField->getName()];

    // required
    if ($validator->getOption('required'))
    {
      $this->mergeClass($widget, 'required');
    }

    // min length
    if ($validator->getOption('min_length'))
    {
      $widget->setAttribute('minlength', $validator->getOption('min_length'));
    }

    // max length
    if ($validator->getOption('max_length'))
    {
      $widget->setAttribute('maxlength', $validator->getOption('max_length'));
    }

    // number
    if ($validator instanceof sfValidatorInteger || $validator instanceof sfValidatorNumber)
    {
      $this->mergeClass($widget, 'number');
    }

    // email
    if ($validator instanceof sfValidatorEmail)
    {
      $this->mergeClass($widget, 'email');
    }

    // url
    if ($validator instanceof sfValidatorUrl)
    {
      $this->mergeClass($widget, 'url');
    }
  }
}

/**
 * Merge CSS classes to the given widget.
 *
 * @param $widget
 * @param $className
 */
public function mergeClass($widget, $className)
{
  return $widget->setAttribute('class', (null !== $widget->getAttribute('class')) ? sprintf('%s %s', $widget->getAttribute('class'), $className) : $className);
}
{% endhighlight %}

Pour résumer, la méthode `listenToFormPostConfigureEvent` va **itérer sur les différents widgets du formulaire**, et pour chacun d'eux va récupérer son validator. Elle va alors modifier les attributs du widget (le plus souvent l'attribut `class`) pour y indiquer quel type de validation devra opérer la partie Javascript.

Libre à vous d'implémenter d'autres validators. Il serait même possible de passer par un JSON (technique metadata) pour ainsi gérer plus de cas, plus d'options liés à [la documentation de jQuery plugin validation][jquery.validation_documentation].

N'oubliez pas de charger les différents javascripts, à savoir jQuery et ceux du plugin de validation (vous pouvez en option ajouter un JS localisé proposé par le plugin ou encore un fichier contenant vos propres traductions pour les messages d'erreurs, c'est très pratique) :

{% highlight yaml %}
default:
  javascripts:
    - //ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js
    - jquery-validation/jquery.validate.js
    - jquery-validation/localization/messages_fr.js # optional
{% endhighlight %}

Et maintenant dans votre vue (considérons que vous avez correctement affiché votre formulaire) il ne reste plus qu'à initialiser le javascript du plugin de validation, via :

{% highlight html %}
<script type="text/javascript" charset="utf-8">
  $(function(){
    $("form").validate();
  });
</script>
{% endhighlight %}

Voici le résultat que j'obtiens :

![Validation JS facile de formulaire Symfony via les events](/images/2010-11-11-valider-simplement-ses-formulaires-symfony-en-js/validationjs.png)

Si vous souhaitez adapter ce code à [VanadiumJS][jquery.validation2], ce ne sera pas très compliqué, il suffira de faire quelques adaptations au niveau des classes, par exemple : `required` devient `:required`, `min_length` et `max_length` ne sont plus des attributs du widget mais des classes, etc. Il suffit de se référer à la [documentation de VanadiumJS][vanadiumjs_documentation].

#### Conclusion :

Pour conclure, on constate qu'il a été très simple d'étendre les fonctionnalités de `sfForm` mais surtout de généraliser ce comportement à tous les formulaires. Evidemment n'utilisez pas forcément ce code là en production, car il va s'exécuter pour tous vos formulaires, ce qui n'est pas forcément souhaitable. Il serait toutefois assez simple de définir via un `app.yml` une collection de noms de formulaires pour lesquels on souhaite appliquer des validations côté client.

Sachez qu'il existe également un plugin Symfony de validation javascript : [sfJqueryFormValidationPlugin][sfJqueryFormValidationPlugin] (qui au passage se base sur le même plugin jQuery que cet article). Par contre ce dernier ne se base pas sur les events Symfony, il fonctionne via un filter qui ajoute des fichiers javascripts dynamiques qui précise les règles de validation des formulaires.

[jquery.validation1]: http://bassistance.de/jquery-plugins/jquery-plugin-validation/
[jquery.validation2]: http://www.vanadiumjs.com/
[vanadiumjs_documentation]: http://www.vanadiumjs.com/
[jquery.validation_documentation]: http://docs.jquery.com/Plugins/Validation
[jquery.metadata]: http://plugins.jquery.com/project/metadata
[form.post_configure]: http://www.symfony-project.org/reference/1_4/en/15-Events#chapter_15_sub_form_post_configure
[sfJqueryFormValidationPlugin]: http://www.symfony-project.org/plugins/sfJqueryFormValidationPlugin
