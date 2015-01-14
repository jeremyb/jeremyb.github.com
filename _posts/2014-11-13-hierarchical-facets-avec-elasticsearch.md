---
layout: post
title: Hierarchical facets avec Elasticsearch
excerpt:
    Elasticsearch est devenu un outil incontournable pour l'indexation de 
    documents et la recherche textuelle. Un des rares reproches qui pouvait lui 
    être fait il y a quelques mois était son absence de support des facets 
    hiérarchiques. Il s'agit en effet d'une fonctionnalité très utile et 
    demandée dans les sites e-commerce.
tags: [elasticsearch]
image:
  feature: slides/default.jpg
comments: true
share: true
---

[Cet article a été intialement publié sur le blog de Lexik][lexik_blog]
{: .alert .alert-warning}

[Elasticsearch](http://www.elasticsearch.org) est devenu un outil incontournable 
pour l'indexation de documents et la recherche textuelle. Un des rares reproches 
qui pouvait lui être fait il y a quelques mois était son absence de support des 
facets hiérarchiques. Il s'agit en effet d'une fonctionnalité très utile et 
demandée dans les sites e-commerce.

Pour ceux qui ne seraient pas familiers avec le vocabulaire des moteurs de 
recherche, une « facet » (ou recherche à facette en français) permet de 
regrouper des données sur des résultats de recherche. Elles sont calculées en 
temps réel et on les retrouve très souvent sur les catégories d'un site 
e-commerce. Les facets permettent par exemple de retrouver toutes les
catégories associées à des résultats de recherche, avec le nombre d'éléments
correspondants.

Les facets hiérarchiques sont basées sur le même système mais avec une notion de 
hiérarchie (de profondeur) supplémentaire. On voit cette technique sur des sites 
e-commerce très connus, comme Amazon.fr comme vous pouvez voir sur la capture 
d'écran suivante :

![Catégories sur Amazon](/images/2014-11-13-hierarchical-facets-avec-elasticsearch/amazon.png)
{: .pull-right}

Jusqu'à la version 1.0 d'Elasticsearch il était impossible de faire ce style de 
requête tandis que [Solr](http://lucene.apache.org/solr/) les proposait via ses 
[« Pivot Facets»](http://wiki.apache.org/solr/HierarchicalFaceting#Pivot_Facets). 
En réponse à ce manque et aux limitations des facets, l'équipe d'Elasticsearch a
introduit le concept d'agrégations. Outre le fait que le nom est beaucoup plus
explicite, les agrégations sont également beaucoup plus flexibles. Leurs 2 
atouts majeurs sont de pouvoir être définies en cascade (autrement dit de façon 
hiérarchique, une agrégation peut avoir une ou plusieurs sous-agrégations), et 
de pouvoir combiner différents types de filtre / groupe (comme des facets ou des
calculs de statistiques).

Nous allons maintenant voir comment utiliser ces agrégations, et notre cas
pratique sera un site e-commerce avec des catégories à plusieurs niveaux. Par
simplicité l'exemple ci-dessous sera illustré via le service en ligne [Play de
found.no](https://www.found.no/play/) qui permet de définir son schéma, ses
données et ses recherches Elasticsearch sur une instance publique. _(La
communication avec Elasticsearch se fait normalement en JSON, là où found.no a
choisi un format Yaml un peu plus lisible.)_

Supposons que nous ayons 3 produits, rangés dans 3 niveaux de catégories :

{% highlight yaml %}
_type: product
category_level0: Books
category_level1: Computers & Technology
category_level2: Network Programming
name: Pro AngularJS

---

_type: product
category_level0: Books
category_level1: Computers & Technology
category_level2: Online Searching
name: ElasticSearch Server Second Edition

---

_type: product
category_level0: Books
category_level1: Arts & Photography
category_level2: Photography & Video
name: Humans of New York
{% endhighlight %}

Source : [https://www.found.no/play/gist/c6fc7c11b8a4b5967008#documents](https
://www.found.no/play/gist/c6fc7c11b8a4b5967008#documents)

Le schéma Elasticsearch associé est le suivant :

{% highlight yaml %}
product:
    properties:
        category_level0:
            type: string
            index: not_analyzed
        category_level1:
            type: string
            index: not_analyzed
        category_level2:
            type: string
            index: not_analyzed
        name:
            type: string
{% endhighlight %}

Source : [https://www.found.no/play/gist/c6fc7c11b8a4b5967008#mappings](https:
//www.found.no/play/gist/c6fc7c11b8a4b5967008#mappings)

On choisi de ne pas analyser les catégories pour qu'elles soient indexées
strictement comme spécifié. Elles ne seront donc pas optimisées pour être
retrouvées via un moteur de recherche mais le seront pour nos agrégations.

Nous avons vu que les agrégations peuvent être définies en cascade, nous allons 
donc définir une agrégation sur le terme de la catégorie de 1er niveau et ainsi 
de suite jusqu'au niveau 3 :

{% highlight yaml %}
size: 0

aggregations:
    category:
        terms:
            field: category_level0
        aggs:
            level1:
                terms:
                    field: category_level1
                aggs:
                    level2:
                        terms:
                            field: category_level2
{% endhighlight %}

Source : [https://www.found.no/play/gist/c6fc7c11b8a4b5967008#search](https://
www.found.no/play/gist/c6fc7c11b8a4b5967008#search)

Avec cette recherche, Elasticsearch va être capable de nous agréger les 
résultats des 3 produits sur les 3 niveaux de catégories :

{% highlight yaml %}
aggregations:
  category:
    buckets:
      -
        key: "Books"
        doc_count: 3
        level1:
          buckets:
            -
              key: "Computers & Technology"
              doc_count: 2
              level2:
                buckets:
                  -
                    key: "Network Programming"
                    doc_count: 1
                  -
                    key: "Online Searching"
                    doc_count: 1
            -
              key: "Arts & Photography"
              doc_count: 1
              level2:
                buckets:
                  -
                    key: "Photography & Video"
                    doc_count: 1
{% endhighlight %}

Avec ces données, nous allons facilement pouvoir afficher une liste de ce type :

    - Books (3)
        - Computers & Technology (2)
            - Network Programming (1)
            - Online Searching (1)
        - Arts & Photography (1)
            - Photography & Video (1)


Pour aller plus loin avec les agrégations d'Elasticsearch je vous recommande les 
2 lectures suivantes :

* <https://www.found.no/foundation/elasticsearch-aggregations/>
* <http://obtao.com/blog/2014/10/elasticsearch-et-symfony-statistiques-avec-les-aggregations/>

[lexik_blog]: http://devblog.lexik.fr/symfony2/hierarchical-facets-avec-elasticsearch-2762
