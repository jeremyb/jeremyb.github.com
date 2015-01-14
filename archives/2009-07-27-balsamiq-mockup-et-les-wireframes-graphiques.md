---
layout: page
title: Balsamiq Mockup et les wireframes graphiques
image:
  feature: slides/default.jpg
---

[Cet article a été intialement publié sur le blog de Lexik][lexik_blog]
{: .alert .alert-warning}

**Attention :** cet article a été rédigé en 2009, le contenu ou les éléments abordées peuvent être obsolète.
{: .alert .alert-warning}

Habituellement nous vous parlons du framework Symfony car c'est un des outils qui nous rend le plus de services pendant le développement. Mais n'oublions pas que la gestion d'un projet est primordiale à son bon déroulement. Cet article n'a pas pour ambition de présenter toutes les ficelles de la gestion de projet mais simplement de se concentrer sur un point très important dans le Web à savoir **le passage d'un prototype à la maquette graphique finale**. Aussi cet article va vous présenter le concept des **wireframes** et d'un outil de conception à savoir **Balsamiq Mockup**.

### 1. Qu'est ce qu'un prototype / user-story ?

Dans le cadre de réunion autour d'un projet Web, on voit souvent quelqu'un sortir une feuille de papier, prendre un crayon, dessiner quelques traits hasardeux, des blocs par ci, par là, afin de présenter à un client ou un graphiste le rendu souhaité d'un site Internet ou d'un logiciel. C'est l'idée du wireframe, en beaucoup moins brouillon ! Le wireframe atteint un vrai niveau de précision, lorsque ce dernier est finalisé, on a une vision cohérente du futur rendu, il ne reste plus qu'au graphiste à ajouter sa touche graphique...

## 2 logiques pour les prototypes / user-story :

On peut globalement définir **2 styles de prototypes d'interfaces** :

**1. le wireframe "graphique" :** il s'agit d'un prototype / scénario dont le but est de s'approcher au maximum du rendu final du site Internet. Dans un premier temps, on place les différentes zones à l'écran, cette étape s'appelle le **zoning**, elle permet d'organiser la page. Dans un second temps, on se concentre sur l'ergonomie, la communication générale, qui se clôture par le **wireframe**. A ce stade là, le wireframe détaille à la fois l'**organisation de la page** mais également l'**ergonomie générale**, l'étape suivante est naturellement la charte graphique.

_**Note :** le wireframe peut faire l'objet d'une validation auprès du client et joue un rôle de support dans la communication avec le graphiste._

On comprend bien l'intérêt de toutes ses étapes qui nous approche de manière réfléchi et construite vers la maquette graphique, cela peut se résumer par :

**zoning &gt; wireframe &gt; charte graphique**

**Quelques outils :**

* [Balsamiq Mockup](http://www.balsamiq.com/products/mockups) ;
* [iPlotz](http://iplotz.com/).

**2. le user-story ou histoires d'utilisateur** implique un besoin moins statique, 1 seul écran ne suffit pas. L'idée est de présenter un cas, un besoin, une problématique sur plusieurs écrans, dans une idée de **séquences**. Ce type de wireframe est beaucoup moins lié au graphiste, d'ailleurs la touche graphique y est beaucoup moins importante. On est plus proche de la couche métier du projet et ces outils sont plus destinés au client et au développeur. C'est pour moi une étape parallèle au wireframe "graphique", cet article n'en détaillera pas plus le fonctionnement.

## **Les gains d'un wireframe ?**

Les gains sont multiples, en effet pour en arriver au wireframe, plusieurs briefs ont été réalisés. L'objectif final, les éléments à mettre en avant, l'ergonomie et la communication générale ont été débattus et travaillés. Le résultat n'en est que positif ! Imaginez si vous vous étiez lancés directement sur la maquette graphique, les changements a posteriori sont beaucoup plus longs et couteux.

### 2. Balsamiq Mockup ?

Ce logiciel possède une interface **claire et intuitive**, les différents composants sont très variés (**environ 70** répartis en : formulaires, blocs, player vidéo, calendrier, tree view, nuage de tags, etc.). Il possède des fonctionnalités basiques mais très pratiques telles que les raccourcis clavier et la sélection multiples d'objets à la souris.

[![balsamiq-mockups-for-desktop-new-mockup](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/balsamiq-mockups-for-desktop-new-mockup-300x224.png "Capture d")](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/balsamiq-mockups-for-desktop-new-mockup.png)
[![mockup](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/mockup-300x148.png "Exemple de wireframe avec Balsamiq Mockup")](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/mockup.png)

Il est possible de **grouper** les composants graphiques entre eux afin de les déplacer ensemble ou encore de les positionner l'un au dessus des autres, etc. Il est également possible d'inclure de véritables images, l'intégration au milieu de l'effet crayonné est étrange, mais peut s'avérer pratique dans le cadre d'un logo (cf. le cas pratique). Le logiciel inclut également **une série d'icônes**, dans un style crayonné, qui complète très bien certains manques de composants, notamment dans les boutons.

J'ai particulièrement apprécié dans le cadre d'un drag n' drop le clip des objets afin de les aligner de façon horizontale ou verticale. Avec un peu d'entraînement on peut presque se baser sur des grilles, très utiles en webdesign, ce qui permettrait plus tard de faire l'intégration avec un framework CSS, mais je m'avance, nous verrons ceci dans un futur article...

Le point fort de Balsamiq Mockup est son **rendu crayonné et monochrome** qui permet de le détacher du rendu final. En effet **le danger dans un wireframe est qu'un client l'imagine comme maquette définitive** ou encore qu'il s'attarde sur des problématiques graphiques qui ne seront vu qu'en étape suivante.

La version desktop est écrite en **Adobe AIR** ce qui lui confère l'avantage d'être multi-plateforme.

Balsamiq Mockup n'est pas complètement exempte de défauts, j'ai eu droit à quelques plantages avec plusieurs mockups ouverts et comme je le précise ci-dessus, il manque encore quelques composants graphiques, notamment sur les boutons.

Un autre défaut est qu'il ne permet pas de faire des liens entre prototypes. En ce sens, Balsamiq Mockup s'arrête au rang d'outil de création de prototypes "graphiques", il ne permet pas de réaliser des scénarios / séquences d'écrans, ou plus communément appelé user-story (cf. ci-dessus).

### 3. Cas pratique : Lexik

Vous avez la chance, via cet article, de voir les premiers wireframes du futur site de Lexik.fr :

[![lexik-home_2](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-home_2-226x300.png "Lexik - page d")](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-home_2.png)
[![lexik-listing2](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-listing2-205x300.png "Lexik - listing de pages sur la nouvelle version")](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-listing2.png)

[![lexik-listing3](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-listing3-207x300.png "Lexik - listing de pages sur la nouvelle version")](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-listing3.png)
[![lexik-page](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-page-226x300.png "Lexik - modèle de page sur la nouvelle version")](/images/archives/2009-07-27-balsamiq-mockup-et-les-wireframes-graphiques/lexik-page.png)

**Quelques liens :**

* [une présentation du zoning et des wireframes chez pixenjoy.com](http://www.pixenjoy.com/zoning-et-wireframe) ;
* [le user-story version frenchies](http://www.aubryconseil.com/post/2006/10/16/106-des-histoires-d-utilisateur) ;
* [présentation de quelques outils en ligne de conception de wireframes](http://www.superfiction.net/blog/index.php?2008/09/01/297-les-outils-online-de-conception-de-wireframes-introduction).

[lexik_blog]: http://devblog.lexik.fr/methodologie/balsamiq-mockup-et-les-wireframes-graphiques-805
