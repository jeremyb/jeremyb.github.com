## Ne laissez pas les formulaires Symfony influencer votre modèle

<!-- .element: class="right" -->
![talkspirit](images/talkspirit-logo.png)

#### Meetup Symfony Montpellier (Octobre 2016)

#### [Jeremy Barthe][site]

[site]: http://jeremybarthe.com/
[talkspirit]: https://www.talkspirit.com/

---

## Form component

<ul class="multicolumns">
    <li>FormBuilder</li>
    <li>FormView</li>
    <li>handleRequest()</li>
    <li>Validation</li>
    <li>Validation Groups</li>
    <li>Form collections</li>
    <li>Embedded Forms</li>
    <li>Form events</li>
    <li>DataTransformer</li>
    <li>File uploads</li>
    <li>Creating new field types</li>
    <li>Rendering a Form in Twig</li>
    <li>Form errors</li>
    <li>Form themes</li>
    <li>Form translations</li>
    <li>etc.</li>
</ul>

---

## Quelques rappels

---

### Un exemple de modèle

    class User
    {
        /**
         * @Assert\NotBlank()
         * @Assert\Email()
         */
        private $email;

        /**
         * @Assert\NotBlank()
         */
        private $password;

        /** @var \DateTimeImmutable */
        private $createdAt;

        public function __construct()
        {
            $this->createdAt = new \DateTimeImmutable();
        }

        // getters / setters
    }

---

### Un exemple de formulaire

    class UserType extends AbstractType
    {
        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('email', EmailType::class)
                ->add('password', PasswordType::class);
        }

        public function configureOptions(OptionsResolver $resolver)
        {
            $resolver->setDefaults([
                'data_class' => User::class,
            ]);
        }
    }

---

### Un exemple de controller

    public function registrationAction(Request $request)
    {
        $user = new User();

        $form = $this->createForm(UserType::class, $user);
        $form->add('submit', SubmitType::class);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            dump($user); exit;
        }

        return [
            'form' => $form->createView(),
        ];
    }

---

![UserType](images/usertype.png)

![UserType result](images/usertype-result.png)

---

### Les besoins évoluent...

* On ajoute un profil utilisateur
* On ajoute une authentification OAuth
* On ajoute une administration des utilisateurs
* etc.

---

### Les besoins évoluent...

* On introduit de nouveaux **validation groups**<br>
  (Registration, Profile, ResetPassword, ChangePassword, etc.)
* On ajoute un **DataTransformer** pour traiter un autocomplete
* On s'essaye aux **FormEvents** pour rajouter de nouveaux champs
* On ajoute nombreux **getters et setters**<br>
  (même des setCreatedAt())

---

### Jusqu'au jour où...

![UserType failed](images/usertype-failed.png)
<!-- .element: class="fragment" -->

Il manque un groupe sur un @Assert\NotBlank() :-)
<!-- .element: class="fragment" -->

---

### Ou encore...

![UserType failed](images/usertype-failed2.png)

---

## Tout reprendre à zéro

Est-ce que ce modèle a pour vocation de n'être utilisé que par ce(s) formulaire(s) ?
<!-- .element: class="fragment" -->

---

### Tout reprendre à zéro

* Réfléchir en premier au Domain Model (Entity / Value Object)
* Les entités devraient toujours être dans un état valide
* Paramètres obligatoires dans le constructeur
* Nom de méthode parlante (liée au domaine de l'application - Ubiquitous Language)

---

### Ubiquitous Language

* Langage commun entre le business et les développeurs
* Le code doit refléter le langage du métier, son vocabulaire, ses termes spécifiques, etc.

---

#### Penser le modèle en fonction du Ubiquitous Language

    final class User
    {
        /** @var string */
        private $email;
        /** @var string */
        private $password;
        /** @var \DateTimeImmutable */
        private $createdAt;

        public static function register($email, $password)
        {
            $user = new self();
            $user->email = $email;
            $user->password = $password;

            return $user;
        }

        private function __construct()
        {
            $this->createdAt = new \DateTimeImmutable();
        }

        // getters
    }

---

#### Penser le modèle en fonction du Ubiquitous Language

    final class User
    {
        // ...

        /** @var PersonalInformation */
        private $personalInformation;

        // ...

        public function complete(PersonalInformation $personalInformation)
        {
            $this->personalInformation = $personalInformation;
        }
    }

---

### Un formulaire représente une action

#### L'action est de s'inscrire

---

## Data Transfer Object (DTO)

* Un DTO a pour but de simplifier les échanges de données
* C'est un objet simpliste (POPO)

---

#### Inscription - DTO / Command

    final class RegistrationCommand
    {
        /**
         * @Assert\NotBlank()
         * @Assert\Email()
         */
        public $email;
    
        /**
         * @Assert\NotBlank()
         */
        public $password;
    }

---

#### Inscription - Formulaire

    final class RegistrationType extends AbstractType
    {
        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('email', EmailType::class)
                ->add('password', PasswordType::class);
        }

        public function configureOptions(OptionsResolver $resolver)
        {
            $resolver->setDefaults([
                'data_class' => RegistrationCommand::class,
            ]);
        }
    }

