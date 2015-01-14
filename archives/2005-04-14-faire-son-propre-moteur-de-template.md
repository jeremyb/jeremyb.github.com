---
layout: page
title: Faire son propre moteur de template
image:
  feature: slides/default.jpg
---

**Attention :** cet article a été rédigé en 2005, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

On est loin des [Smarty][1] ou autre [templeet][2], mais l'idée de programmer son propre moteur de template peut être interessante, d'autant plus lorsque votre projet PHP est simple et ne demande donc pas l'utilisation des fonctions complexes de tels moteurs de templates. Vous gagnerez ainsi en rapidité d'execution et en consomation de ressource serveur.

#### Mais tout d'abord, qu'est ce qu'un moteur de template ?

Le moteur de template est un moyen élégant de séparer la forme, de la programmation _(le fond)_. D'un côté vous aurez votre programmation PHP / ASP / etc. _(dans notre cas PHP)_ et de l'autre vos différents fichiers templates correspondants à un modèle de mise en page.  
La conception du projet d'une part, et la conception des pages d'autre part seront grandement facilité.  
Immaginez une page PHP sans _echo "";_ ^^  
Dans la même optique, fini les _"_ au milieu du HTML :)  
Quelques exemples parmis bien d'autres qui vous facilitent la vie lors de l'utilisation d'un moteur de template.

#### Rôle du moteur de template

Le moteur de template va simplement afficher la page que vous souhaitez, en d'autre terme, vous passerez en paramètre le nom du fichier à afficher et le moteur de template se charge du reste.  
Vous avez en plus de cela la possibilité de faire afficher la valeur de retour d'une variable, chose pratique sinon vos pages aurez été statique :) Il vous faudra donc choisir un formalisme de notation des variables pour votre moteur de template. Dans l'exemple suivant, le voici : _{variable}_. La variable _{variable}_ devra donc être remplacée par une valeur. Ce procédé se fait dans votre programmation PHP, juste avant d'afficher le contenu d'un fichier template.

#### Les données de la classe de votre moteur de template

En premier lieu votre fichier devra comporter l'entête de la classe, c'est à dire :

    <?php
    class template {}
    ?>

Les données vous aideront sans doute à comprendre ce qu'il faut stocker pour que le moteur de template fonctionne, les voici :

    private $repertoireTemplate;
    private $contenuAAfficher;
    private $variablesAssigneesCle;
    private $variablesAssigneesValeur;

**$repertoireTemplate** contient le chemin vers le répertoire contenant vos fichiers template.  
**$contenuAAfficher** représente le contenu de votre fichier template à afficher.  
**$variablesAssigneesCle** c'est le nom de la variable du moteur de template à remplacer, dans notre cas ci-dessus _({variable})_, il faudrait donc mettre en clé "variable".  
**$variablesAssigneesValeur;** représente les valeurs de remplacement des variables du moteur de template.

#### Le contructeur de la classe

    function __construct($repertoire) {
         $this->repertoireTemplate = $repertoire;
         $this->contenuAAfficher = "";
         $this->variablesAssigneesCle = array();
         $this->variablesAssigneesValeur = array();
    }

Ce constructeur reçoit qu'un paramètre, le chemin vers le répertoire de vos fichiers templates.  
Vous allez maintenant voir à quoi ressemble l'entête de votre fichier PHP :

    <?php
    require("template.class.php"); // moteur de template
    $tpl = new template("templates/");
    ?>

#### Assigner une valeur PHP à une variable du moteur de template

La fonction suivante vous permettra d'assigner une clé à une valeur, la clé est le nom de votre variable dans le moteur de template, tandis que la valeur peut être une variable PHP, le résultat d'une requête, une simple chaîne de caractère.

    function ajouteAccolade($val) {
         return "{".$val."}";
    }

    function assigner($cle, $valeur) {
         $cle = $this->ajouteAccolade($cle);
         array_push($this->variablesAssigneesCle, $cle);
         array_push($this->variablesAssigneesValeur, $valeur);
    }

La fonction _ajouteAccolade($val)_ est en lien avec la notation des variables que nous avons choisi. Si vous souhaitez la changer, c'est ici que ça se passe :)  
_assigner($cle, $valeur)_ quant à elle rajoute au tableau de clé et de valeur, les valeurs passées en paramètres. C'est à partir de ce tableau de clé et de valeur que nous ferons ensuite le changement des variables du moteur de template, juste avant d'afficher le contenu. Pour l'exemple (dans votre fichier PHP) :

    $test = "Gnome";
    $tpl->assigner("test", $test);

