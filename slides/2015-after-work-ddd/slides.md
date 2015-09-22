ORM & DDD
=========

#### cas pratique avec Doctrine

<!-- .element: class="small" -->
Meetup After Work DDD - Septembre 2015
<br>
[Jeremy Barthe][site] - [KNP Labs][knplabs]

[site]: http://jeremybarthe.com/
[knplabs]: http://knplabs.com/

---

## ORM

> Un mapping objet-relationnel (en anglais object-relational mapping ou ORM) est 
> une technique de programmation informatique qui crée l'illusion d'une base de 
> données orientée objet à partir d'une base de données relationnelle en 
> définissant des correspondances entre cette base de données et les objets du 
> langage utilisé. (cf. Wikipedia)
<!-- .element: class="fragment small" -->

---

### Exemple

Database :

    +----+----------+------------+
    | id | username | first_name |
    +----+----------+------------+
    | 1  | jeremyb  | Jeremy     |
    +----+----------+------------+

PHP :

    $user->getId()
    $user->getUsername()
    $user->getFirstName()

---

### Différences entre ActiveRecord et DataMapper

Lequel est le plus adapté dans un contexte DDD.

---

### Active Record

    $user = new User('jeremyb');
    $user->save();

### Data Mapper

    $user = new User('jeremyb');
    $objectManager->persist($user);

---

### Active Record

Avantages

- Rapide à mettre en place, pratique pour du RAD
- Orienté CRUD

Inconvénients

- Couplage fort entre la structure de la base et l'objet
- Violation d'un principe SOLID (Single Responsibility Principle)
- Impose fréquemment d'hériter d'une classe de l'ORM

---

### Data Mapper

Avantages

- Séparation claire entre l'objet et sa persistence
- Liberté dans la construction du modèle

Inconvénients

- Plus complexe à mettre en place

---

### Exemple avec Doctrine

    /**
     * @Entity @Table(name="posts")
     **/
    final class Post {
        /** @Id @Column(type="integer") @GeneratedValue */
        private $id;

        /** @Column(type="string", nullable=false) */
        private $title;

        /** @Column(type="string", nullable=false) */
        private $content;

        public function __construct($title, $content) {
            $this->title = $title;
            $this->content = $content;
        }

        public function getId() {
            return $this->id;
        }

        public function getTitle() {
            return $this->title;
        }

        public function getContent() {
            return $this->content;
        }
    }

---

### Exemple avec Doctrine

    $product = new Product('First post', 'lorem ipsum...');
    
    $entityManager->persist($product);
    $entityManager->flush($product);

---

## Scénario Gherkin

    Scenario: Getting some blog posts published
      Given a draft blog post titled "First post" was written
      When I publish "First post" blog post
      Then the "First post" blog post should be published

---

### Adaptons le modèle au scénario

    final class Post {
        // ...

        public static function write($title, $content) {
            return new self($title, $content);
        }

        private function __construct($title, $content) {
            $this->title = $title;
            $this->content = $content;
        }

        // ...
    }

---

## Value Objects

- Immutable
- Capacité de validation
- Test sur l'égalité
- Exemple : identifiant, prix, localisation, etc.

---

### Cas pratique avec un statut

    final class Post {
        const STATUS_DRAFT = 10;
        const STATUS_PUBLISHED = 20;

        // ...

        /** @Column(type="string", nullable=false) **/
        private $status;

        public static function write($title, $content) {
            return new self($title, $content);
        }

        private function __construct($title, $content) {
            $this->title = $title;
            $this->content = $content;
            $this->status = self::STATUS_DRAFT;
        }
    }

---

### Le statut est un bon candidat pour être un Value Object

    final class Status {
        const DRAFT = 10;
        const PUBLISHED = 20;

        private $status;

        public static function published() {
            return new self(self::PUBLISHED);
        }

        public static function draft() {
            return new self(self::DRAFT);
        }

        private function __construct($status) {
            $this->status = $status;
        }

        public function equals(self $anStatus) {
            return $this->status === $anStatus->status;
        }
    }

---

