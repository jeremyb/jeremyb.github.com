---
layout: post
title: Convertir une Exception en Response dans Symfony2
tags: [Symfony2]
image:
  feature: slides/default.jpg
comments: true
share: true
---

La méthode traditionnelle pour retourner une page avec le framework Symfony2 est 
de retourner un objet `Response`. Toutefois on peut remarquer que les pages 
d'erreurs (notamment les 404) ne suivent pas ce principe. En effet pour 
déclencher un code d'erreur 404 et afficher la page correspondante, il suffit 
de lever une Exception comme ceci :

{% highlight php startinline %}
throw new NotFoundHttpException();
{% endhighlight %}

Il peut parfois s'avérer intéressant de reproduire ce système pour des 
Exceptions métiers dans son projet. Supposons par exemple que nous devons gérer 
des verrous sur l'édition d'un objet. C'est une demande fréquente sur des 
applications web (intranet par exemple) où lorsqu'un utilisateur se trouve sur 
le formulaire d'édition d'un objet, les autres utilisateurs, qui tentent 
d'accéder à ce même formulaire, doivent être bloqués et notifiés de l'édition 
en cours d'un utilisateur. Chez Lexik, nous avons récemment eu cette demande et 
nous l'avons traité via une `Exception`.

L'article suivant ne donnera pas une implémentation complète du bundle de 
gestion des verrous d'édition, que nous appellerons `LockBundle` tout au long de 
l'article, mais servira d'exemple pour montrer comment transformer une 
`Exception` dans Symfony2 en `Response`. Si vous êtes intéressés pour avoir une 
version Open Source du `LockBundle`, il suffit de le demander ;-)

Supposons que nous avons un service `lock_manager` capable d'ajouter et 
supprimer un verrou, ainsi que savoir si un objet est verrouillé ou non. La 
seule contrainte est que l'objet passé en paramètre doit implémenter l'interface 
`LockableInterface`.

{% highlight php %}
<?php

namespace Acme\LockBundle\Model;

use Acme\LockBundle\Exception\LockedException;

class LockManager
{
    public function lock(LockableInterface $object)
    {
        // ...
    }

    public function unlock(LockableInterface $object)
    {
        // ...
    }

    public function verify(LockableInterface $object)
    {
        if (/* some condition */) {
            throw new LockedException();
        }
    }
}
{% endhighlight %}

Dans un contexte classique, depuis un Controller Symfony2, il faudrait retourner 
une `Response` avec une vue attachée, comme ceci :

{% highlight php %}
<?php

namespace Acme\DemoBundle\Controller;

use Acme\LockBundle\Exception\LockedException;

class ArticleController extends Controller
{
    public function editAction(Request $request, Article $article)
    {
        try {
            $this->get('lock_manager')->verify($article)
        } catch (LockedException $e) {
            return $this->render('::locked.html.twig');
        }
        
        // ...
    }
}
{% endhighlight %}

Si cette action doit être réalisée à plusieurs reprises, depuis plusieurs 
Controller, ce code peut s'avérer rébarbatif et verbeux. Le plus simple serait 
d'appeler seulement la méthode `verify` de notre service et lever l'Exception 
si un verrou est présent. Par contre, dans ce contexte, c'est une page 500 qui 
s'affichera ce qui n'est pas acceptable.

Heureusement, Symfony2 et son composant `HttpKernel` nous offre beaucoup de 
souplesse et dispose d'un évènement lorsqu'une Exception est levée et non 
catchée. Il s'agit de l'évènement `kernel.exception` comme sa documentation 
l'indique `this event allows you to create a response for a thrown exception`.
Il nous suffit de créer un listener :

{% highlight php %}
<?php

namespace Acme\LockBundle\Listener;

use Symfony\Bundle\TwigBundle\TwigEngine;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Event\GetResponseForExceptionEvent;
use Acme\LockBundle\Exception\LockedException;

class LockedExceptionListener
{
    private $templating;

    public function __construct(TwigEngine $templating)
    {
        $this->templating = $templating;
    }

    public function onKernelException(GetResponseForExceptionEvent $event)
    {
        if ( ! $event->getException() instanceof LockedException) {
            return;
        }

        $response = $this->templating->renderResponse('::locked.html.twig');
        $event->setResponse($response);
    }
}
{% endhighlight %}

Il ne reste plus qu'à la définir en tant que service et l'associer à l'évènement
`kernel.exception` :

{% highlight yaml %}
services:
    listener.locked_exception:
        class: Acme\LockBundle\Listener\LockedExceptionListener
        arguments: [@templating]
        tags:
            - { name: kernel.event_listener, event: kernel.exception, method: onKernelException }
{% endhighlight %}

Avec ce listener, nous pouvons maintenant simplifier le code de notre 
Controller comme ceci :

{% highlight php startinline %}
public function editAction(Request $request, Article $article)
{
    $this->get('lock_manager')->verify($article);

    // ...
}
{% endhighlight %}

C'est très confortable car ce code peut être appelé depuis Controller ou même 
depuis classe modèle/service et le rendu pour l'utilisateur sera le même.

Nous pouvons même enrichir la `Response` du listener pour retourner un status 
code HTTP d'erreur (comme ce qui est fait pour les 404 par exemple). Pour cela 
il suffit d'éditer la classe `LockedExceptionListener` comme ceci :

{% highlight php startinline %}
$response = $this->templating->renderResponse(
    '::locked.html.twig',
    array(),
    // le 3ème paramètre permet de fournir un objet Response :
    new Response(null, 423)
);
{% endhighlight %}