#### Afficher le contenu d'un fichier template et remplacer les variables par des valeurs

Voici le code de la fonction :

    function ajouterTemplate($fichier) {
    $this->contenuAAfficher = file_get_contents($this->repertoireTemplate.$fichier);
    }

    function afficher($fichier) {
         $this->ajouterTemplate($fichier);
         $this->contenuAAfficher = str_replace($this->variablesAssigneesCle, $this->variablesAssigneesValeur, $this->contenuAAfficher);
         echo $this->contenuAAfficher;
         $this->contenuAAfficher = "";
         $this->variablesAssigneesCle = array();
         $this->variablesAssigneesValeur = array();
    }

La fonction _ajouterTemplate($fichier)_ récupére tout le contenu du fichier template. _afficher($fichier)_ quant à elle remplace les valeurs des clés par les valeurs des valeurs ^^ et affiche le résultat. Il faut penser à réinitialiser les variables à vide, sinon votre texte va se cumuler et je ne traiterai pas ce modèle de template ici. Certains en effet permettent d'enregistrer le contenu de plusieurs fichiers templates et de les afficher tous à la fin.  
Toujours avec la même simplicité, voila comment faire afficher le contenu d'un fichier template dans votre navigateur. Tout d'abord il vous faut éditer votre premier fichier template :

    Hello World!
    (Ca fait geek ça)
    {test} applets are nice!

Vous enregistrerez ce dernier dans votre répertoire de templates sous un nom quelconque.  
Du côté PHP, voici ce que ça donne :

    <?php
    require("template.class.php"); // moteur de template
    $tpl = new template("templates/");
    $test = "Gnome";
    $tpl->assigner("test", $test);
    $tpl->afficher("nomdufichiertemplate.tpl");
    ?>

{test} va être remplacé par Gnome dans notre exemple, ce qui donnera au final :

    Hello World!
    (Ca fait geek ça)
    Gnome applets are nice!

#### Code complet du moteur de template

    <?php

    class template {
    	private $repertoireTemplate;
    	private $contenuAAfficher;
    	private $variablesAssigneesCle;
    	private $variablesAssigneesValeur;

    	function __construct($repertoire) {
    		$this->repertoireTemplate = $repertoire;
    		$this->contenuAAfficher = "";
    		$this->variablesAssigneesCle = array();
    		$this->variablesAssigneesValeur = array();
    	}

    	function ajouterTemplate($fichier) {
    		$this->contenuAAfficher = file_get_contents($this->repertoireTemplate.$fichier);
    	}

    	function assigner($cle, $valeur) {
    		$cle = $this->ajouteAccolade($cle);
    		array_push($this->variablesAssigneesCle, $cle);
    		array_push($this->variablesAssigneesValeur, $valeur);
    	}

    	function ajouteAccolade($val) {
    		return "{".$val."}";
    	}

    	function afficher($fichier) {

    		$this->ajouterTemplate($fichier);
    		$this->contenuAAfficher = str_replace($this->variablesAssigneesCle, $this->variablesAssigneesValeur, $this->contenuAAfficher);
    		echo $this->contenuAAfficher;
    		$this->contenuAAfficher = "";
    		$this->variablesAssigneesCle = array();
    		$this->variablesAssigneesValeur = array();
    	}

    	function setRepertoireTemplate($repertoire) {
    		$this->repertoireTemplate = $repertoire;
    	}
    }

    ?>

#### Conclusion

Les moteurs de templates du style Smarty ou Templeet, vous permettront évidemment de faire beaucoup plus, puiqu'il vous sera possible d'intégrer un code ressemblant au PHP directement dans vos fichiers templates, ce qui vous permettra par exemple d'effectuer une boucle foreach ou un if. Ces moteurs de template compilent un fichier PHP à partir des informations renseignées dans le fichier template. Ils conservent donc une trace et permettent un système de cache.

Donc le moteur de template que je viens de vous présenter là est beaucoup moins complet, mais ne fait que 45 lignes de codes lol :)

_Pour information, cette technique n'est peut être pas la meilleure, ou peut être déjà connue, je ne sais pas, mais bon, on fait partager, ce qu'on peut faire partager :)   
j'espère que cet article n'est pas trop décousu et qu'il vous aidera._

[1]: http://smarty.php.net/
[2]: http://www.templeet.org/index.fr.html