### Cas pratique avec un statut

    final class Post {
        // ...

        /** @Embedded(class="Status") */
        private $status;

        private function __construct($title, $content) {
            // ...
            $this->status = Status::draft();
        }
    }

    Status:
        type: embeddable
        fields:
            status: { type: string }

---

### Parenthèse par rapport à votre modèle

- Nous avons de mauvaises habitudes avec Doctrine
- Nous sommes fainéants :)

<p />

- Génération de code :
- `php bin/doctrine orm:generate:entities`
- `php app/console doctrine:generate:entity`

<!-- .element: class="fragment" -->

---

### Parenthèse par rapport à votre modèle

- Les propriétés obligatoires de votre modèle devraient se trouver dans le 
  constructeur


- Eviter les setters inutiles / voire supprimer tous les setters
- Utiliser plutôt des méthodes qui ont du sens (Ubiquitous Language)

<!-- .element: class="fragment" -->

---

### Parenthèse par rapport à votre modèle

    // 1.
    $post->setStatus(Status::published());
    $post->setPublishedAt(new \DateTime());

    // 2.
    $post->publish();

---

## Repository

- Le repository manipule une collection d'objets
- Abstraction de la manipulation de la persistence des objets
- Plusieurs implémentations possibles

---

### Interface du repository

    interface PostRepository {
        public function add(Post $post);
        public function remove(Post $post);
        public function getById($id);
        public function getPublishedPosts();
        public function getDraftPosts();
    }

---

### Repository Doctrine (écriture)

    final class DoctrinePostRepository implements PostRepository {
        private $em;

        public function __construct(EntityManager $em) {
            $this->em = $em;
        }

        public function add(Post $post) {
            $this->em->persist($post);
        }

        public function remove(Post $post) {
            $this->em->remove($post);
        }

        // ...
    }

---

### Repository "en mémoire"

    final class InMemoryPostRepository implements PostRepository {
        private $posts = [];

        public function add(Post $post) {
            $this->posts[$post->getId()] = $post;
        }

        public function remove(Post $post) {
            unset($this->posts[$post->getId()]);
        }

        // ...
    }

---

### Repository Doctrine (lecture)

    final class DoctrinePostRepository implements PostRepository {
        // ...

        public function getById($id) {
            $post = $this->em
                ->getRepository(Post::class)
                ->find($id);

            if (null === $post) {
                throw new EntityNotFoundException();
                // ou mieux :
                // throw new PostNotFound($id);
            }

            return $post;
        }

        // ...
    }

---

### Repository (bonus avec les tests)

    class PostTest extends PHPUnit_Framework_TestCase {
        /**
         * @test
         */
        public function some_assertions_about_posts() {
            $repository = $this->prophesize('UserRepository');

            $repository
                ->getById(1)
                ->shouldBeCalled()
                ->willReturn(new Post(/* ... */));

            $repository
                ->add(Argument::type('Post'))
                ->shouldBeCalled();

            $repository->reveal();
            // que vous pouvez injecter dans une classe service
        }
    }

---

## Specification

    class PublishedPostSpecification implements Specification {
        public function match(QueryBuilder $qb) {
            $qb
                ->andWhere('p.status.status', Status::PUBLISHED)
                ->orderBy('p.publishedAt', 'DESC');

            // etc.
        }
    }

    final class DoctrinePostRepository implements PostRepository {
        // ...

        public function match(Specification $specification) {
            $qb = $this->em
                ->getRepository(Post::class)
                ->createQueryBuilder('p');

            $specification->match($qb);

            return $qb->getQuery()->getResult();
        }

        // ...
    }
    

---

## Domain events

- Evitez d'utiliser les événements Doctrine pour déclencher des actions métiers
- Les Domain Events sont là pour ça (exemple : PostWasCreated, PostWasPublished)

---

## Merci !

### Questions ?

[jeremybarthe.com][site] - [Twitter][twitter] - [Github][github]

[site]: http://jeremybarthe.com/
[twitter]: https://twitter.com/jeremyb_
[github]: https://github.com/jeremyb
