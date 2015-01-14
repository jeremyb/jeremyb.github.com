---
layout: page
title: Gestion d'erreurs PHP au niveau du SGBD
image:
  feature: slides/default.jpg
---

**Attention :** cet article a été rédigé en 2005, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

_Remarque : L'exemple suivant est traité avec PHP 5 et SQLite ([def. wikipédia][1])._

**Nature de l'exemple :** Prenons un exemple simple, vous traitez des projets et des employés. Vous gérez un système permettant d'assigner des employés sur un ou plusieurs projets (jusque la rien de compliqué). La contrainte est la suivante : il ne peut y avoir plus de quatre employés assignés à un projet.

### Accéder à une base de donnée SQLite via PHP

Vous avez deux possibilités pour accéder à une base de donnée SQLite, la méthode procédurale (qui est à éviter si vous coder en PHP 5) et la méthode objet, méthode que je vais présenter.

_Remarque : Votre base de donnée doit forcément se trouver avec un droit d'accès 777._

##### Méthode procédurale :

    $db = sqlite_open("db/gestionProjet.db");

##### Méthode objet :

    $sqlite = new SQLiteDatabase("db/gestionProjet.db");

_Information : Il est possible de faire passer deux paramètres de plus, le mode d'accès qui pour le moment est ignoré des bibliothèques de SQLite (valeur par défaut 0666), et un message d'erreur affiché dans le cas où la base n'arrive pas à être ouverte._

### Résolution de la contrainte (ancienne méthode)

Avant, nous aurions simplement exécuté une requête allant compter le nombre de participants actuel au projet, si le chiffre était inférieur à quatre, alors nous aurions laissé faire la requête d'insertion d'un participant, dans le cas contraire nous aurions directement affiché un message d'erreur.

_Information : La table qui contient les employés participants à des projets s'appelle participer et le champ de cette table qui fait lien avec un projet s'appelle partProjet._

Voici le code :

    $nb = $sqlite->singleQuery("select count(*) from participer where partProjet=".$_POST['projet']."");
    if ($nb < 4) {
         // Requête d'insertion
    } else {
         // Message d'erreur (cause : il faut moins de quatre participants pour un projet)
    }

### Résolution de la contrainte (utilisation d'un déclencheur)

Gràce à SQLite, il est possible de mettre en place un déclencheur (trigger), il est spécifié pour ce dernier dans quelle condition et sur quelle table il sera appelé automatiquement. La condition spécifie si l'action se fera lors d'une insertion (insert), d'une modification (update) ou d'une suppression (delete) ensuite il faut préciser sur quelle table se fera cette vérification. Par la suite automatiquement, lors d'une insertion sur la table spécifié, par exemple, un traitement viendra s'exécuter.

On peut de plus accéder aux données de la requête qui a amené au traitement du déclencheur.

* Lors d'une insertion, on utilisera le mot clé _new_ avant le champ que l'on cherche à récupérer.
* Lors d'une modification, on utilisera _old_ pour accéder à la valeur qui va être remplacée, et _new_ pour accéder à la valeur de remplacement.
* Lors d'une suppression, on utilisera _old_ pour accéder à la valeur qui va être supprimée.

_Information : Je ne connais pas trop le langage SQL de SQLite qui permet de faire les déclencheurs, j'ai appris qu'il était fortement semblable au PL SQL de Oracle. Pour ma part j'ai repris un exemple pour m'inspirer de mes déclencheurs._

Il faut ensuite mettre en place un déclencheur de ce style :

    create trigger verifNbreParticipants before insert on participer for each row
    begin
    select case
    when (select count(*) from participer where partProjet=new.partProjet)>=4 then raise (fail, 'Erreur nombre participants')
    end;
    end;

_Information : Exécutez simplement une requête à la base de donnée contenant ce déclencheur pour l'activer._

A partir de la, refaites votre insertion, jusqu'à ce qu'il y ai quatre participants pour un projet. Vous verrez apparaître une belle erreur en haut de votre navigateur :

    Warning: SQLiteDatabase::query() [function.query]: Erreur nombre participants

On reconnaît tout de même le message d'erreur que l'on a prévu dans le déclencheur :

    raise (fail, 'Erreur nombre participants')

### Redéfinition des messages d'erreurs en PHP

On ne va pas laisser cette vieille erreur en haut du navigateur quand même ?! La méthode _set_error_handler()_ nous permet de redéfinir les messages d'erreurs de PHP. Il suffit de lui passer en paramètre le nom de la fonction qui prendra en charge les messages d'erreurs.

_Information : Vous trouverez plus d'information sur cette fonction et sur les paramètres spécifiés ci-dessous, [ici][2]._

Créons une fonction de gestion des erreurs :

    function gestionErreur($errno, $errstr, $errfile, $errline) {
         if (ereg("Erreur nombre participants", $errstr)) {
              $erreur = "Il ne peut pas y avoir plus de quatre développeurs sur un même projet.";
         }
    }

A partir de la vous pouvez faire afficher cette erreur à l'endroit où vous voulez et avec votre propre mise en page, comme ceci :  
![][3]

### Conclusion

Ce style de programmation permet de bien séparer les tàches et les traitements.  
Verdict : je langi vraiment que ce soit implémenté sous MySQL.

[1]: http://fr.wikipedia.org/wiki/SQLite
[2]: http://www.nexen.net/docs/php/annotee/function.set-error-handler.php?lien=handler
[3]: /images/archives/2005-06-16-gestion-des-erreurs-php-au-niveau-du-sgbd/erreur.jpg
