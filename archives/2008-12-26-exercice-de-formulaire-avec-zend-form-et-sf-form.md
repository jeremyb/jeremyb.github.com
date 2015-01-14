---
layout: page
title: Exercice de formulaire avec Zend_Form et sfForm
image:
  feature: slides/default.jpg
---

**Attention :** cet article a été rédigé en 2008, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Bien, on connait maintenant [quelques techniques d'intégration pour nous aider dans nos CSS sous IE 6][1], voici un article plus technique !

J'avais envie de vous parler de [Symfony][2] et [Zend Framework][3], il s'agit de 2 framework PHP apportant un développement pérenne, rapide et agile. Loin de moi l'idée de vous donner la définition d'un framework, ni même son utilité, bien des ressources existent sur Internet, [à commencer par cet article][4]. Je vais plutôt m'attacher à vous présenter leur gestion des formulaires. L'exercice sera donc de créer un formulaire type avec ces 2 frameworks, ce qui nous permettra d'une part de comparer le code, et d'autre part de mesurer le temps qui aura été nécessaire.

Le but étant d'obtenir un **formulaire généré** donc facilement maintenable, un **formulaire évidemment validé** (à la fois pour contrôler les données saisies et pour nous éviter d'éventuelles failles), et enfin un **formulaire internationalisé**.

Petite pub au passage, pour mesurer mon temps j'ai utilisé la très sympathique application [Kronos][5] édité par une [petite boite Montpellièraine][6].

### Descriptif du formulaire

Dans le cadre de cet exercice, j'ai défini d'une part les champs du formulaire, et d'autre part certaines contraintes techniques afin de compliquer légèrement la tâche.  
Attaquons le vif du sujet, voici **les champs de notre formulaire** :

| ----- |
| Type de demande |  sélecteur / obligatoire |
| Nom |  champ texte / obligatoire |
| Prénom |  champ texte / obligatoire |
| Email |  champ texte / obligatoire / validation de l'email |
| Message |  zone de texte / obligatoire |
| Date de naissance |  sélecteurs / validation de date |
| Inscription à la newsletter |  case à cocher |

Les **contraintes techniques** (essentiellement sur la forme) sont les suivantes :
* le formulaire ne sera pas généré en tableau, mais en liste à puces ;
* les "labels" des champs obligatoires seront suivi d'une étoile rouge ;
* les champs "prénom" et "nom" doivent être côte à côte (flottants donc) ;
* le champ "date de naissance" doit apparaître sous la forme de sélecteurs (on pourra éventuellement y ajouter un datepicker en javascript) ;
* la case à cocher de l'inscription à la newsletter doit apparaître avant le "label" ;
* la "vue" devra être la plus courte possible pour être flexible autant sur le fond que sur la forme.

Et enfin, voici un screenshot du rendu souhaité :

![Formulaire][7]

### Comparaison de codes

Dans Symfony un formulaire est généré via la classe "sfForm", chaque éléments du formulaire se nommera un "widget", ils proviennent naturellement de la classe "sfWidget".

Dans Zend Framework un formulaire est généré via la classe "Zend_Form", chaque éléments du formulaire se nommera "element", ils proviennent de la classe "Zend_Form_Element".

Passons à la description du code et surtout à la comparaison des 2 écritures :

#### Formulaire de contact avec Zend_Form

    /**
     * Formulaire de contact avec Zend_Form du Zend Framework
     */
    public function init()
    {
        $this->setName('contact-form')
             ->setAttrib('id', 'contact-form');

        $this->addElement('select', 'subject', array(
            'label' => 'subject',
            'required' => true,
            'multiOptions' => array('' => '', 1 => 'commercial', 2 => 'technical')
        ));

        $this->addElement('text', 'firstname', array(
            'label' => 'firstname',
            'required' => true,
            'validators' => array('alnum')
        ));

        $this->addElement('text', 'lastname', array(
            'label' => 'lastname',
            'required' => true,
            'validators' => array('alnum')
        ));

        $this->addElement('text', 'email', array(
            'label' => 'email',
            'required' => true,
            'validators' => array('EmailAddress')
        ));

        $this->addElement('textarea', 'message', array(
            'label' => 'message',
            'rows' => 5,
            'cols' => 50,
            'required' => true
        ));

        $this->addElement('text', 'birthday', array(
            'label' => 'birthday',
            'description' => 'birthdayDescription'
        ));
        // date validator
        $this->getElement('birthday')->addValidator(new Zend_Validate_Date(null, Zend_Registry::get('Zend_Translate')->getLocale()));

        $this->addElement('checkbox', 'newsletter', array(
            'label' => 'newsletter'
        ));

        $this->addElement('submit', 'submit', array(
            'label' => 'submit'
        ));

        /**
         * Decorators
         */
        $this->clearDecorators();

        $this->addDecorator('FormElements')
             ->addDecorator('HtmlTag', array('tag' => '<ul>', 'class' => 'form'))
             ->addDecorator('Form');

        $this->setElementDecorators($this->_defaultDecorator);

        $this->getElement('firstname')->setDecorators($this->_floatLeftDecorator);
        $this->getElement('lastname')->setDecorators($this->_floatRightDecorator);
        $this->getElement('newsletter')->setDecorators($this->_inlineDecorator);
        $this->getElement('submit')->setDecorators($this->_submitDecorator);

        return $this;
    }

