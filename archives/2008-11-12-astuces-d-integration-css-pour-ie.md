---
layout: page
title: Astuces d'intégration CSS pour IE
image:
  feature: slides/default.jpg
---

**Attention :** cet article a été rédigé en 2008, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Cela fait bientôt 3 ans que je travaille comme développeur Web chez [Pyxis][1], j'y intègre la quasi totalité des maquettes graphiques. J'ai appris bien des choses sur le xhtml et le CSS, j'ai aussi fait beaucoup d'erreurs, ce qui me permet aujourd'hui de vous faire un petit retour de mon expérience. Et aussi évidemment d'en apprendre plus de toi lecteur, de tes compétences et astuces !

Je compte donc faire une série d'articles traitant du Xhtml / CSS, du Javascript, des bonnes pratiques, des méthodes d'organisation, etc. Ce premier article traitera d'astuces CSS et d'intégration pour IE. Pas mal concernent IE 6, certes ce navigateur date de 2001, on pourrait légitimement se demander pourquoi optimiser pour ce dernier. Pourtant son pourcentage d'utilisation oblige a encore le prendre en compte. La faute a bien des postes où les mises à jours sont impossibles, vieilles versions de Windows, utilisateurs néophytes, etc.

Ci-dessous quelques astuces, globalement elles sont assez connues et relativement communiquées, mais je rencontre encore trop d'intégrateurs qui ne les connaissent pas.

#### Sommaire

### Double margin sur un élément flottant (IE 6)

Ce bug survient lorsque vous utilisez une marge dans le même sens qu'un float. En d'autre terme une marge à gauche sur un élément flottant à gauche et inversement une marge à droite sur un élément flottant à droite. Un petit exemple :

    .floatbox { float: left; width: 150px; height: 150px; margin-left: 100px; }

Ceci appliquera un margin left de 200px sur IE 6 :

![Bug du double margin][2]

Heureusement il existe une astuce simple, qui consiste à rajouter la propriété display à la valeur "inline". Dès lors votre bloc se comporte normalement sous IE 6. L'avantage majeur de cette astuce est qu'elle n'influera pas le comportement des autres navigateurs car la propriété float est prioritaire à display.

Cette astuce est extrêmement importante à connaître car dans le cas contraire on peut parfois tomber sur des codes difficilement maintenables avec des surcharges des valeurs des marges pour IE 6...

Le code final sera donc :

    .floatbox { float: left; width: 150px; height: 150px; margin-left: 100px; display: inline; }

Ce bug survient aussi si vous avez plusieurs éléments flottants côte à côte avec une marge **mais que pour le premier élément** ! Prenons un exemple simple un menu de navigation horizontal avec une marge entre chaque élément :

    #nav { margin: 0; padding: 0; list-style: none; }
    #nav li { float: left; width: 100px; height: 30px; line-height: 30px; margin: 0 10px; border: 1px solid #eee; }

    <ul id="nav">
    <li></li>
    <li></li>
    <li></li>
    </ul>

![Bug du double margin avec plusieurs éléments][3]

Comme dans l'exemple précédent un simple display inline résoudra ce fâcheux problème :

    #nav li { float: left; width: 100px; height: 30px; line-height: 30px; margin: 0 10px; border: 1px solid #eee; display: inline; }

Source [chez positioniseverything.net][4]

Retour au sommaire

### Non interprétation de la propriété min-height (IE 6)

Cette chère propriété qui nous est souvent bien pratique, notamment pour un div avec un dégradé, il vous assure que le bloc aura au minimum la hauteur de votre dégradé, n'est pas interprété par IE 6. Heureusement, comme la vie d'intégrateur est quand même bien faite, le comportement de la propriété height sous IE 6 est similaire à celle de min-height.

    #round { min-height: 100px; }
    /* ajout pour IE 6 */
    #round { height: 100px; }

L'astuce est, cette fois-ci, plus complexe, car mettre la propriété height à tous les navigateurs aura forcément des répercutions sur l'affichage. Il est donc nécessaire d'appliquer cette propriété uniquement pour IE 6. Ca se complique...

