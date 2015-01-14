---
layout: page
title: sfForm de Symfony en tant que framework
image:
  feature: slides/default.jpg
---

**Attention :** cet article a été rédigé en 2009, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Le framework Symfony a l'énorme avantage d'être construit sous la forme d'un ensemble de composants autonomes et cohérents. En d'autres termes il s'agit d'un framework composé de minis frameworks. Chacun de ces composants est utilisable en soi de façon cohérente.

L'objectif de cet article est de vous présenter sfForm en tant que framework sans Symfony, avec ses compagnons de route, à savoir ses widgets et ses validateurs. Evidemment mon but n'est pas de vous conseiller d'utiliser cette technique car vous ne bénéficierez pas de toutes les fonctionnalités liés à Symfony, notamment le lien entre le formulaire et l'ORM. De plus dans cet exemple il y a des appels aux variables supersglobales ce qui n'est pas recommandé, etc. Mais ceci peut être utile si vous travaillez sur un code existant sur lequel vous ne pouvez envisager une refonte totale et sur lequel vous avez une problématique autour des formulaires, sfForm peut y répondre en tant que tel.

Dans un premier temps il nous faut inclure les librairies. J'ai choisi, pour cet exemple relativement simple d'utiliser le système d'autoloading fourni dans Symfony. Cette intégration dépend de votre projet, si vous utilisez déjà l'autoloading, il vous faudra l'adapter à l'inclusion des librairies de sfForm...

    require_once dirname(__FILE__) . '/lib/symfony/autoload/sfCoreAutoload.class.php';
    sfCoreAutoload::register();

La classe de définition du formulaire sfForm est identique à celle que l'on pourrait trouver dans un projet Symfony, je laisse donc de côté cette étape, vous pouvez [vous référer à la documentation](http://www.symfony-project.org/book/forms/1_2/en/). Vous trouverez cependant la classe dans l'archive attachée à cet article et dans une fenêtre modale ci-dessous :

    <?php
    class ContactForm extends sfForm
    {
      protected static $subjects = array('Subject A', 'Subject B', 'Subject C');

      public function configure()
      {
        $this->setWidgets(array(
          'name'    => new sfWidgetFormInput(),
          'email'   => new sfWidgetFormInput(),
          'subject' => new sfWidgetFormSelect(array('choices' => self::$subjects)),
          'message' => new sfWidgetFormTextarea(),
        ));

        $this->setValidators(array(
          'name'    => new sfValidatorString(array('required' => false)),
          'email'   => new sfValidatorEmail(array(), array('invalid' => 'Email address is invalid.')),
          'subject' => new sfValidatorChoice(array('choices' => array_keys(self::$subjects))),
          'message' => new sfValidatorString(array('min_length' => 4), array(
            'required'   => 'The message field is required',
            'min_length' => 'The message "%value%" is too short. It must be of %min_length% characters at least.',
          )),
        ));

        $this->widgetSchema->setNameFormat('contact[%s]');

        $this->widgetSchema->setFormFormatterName('list');
      }
    }

Quant à la partie de notre code qui va gérer le traitement de la requête entrante, le formulaire et la réponse (notre contrôleur en résumé), nous allons étudier le code habituel d'une action Symfony pour en déceler les éléments indisponibles dans notre application from scratch.

Code habituel de l'action du formulaire avec Symfony :

    public function executeIndex(sfWebRequest $request)
    {
      $this->form = new ContactForm();

      if ($request->isMethod('post'))
      {
        $this->form->bind($request->getParameter('poll', array()));

        if ($this->form->isValid())
        {
          // traitement base de données ou email

          // redirection vers une page de confirmation
          $this->redirect('contact/confirmation');
        }
      }
    }

Ci-dessous une liste de contraintes pour adapter cela sans Symfony :

* _$this->form_ nous permet de passer un objet à la vue, nous n'en avons plus besoin une simple variable _$form_ suffira (attention néanmoins à la visibilité de cette variable et qu'elle ne soit pas écrasée ailleurs dans votre code...) ;
* nous n'avons plus l'objet _$request_, lui qui nous permet de récupérer des informations venant de la requête utilisateur, tels que des paramètres GET ou POST, nous allons le remplacer par un accès direct à la variable superglobale _$_POST_ ;
* enfin _$this->redirect()_ pourra être remplacé par un _header("Location")_.

Ce qui nous amène à ce code :

    $form = new ContactForm();

    if (!empty($_POST))
    {
      $form->bind((is_array($_POST['contact'])) ? $_POST['contact'] : array());
      if ($form->isValid())
      {
        // traitement base de données ou email
        $values = $form->getValues();

        // redirection vers une page de confirmation
        header("Location: confirmation.php");
        exit;
      }
    }

Forcément c'est moins propre qu'avec Symfony... ;-)

Voici la structure de notre micro-projet :

*   lib/
    *   symfony/
        *   autoload/
        *   form/
        *   validator
        *   widget
        *   ContactForm.class.php
*   index.php

C'est terminé, notre code est fonctionnel, nous avons apprivoisé sfForm pour l'utiliser dans notre projet avec nos autres librairies. Vous trouverez ci-dessous le code complet du fichier _index.php_ :

    <?php
    /**
     * Symfony autoloading
     */
    require_once dirname(__FILE__) . '/lib/symfony/autoload/sfCoreAutoload.class.php';
    sfCoreAutoload::register();

    /**
     * Contact form example
     */
    require_once dirname(__FILE__) . '/lib/ContactForm.class.php';
    $form = new ContactForm();

    if (!empty($_POST))
    {
      $form->bind((is_array($_POST['contact'])) ? $_POST['contact'] : array());
      if ($form->isValid())
      {
        // traitement base de données ou email
        $values = $form->getValues();

        // redirection vers une page de confirmation
        header("Location: confirmation.php");
        exit;
      }
    }

    ?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>Contact form example with sfForm</title>
      </head>
      <body>
        <form action="index.php" method="post">
        <ul>
          <?php echo $form ?>
          <li><input type="submit" value="Submit" /></li>
        </ul>
        </form>
      </body>
    </html>

Pour aller plus loin et notamment pour comprendre la modularité des composants de Symfony, je vous conseille la lecture des slides de la conférence de Fabien Potencier, lors du forum PHP 2008, intitulée "[Découpler votre code pour assurer la réutilisabilité et la maintenabilité](http://fabien.potencier.org/talk/20/decouple-your-code-for-reusability-php-forum-2008)".