---

#### Inscription - Traitement du DTO / Command

    final class RegistrationHandler
    {
        /** @var UserRepository */
        private $repository;
    
        public function __construct(UserRepository $repository) {
            $this->repository = $repository;
        }
    
        public function handle(RegistrationCommand $command) {
            $user = User::register(
                $command->email,
                $command->password
            );
            $this->repository->add($user);
    
            return $user;
        }
    }

---

#### Inscription - Controller

    public function registrationAction(Request $request)
    {
        $form = $this->createForm(RegistrationType::class);
        $form->add('submit', SubmitType::class);

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $user = $this->get('app.registration_handler')->handle(
                $form->getData()
            );
            dump($user); exit;
        }

        return [
            'form' => $form->createView(),
        ];
    }

---

## Inscription - Unicité de l'email

---

### Inscription - Unicité de l'email

* Vous penser à `@UniqueEntity("email")` ?
* C'est retomber dans un couplage fort entre votre modèle et les formulaires et ses validations
* Le domaine métier peut se charger de cette validation

---

### Où traiter les validations dans ce modèle ?

Pour aller plus loin<br>
[Form, Command, and Model Validation][form-command-model-validation]<br>
par [@mathiasverraes][mathiasverraes].

[form-command-model-validation]: http://verraes.net/2015/02/form-command-model-validation/
[mathiasverraes]: https://twitter.com/mathiasverraes

---

### Inscription - Unicité de l'email

    final class RegistrationHandler
    {
        // ...
    
        public function handle(RegistrationCommand $command)
        {
            if (null !== $this->repository->findOneByEmail($command->email)) {
                throw new EmailAlreadyExists();
            }
    
            $user = User::register(
                $command->email,
                $command->password
            );
            $this->repository->add($user);
    
            return $user;
        }
    }

---

### Inscription - Unicité de l'email

    public function registrationAction(Request $request)
    {
        // ...

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $user = $this->get('app.registration_handler')->handle(
                    $form->getData()
                );
                dump($user); exit;
            } catch (EmailAlreadyExists $e) {
                $form->get('email')->addError(
                    new FormError('Email is already registered')
                );
            }
        }

        // ...
    }

---

## Mapping personnalisé

---

### Mapping par défaut

* Implémentation standard `PropertyPathMapper` (utilisation du composant PropertyAccess)

---

### `empty_data`

* Permet de construire un objet comme on le souhaite
* Donc on peut passer des paramètres au constructeur
* Impossible d'éditer un objet

---

### Très pratique pour les Value Objects

* Un Value Object est Immutable
* A chaque fois que l'on veut changer l'objet on en crée un nouveau

Pour aller plus loin<br>
[Mets du Value Object dans ton modèle][value-object-slides]<br>
par [@damienalexandre][damienalexandre].

[value-object-slides]: https://jolicode.github.io/value-object-conf/slides/index.html
[damienalexandre]: https://twitter.com/damienalexandre

---

### Exemple avec `empty_data`

---

### Value Object Customer

    class CustomerType extends AbstractType
    {
        public function configureOptions(OptionsResolver $resolver)
        {
            $resolver->setDefaults([
                'data_class' => Customer::class,
                'empty_data' => function (FormInterface $form) {
                    return new Customer(
                        $form->get('name')->getData(),
                        $form->get('address')->getData()
                    );
                },
            ]);
        }

        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('name', TextType::class)
                ->add('address', AddressType::class);
        }
    }

---