* Commentaires conditionnels : incontestablement la solution la plus propre, mais pas forcément la plus simple à maintenir, en effet elle vous oblige à avoir une CSS dédiée aux surcharges pour IE.En savoir plus [chez blog-and-blues.org][5] ;
* Commentaires conditionnels détournés pour ajouter un identifiant à la balise body, je pense revenir plus en détail sur cette technique dans un futur billet, car elle m'a beaucoup séduit.En savoir plus [chez lesintegristes.net][6] ;
* Un hack : il vaut mieux éviter car on ne peut être sûr de son fonctionnement dans le temps (mise à jour des navigateurs), néanmoins il permet de centraliser la CSS et les surcharges pour IE dans une seule CSS.En savoir plus [chez blog.pixarea.com][7] ;

Retour au sommaire

### La hauteur minimum d'un élément (IE 6)

Sous IE 6, tous les éléments ont une hauteur minimum, même après avoir mis la propriété height à "10px" par exemple. Par exemple, nous souhaitons faire un rectangle de couleur de 10px de hauteur :

    #little-box { width: 100px; height: 10px; background: #eee; }

    <div id="little-box"></div>

Ce qui donnera :

![Bug de la hauteur minimum sur un élément][8]

Cela provient de l'interligne et de la taille du texte qui sont par défaut définit à 16px sur tous les éléments. Pour résoudre ce problème, il vous faut soit redéfinir les propriétés "line-height" et "font-size", soit rogner ce qui dépasse de l'élément au moyen de la propriété "overflow".

Solution n°1 :

    #little-box { width: 100px; height: 10px; background: #eee; font-size: 0; line-height: 0; }

Solution n°2 :

    #little-box { width: 100px; height: 10px; background: #eee; overflow: hidden; }

Certes nous sommes des intégrateurs, mais nous sommes avant tout des développeurs, aussi rappelons nous de nos enseignements, à savoir de prendre toujours le chemin le plus court, et de coder le moins possible. Nous choisirons donc la solution n°2 ;-)

Si maintenant nous souhaitons avoir du texte dans notre #little-box, il faudra par contre redéfinir les propriétés "line-height" et "font-size" au risque de ne pas voir le texte... Donc :

    #little-box { width: 100px; height: 10px; background: #eee; font-size: 11px; line-height: 10px; text-align: center; overflow: hidden; }

    <div id="little-box">Little box</div>

Et voilà, merci IE... Mais en y réfléchissant là encore c'est un bug très facile à corriger, il suffit seulement d'ajouter une propriété qui n'influe pas le comportement des autres navigateurs. C'est un peu de temps et une habitude à prendre pour que vos sites passent correctement sous ce dinosaure d'IE 6.

Retour au sommaire

### Le clear sur un élément flottant (IE)

Si vous avez plusieurs éléments flottants dont un avec un "clear", vous serez surpris du rendu sous IE. En effet l'élément avec "clear" sera bien interprété mais les suivants ne partiront pas de lui comme base. Un exemple sera beaucoup plus simple à comprendre :

    #box1 { float: left; width: 50px; height: 20px; background: #eee; }
    #box2 { clear: left; float: left; width: 100px; height: 25px; background: #ccc; }
    #box3 { float: left; width: 50px; height: 30px; background: #aaa; }

    <div id="box1"></div>
    <div id="box2"></div>
    <div id="box3"></div>

Voici le rendu qu'auront ces 3 blocs :

![Bug du clear sur un élément flottant][9]

On voit bien ici que le bloc avec "clear" est bien passé à la ligne, mais le 3ème bloc ne le prends pas comme base et est flottant à partir du 1er bloc. La solution est d'ajouter un élément vide juste avant l'élément avec "clear". Comme ceci :

    <div id="box1"></div>
    <div "=""></div>
    <div id="box2"></div>
    <div id="box3"></div>