#### Formulaire de contact avec sfForm

    /**
     * Formulaire de contact avec sfForm de Symfony
     */
    public function configure()
    {
      $subjects = array('' => '', 1 => __('commercial'), 2 => __('technical'));
      $years = range(date('Y') - 10, date('Y') - 100);

      $this->setWidgets(array(
        'subject'      => new sfWidgetFormSelect(array('choices' => $subjects)),
        'firstname'    => new sfWidgetFormInput(array(), array('maxlength' => 30)),
        'lastname'     => new sfWidgetFormInput(),
        'email'        => new sfWidgetFormInput(),
        'message'      => new sfWidgetFormTextarea(array(), array('cols' => 50, 'rows' => 5)),
        'birthday'     => new sfWidgetFormDate(array('format' => '%day%/%month%/%year%', 'years'  => $years)),
        'newsletter'   => new sfWidgetFormInputCheckbox(array()),
      ));

      $this->widgetSchema->setLabels(array(
        'subject'      => 'subject',
        'firstname'    => 'firstname',
        'lastname'     => 'lastname',
        'email'        => 'email',
        'message'      => 'message',
        'birthday'     => 'birthday',
        'newsletter'   => 'newsletter',
      ));

      $this->setValidators(array(
        'subject'      => new sfValidatorChoice(array('choices' => array_keys($subjects))),
        'firstname'    => new sfValidatorString(array('required' => true)),
        'lastname'     => new sfValidatorString(array('required' => true)),
        'email'        => new sfValidatorEmail(array('required' => true), array('invalid' => 'Veuillez indiquer un email valide')),
        'message'      => new sfValidatorString(array('required' => true)),
        'birthday'     => new sfValidatorDate(array('required' => false, 'date_format' => '/^[0-9]{2}-[0-9]{2}-[0-9]{4}$/', 'with_time' => false), array()),
        'newsletter'   => new sfValidatorString(array('required' => false)),
      ));

      $this->widgetSchema->setNameFormat('contact[%s]');

      $this->widgetSchema->setFormFormatterName('list');
    }

#### Contrôleur du Zend Framework

    /**
     * Action du contrôleur de traitement du formulaire (Zend Framework)
     */
    public function indexAction()
    {
        // création d'une instance du formulaire
        $form = new Contact(array(
            'action' => $this->view->url(array('action' => 'index')),
            'method' => 'post'
        ));

        // vérification de la validité des données
        if ($this->_request->isPost() && $form->isValid($this->_request->getPost())) {
            // récupération des données
            $values = $form->getValues();

            // traitement des données...

            // redirection vers la page de remerciements
            $this->_redirect('index/success');
            exit;
        }

        $this->view->form = $form;
    }

#### Contrôleur de Symfony

    /**
     * Action du contrôleur de traitement du formulaire (Symfony)
     */
    public function executeIndex($request)
    {
      // création d'une instance du formulaire
      $this->form = new ContactForm();

      if ($request->isMethod('post'))
      {
        $this->form->bind($request->getParameter('contact'));
        // vérification de la validité des données
        if ($this->form->isValid())
        {
          // récupération des données
          $values = $this->form->getValues();

          // traitement des données...

          // redirection vers la page de remerciements
          $this->redirect('form/success');
        }
      }
    }

#### Vue du Zend Framework

    <?php echo $this->form ?>

#### Vue de Symfony

    <form name="form" action="<?php echo url_for('form/index') ?>" method="post">
    <ul class="form">
        <?php echo $form['subject']->renderRow() ?>
    <li class="left">
          <?php echo $form['lastname']->renderError() ?>
          <?php echo $form['firstname']->renderLabel() ?>
          <?php echo $form['firstname']->render() ?>
        </li>
    <li class="right">
          <?php echo $form['lastname']->renderError() ?>
          <?php echo $form['lastname']->renderLabel() ?>
          <?php echo $form['lastname']->render() ?>
        </li>

        <?php echo $form['email']->renderRow() ?>
        <?php echo $form['message']->renderRow() ?>
        <?php echo $form['birthday']->renderRow() ?>
    <li>
          <?php echo $form['newsletter']->render() ?>
          <?php echo $form['newsletter']->renderLabel(null, array('class' => 'inline')) ?>
        </li>
    <li>
    <input type="submit" name="submit" id="submit" value="<?php echo __('submit') ?/>"></li>
    </ul>
    </form>