### Value Object Address

    class AddressType extends AbstractType
    {
        public function configureOptions(OptionsResolver $resolver)
        {
            $resolver->setDefaults([
                'data_class' => Address::class,
                'empty_data' => function (FormInterface $form) {
                    return new Address(
                        $form->get('street')->getData(),
                        $form->get('postalCode')->getData(),
                        $form->get('locality')->getData()
                    );
                },
            ]);
        }

        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('street', TextType::class)
                ->add('postalCode', TextType::class)
                ->add('locality', TextType::class);
        }
    }

---

### Value Object Customer

![Form workflow](images/customertype-result.png)

---

### Attention aux validations

![Form workflow](images/form-workflow.png)

---

### Attention aux validations

* `FormEvents::PRE_SUBMIT`
* `empty_data`
* `DataMapper`
* `FormEvents::SUBMIT`
* `ModelTransformer`
* `FormEvents::POST_SUBMIT`
  * `ValidationListener`

---

### Attention aux validations

Si vous basez la création de vos **Value Objects** via `empty_data` ou un
`DataMapper` gardez à l'esprit que cette création va se faire **avant l'exécution
des validations**.

---

### `DataMapperInterface`

* Le `DataMapper` permet faire le mapping entre le formulaire et le modèle et inversement

---

### Exemple avec `DataMapperInterface`

---

### Value Object Username

    final class Username
    {
        const MIN_LENGTH = 5;
        const FORMAT = '/^[a-zA-Z0-9_]+$/';

        /** @var string */
        private $username;

        public function __construct($username)
        {
            Assert::notEmpty($username, 'The username should not be blank.');
            Assert::minLength($username, self::MIN_LENGTH, 'The username should contains at least %2$s characters.');
            Assert::regex($username, self::FORMAT, 'The username is invalid.');

            $this->username = $username;
        }

        public function getUsername()
        {
            return $this->username;
        }
    }

---

### Value Object Username

    class UsernameType extends AbstractType implements DataMapperInterface
    {
        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('username', TextType::class)
                ->setDataMapper($this);
        }

        // ...
    }

---

### Value Object Username

    class UsernameType extends AbstractType implements DataMapperInterface
    {
        // ...

        public function mapDataToForms($data, $forms)
        {
            $forms = iterator_to_array($forms);

            $forms['username']->setData(
                null !== $data ? $data->getUsername() : null
            );
        }

        // ...
    }

---

### Value Object Username

    class UsernameType extends AbstractType implements DataMapperInterface
    {
        // ...

        public function mapFormsToData($forms, &$data)
        {
            $forms = iterator_to_array($forms);

            try {
                $data = new Username($forms['username']->getData());
            } catch (\InvalidArgumentException $e) {
                $error = new FormError($e->getMessage());
                $forms['username']->addError($error);
            }
        }

        // ...
    }

---

### Value Object Username

    class UsernameType extends AbstractType implements DataMapperInterface
    {
        // ...

        public function configureOptions(OptionsResolver $resolver)
        {
            $resolver->setDefaults([
                'data_class' => Username::class,
                'empty_data' => null,
            ]);
        }
    }

---

### Value Object Username

![Username form](images/usernametype-form.png)

---

### Domain-Driven Design in PHP

![DDD in PHP book](images/ddd-in-php.png)

https://leanpub.com/ddd-in-php

---

Slides/post intéressants by [@webmozart][webmozart] :

* [Symfony2 Forms: Do's and Don'ts][webmozart-symfony2-forms]
* [Symfony Forms 101][webmozart-symfony-forms-101]
* [Value Objects in Symfony forms][value-objects-in-symfony-forms]
* https://github.com/webmozart/symfony-forms-workshop-websc16

[webmozart]: https://twitter.com/webmozart
[webmozart-symfony2-forms]: https://speakerdeck.com/webmozart/symfony2-forms-dos-and-donts
[webmozart-symfony-forms-101]: https://speakerdeck.com/webmozart/symfony-forms-101
[value-objects-in-symfony-forms]: https://webmozart.io/blog/2015/09/09/value-objects-in-symfony-forms/

---

## Merci !

### Questions ?

[jeremybarthe.com][site] - [Twitter][twitter] - [Github][github]

[site]: http://jeremybarthe.com/
[twitter]: https://twitter.com/jeremyb_
[github]: https://github.com/jeremyb