Bon, sur ce précédent exemple, on peut se poser la question de l'intérêt de cette technique, elle peut servir, entre autre, pour des menus horizontaux sur plusieurs lignes, exemple :

    #float-box { width: 400px; margin: 0; padding: 0; list-style: none; }
    #float-box li { float: left; width: 80px; line-height: 20px; margin: 10px; border: 1px solid #eee; }

    <ul id="float-box">
    <li>Box 1</li>
    <li>Box 2 with long text</li>
    <li>Box 3</li>
    <li>Box 4</li>
    <li>Box 5</li>
    <li>Box 6</li>
    </ul>

Dans cet exemple, les éléments de la seconde ligne seront déstructurées car il manque un clear sur le 4ème élément. Etant donné que celui-ci sera aussi flottant, nous allons utiliser la technique apprise ci-dessus en ajoutant un élément vide juste avant l'élément flottant avec le clear, comme ceci :

    #float-box { width: 400px; margin: 0; padding: 0; list-style: none; }
    #float-box li { float: left; width: 80px; line-height: 20px; margin: 10px; border: 1px solid #eee; color: #fff; }
    #float-box li.break { float: none; width: auto; margin: 0; border: 0; }
    #float-box li.clear { clear: left; }

    <ul id="float-box">
    <li>Box 1</li>
    <li>Box 2 with long text</li>
    <li>Box 3</li>
    <li class="break"></li>
    <li class="clear">Box 4</li>
    <li>Box 5</li>
    <li>Box 6</li>
    </ul>

La seule différence avec l'exemple précédent est que nous sommes obligé de surcharger les propriétés de l'élément vide car nous avons directement ciblé tous les "li", il faut donc lui annuler les effets classiques. Ce qui donnera :

![Bug du clear sur un élément flottant][10]

Source [chez brunildo.org][11]

Retour au sommaire

### Conclusion

Pour conclure, je dirai qu'une seule chose, si votre code CSS contient trop de hacks, d'exceptions, de surcharges, etc. c'est qu'il y a un problème. Votre code doit rester, autant que possible simple ! Si vous commencez votre découpage et que l'intégration vous parait complexe, pleines de subtilités, c'est sans doute que vous prenez le mauvais chemin. Réfléchissez, tournez la maquette dans tous les sens, il y a certainement une méthode plus simple ! Et oui l'intégration est un puzzle :)

Relisez toujours vos CSS, il y a souvent des propriétés qui ne servent plus à rien, il y a souvent moyen de centraliser quelques bouts de code, le tout dans l'optique d'alléger votre CSS. Car aujourd'hui votre CSS vous parez compréhensible, mais dans quelques mois lorsque vous devrez faire une modification elle le sera probablement beaucoup moins !

Et si vraiment la maquette vous parait toujours aussi complexe, ou irréalisable, allez voir votre graphiste, après tout on fait du Web, pas des flyers ;) cela entraîne inévitablement des contraintes.

Et si après tout ça, vous n'arrivez toujours pas à intégrer votre site sous IE, il ne vous reste plus [qu'à lire cet article][12]... ;-)

[1]: http://www.pyxis.org/
[2]: /images/archives/2008-11-12-astuces-d-integration-css-pour-ie/margin-bug.jpg
[3]: /images/archives/2008-11-12-astuces-d-integration-css-pour-ie/margin-bug2.jpg
[4]: http://www.positioniseverything.net/explorer/doubled-margin.html
[5]: http://www.blog-and-blues.org/articles/Les_syntaxes_de_commentaires_conditionnels_pour_IE_Windows
[6]: http://www.lesintegristes.net/2008/04/08/cibler-internet-explorer-dans-une-css-oui-et-sans-hack/
[7]: http://blog.pixarea.com/index.php/2006/06/13/39-css-un-hack-simple-pour-ie7
[8]: /images/archives/2008-11-12-astuces-d-integration-css-pour-ie/line-height.jpg
[9]: /images/archives/2008-11-12-astuces-d-integration-css-pour-ie/clear-float.jpg
[10]: /images/archives/2008-11-12-astuces-d-integration-css-pour-ie/clear-float2.jpg
[11]: http://www.brunildo.org/test/IEWfc.html
[12]: http://www.designer-daily.com/internet-explorer-6-debugging-techniques-you-wont-learn-in-school-1248