### Avantages / inconvénients sfForm

Inconvénients :

* pas de gestion des fieldset avec legend (aucune possibilité de grouper des widget) ;
* pas de génération complète du formulaire (balises form et submit à ajouter manuellement dans la vue, je reviens sur ce point en conclusion) ;
* "formatter" plus limitée que les "decorators" de Zend_Form (pas de surcharge d'un "formatter" pour un widget spécifique) ;
* recopie inutile des labels pour l'internationalisation ;

### Avantages / inconvénients Zend_Form

Avantages :

* génération totale du formulaire ;
* système des "decorators" flexibles et complets ;

### Bilan

Question temps, j'ai mis un peu plus de 4h pour réaliser ce formulaire avec Symfony et pas loin de 5h avec Zend Framework. En sachant que je n'ai pas compté le temps de mise en place du projet, ce temps étant annexe à l'exercice et d'autant plus car la logique de création d'un projet est assez différente entre Symfony et Zend Framework. Symfony est ce que l'on appelle un "full stack framework" (comprendre tu dézippes, tu as toute l'arborescence de ton projet), tandis que Zend Framework laisse libre la structuration de son projet, il donne seulement quelques recommandations.

Ce temps a été découpé en relecture de la documentation, création du formulaire et mise en place d'un layout.  
On peut trouver le temps de réalisation un peu long en comparaison d'un formulaire généré "from scratch", pour autant avec ces 2 librairies je dispose de nombreux composants, de nombreux validateurs, d'une bonne sécurité et surtout d'une flexibilité.

Enfin dans les 2 cas, je n'ai pas pleinement rempli les contraintes de départ de mon exercice :

Concernant Symfony :

* pas d'étoile rouge après les labels des champs obligatoires (possible à faire dans le "formatter" ?) ;
* le fichier de la vue est un peu chargé, vu que les affichages spécifiques ne sont pas gérés via un "formatter" ;

Concernant Zend Framework :

* le champ date de naissance n'est pas géré avec des sélecteurs, le composant n'est pas de base implémenté dans le framework ;
* le label de l'inscription à la newsletter se trouve avant la case à cocher (je n'ai pas trouvé le moyen de le faire avec les "décorators").

### Conclusion

On peut constater que la manière de créer un formulaire avec ces 2 composants est relativement semblable, tout du moins elle l'est sur un exemple aussi simple. Une fois que la logique est comprise, on peut assez facilement passer de l'un à l'autre.

Au delà de l'aspect coeur de réalisation, j'entends par là design pattern mis en oeuvre ou encore logique interne, j'ai surtout le sentiment que ces 2 composants diffèrent sur la forme :

sfForm et Zend_Form se différencient principalement au niveau de la génération de la partie vue :

* sfForm par le biais des "formatter" propose seulement un gabarit général de présentation du formulaire. Les cas particuliers, les affichages spécifiques seront à votre charge dans la vue, nous allons voir ci-dessous comment ce choix est justifié.
* Zend_Form quant à lui donne la possibilité de créer de multiples "decorators" qui décrivent chacun un comportement du formulaire. En résumé, vous pouvez définir un "decorator" par défaut (qui agira au même titre qu'un "formatter") ainsi que des "decorators" spécifiques à chaque rendu graphique.

#### Génération complète du formulaire

On peut se demander l'intérêt d'une génération complète du formulaire, voici quelques exemples :

* pour chaque champ ajouté dans le formulaire, il faudra penser à l'ajouter dans la vue (et gare aux erreurs sur le nom des champs) ;
* si je fais une modification générale sur le gabarit, il me sera nécessaire de la répercuter au niveau spécifique du formulaire, par exemple si je ne souhaite plus gérer mon formulaire via des listes à puces mais plutôt avec des div ou des listes de définitions, il me sera nécessaire de modifier le "formatter" du formulaire ainsi que la vue (si j'oublie, j'aurais de belles erreurs xhtml...) ;
* plus fréquent, j'ajoute un champ upload, il me faudra penser à ajouter l'entête enctype dans le formulaire... ;

Tout ceci manque un peu de modularité en somme, utiliser un outil de génération des formulaires devrait nous permettre de nous décharger de ce genre de "soucis", le framework doit les prendre en charge pour nous.

#### Différence entre formatter et decorators

Les "formatters" de Symfony gèrent le comportement de l'intégralité du formulaire, il n'est pas possible (à ma connaissance) de personnaliser le "formatter" d'un "widget" en particulier. Sous Zend Framework les "decorators" interviennent au niveau général du formulaire et au niveau de chaque "element", je trouve ce système plus modulaire, je m'explique : l'avantage principal que je vois à cette technique, c'est que je peux préparer les comportements spécifiques de mes formulaires (élément à gauche, élément à droite, élément sans label, élément en ligne pour une case à cocher par exemple, etc.) et je les utilise ensuite librement dans mes formulaires, sans avoir à modifier ma vue.

Après quelques recherches et notamment à la lecture de l'article "[Les formulaires Symfony 1.1 et le pattern MVC][8]" du [blog de Fabien Potencier][9], j'apprends que ce choix a été fait dans un respect du pattern MVC, et on peut y lire :

> "Mais il faut garder à l'esprit que echo $form est juste un raccourci sympathique. Il est très pratique pour créer un prototype rapide mais la plupart du temps, vous voudrez avoir un contrôle plus important sur le rendu du formulaire et sur la disposition des différents widgets dans la page. Et c'est là que le nouveau système est vraiment puissant. Le travail des intégrateurs est grandement simplifié."

J'en suis venu à me demander si le système des "decorators" du Zend Framework respectait le patten MVC, mais je pense que oui, puisqu'ils décrivent des comportements de rendu graphique (en l'occurence HTML) au même titre que le "formatter" de Symfony... Qu'en pensez vous ?

On continue avec une deuxième justification de ce choix dans la [documentation officielle de sfForm][10], nous avons là un scénario de travail en équipe, où développeurs et intégrateurs travaillent en parallèle sur le même projet grâce à ce système découpé.

Certes l'analyse est bonne mais sur ce point je trouve Zend_Form intéressant étant donné que je suis à la fois développeur et intégrateur sur mes projets, c'est donc naturellement moi qui définit les différents "décorators", donc les différents comportements possibles de mes formulaires. A l'inverse une équipe qui travaillera sur le modèle défini ci-dessus sera peut être gênée par ce modèle car c'est aux développeurs d'agir sur les "decorators" et non aux intégrateurs...

#### Avis perso

Dans sfForm, j'ai aimé :

* la simplicité d'utilisation ;
* le nombre de "widgets" et la quantité de validateurs ;
* le fait que sfForm soit un framework en lui même donc utilisable sans Symfony ;
* la génération de formulaire et l'intégration avec Propel et Doctrine qui va infiniment plus loin que Zend_Form.

Dans sfForm, j'ai pas aimé :

* la gestion des "formatter" ;
* l'obligation de coder dans la vue dans les cas spécifiques ;

Dans Zend_Form, j'ai aimé :

* génération complète du formulaire au moyen des "decorators" ;

Dans Zend_Form, j'ai pas aimé :

* le réel manque d'éléments et de validateurs (il n'y a même pas un validateur pour vérifier l'égalité entre 2 champs...) ;
* trop d'écritures alternatives d'un formulaire : il existe 4 ou 5 façon différentes d'écrire un formulaire avec Zend_Form. C'est bien de laisser de la liberté aux développeurs mais un framework est censé apporter des normes et une cohésion.

### Ressources

Zend_Form du Zend Framework :

Voilà pour cet article, beaucoup risquent de trouver que je survole de très haut les fonctionnalités de ces 2 composants, le but n'était pas de donner un tutoriel avancé, mais plutôt de se donner un exercice (avec ses facilités et ses contraintes) et de tenter de s'approcher au maximum du résultat escompté avec ces 2 composants. Le but final est plutôt de donner envie aux développeurs qui ne connaissent ni [Symfony][2], ni [Zend Framework][3] de tenter l'expérience, car l'un comme l'autre, ces frameworks donnent lieu à un développement beaucoup plus agréable !

Si vous relevez des coquilles ou améliorations à apporter à cet article, n'hésitez pas, le formulaire de commentaire ci-dessous est là pour ça.

[1]: /archives/2008-11-12-astuces-d-integration-css-pour-ie
[2]: http://www.symfony-project.org/
[3]: http://framework.zend.com/
[4]: http://www.biologeek.com/web-frameworks/definition-et-avantages-d-un-framework-web/
[5]: http://twodecember.com/fr/kronos/
[6]: http://twodecember.com/
[7]: /images/archives/2008-12-26-exercice-de-formulaire-avec-zend-form-et-sf-form/form-mini.gif
[8]: http://www.aide-de-camp.org/article/3/fr/les-formulaires-symfony-1-1-et-le-pattern-mvc
[9]: http://www.aide-de-camp.org/
[10]: http://www.symfony-project.org/book/forms/1_2/fr/03-Forms-for-web-Designers#L%27Interaction%20avec%20le%20D%C3%A9veloppeur
