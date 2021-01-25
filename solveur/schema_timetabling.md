# Schéma de modélisation de problèmes d'emploi du temps universitaires
Version 1.1 - 14 septembre 2020
LERIA


## Préambule
Le calcul d'emploi du temps universitaire est un problème multiforme qui admet de nombreuses variantes selon les pays et les institutions. De manière générale, il peut être modélisé comme un problème d'optimisation combinatoire et la compétition ITC 2019 propose à cet effet un schéma XML permettant d'en représenter données et solutions. La compétition cible précisément la classe de problèmes qui incorporent des contraintes d'ordonnancement non-préemptif sur des séances de durées quelconques et pouvant se chevaucher.

Nous rappelons dans ce document les éléments du schéma ITC et présentons les concepts afférents. Nous montrons aussi comment y représenter les problèmes dont l'objectif est de placer des séances d'enseignement de même durée sur une grille de créneaux quotidiens. Cette classe de problèmes présente un double intérêt. D'une part, elle cadre avec le mode de fonctionnement de nombreux établissements français. D'autre part, le problème d'optimisation sous-jacent se ramène à un problème d'affectation qui diffère des problèmes d'ordonnancement en termes de modélisation et de techniques de résolution.

La représentation de ces problèmes dans le schéma ITC exige de réinterpréter certains attributs du schéma en adoptant de nouvelles plages de valeurs. Nous documentons les adaptations apportées pour les attributs concernés dans les différentes sections (sous-sections intitulées *Adaptation UA*). Nous concluons en présentant une modélisation du schéma ITC dans le langage Minizinc qui permet de décrire et résoudre des instances en s'appuyant sur des solveurs de programmation par contraintes.




## Concepts

### Horizon temporel
La confection d'un emploi du temps (edt) repose sur la donnée préalable d'un horizon temporel de planification. Le schéma ITC en propose une représentation fondée sur trois échelles de temps : semaines, journées et créneaux horaires. L'horizon d'une instance ITC se définit précisément par un nombre de semaines `nrWeeks`, un nombre de journées par semaine `nrDays`, et un nombre de créneaux horaires par jour `nrSlotsPerDay`. 

Les créneaux horaires sont supposés être de même durée et diviser sans chevauchement la plage de 24 heures. La durée nominale des créneaux est implicite dans le schéma puisqu'elle se déduit de l'attribut `nrSlotsPerDay`. La grille de créneaux discrétisant l'horizon de temps sert à cadencer le démarrage des activités planifiées (séances d'enseignement, trajets entre séances, pauses entre séances). La durée de toute activité se mesure donc en nombre de créneaux, qu'elle soit prédéfinie dans l'instance (durée de séance, temps de trajet) ou propre à l'edt calculé (temps de pause).

Le schéma ITC n'impose aucune restriction sur la durée des séances, ni n'impose qu'elles soient synchrones dans un edt. Seule la non-préemption est requise, i.e. aucune séance ne peut être scindée. Dans le cas général, les séances d'une instance ITC seront donc de durée variable et pourront se chevaucher dans l'edt calculé sans nécessairement coïncider. Le calcul d'emploi du temps ainsi posé se ramène à la résolution d'un problème d'ordonnancement non-préemptif qui est un problème classique (et difficile) du domaine de l'optimisation combinatoire sous contraintes.

##### Adaptation UA
La flexibilité du schéma ITC permet de se restreindre à des séances de même durée et d'imposer qu'elles soient programmées de manière synchrone sur l'horizon de temps. Ce cadre opérationnel est celui que l'on rencontre dans les établissements français (universités, lycées et collèges) où les séances sont ''plaquées'' sur une grille quotidienne de créneaux d'enseignement. Le calcul d'edt se ramène alors à un problème combinatoire d'affectation et non plus d'ordonnancement puisqu'il s'agit d'attribuer un unique créneau à chaque séance.

Afin de modéliser correctement cette classe de problèmes sans déroger au schéma ITC, nous proposons une ré-interprétation de la notion de créneau. Précisément, les créneaux sont censés modéliser des créneaux d'enseignement et non plus des tranches horaires divisant la journée de 24 heures. Nous supposons toujours une durée nominale (e.g.  80 minutes par créneau d'enseignement) mais ne supposons plus que les créneaux consécutifs soient contigus (e.g. créneaux 8h-9h20 et 9h30-10h50) ni donc ne recouvrent 24 heures (e.g. premier créneau 8h-9h20, dernier créneau 17h-18h20). La journée-type ainsi définie caractérise implicitement un programme de pauses quotidiennes où chaque pause correspond au laps de temps entre deux créneaux consécutifs. Pour plus de flexibilité, nous n'imposons aucun cadrage sur la durée des pauses. Elles peuvent notamment être de durées différentes (e.g. pauses matinales de 10 minutes vs. pauses méridiennes d'1 heure).

Ce choix d'interprétation du schéma ITC a plusieurs conséquences. Tout d'abord, la seule donnée du nombre de créneaux quotidiens d'enseignement `nrSlotsPerDay` ne suffit plus à en déduire leurs dates de début ou de fin et à fortiori la durée nominale. Il en va de même pour les pauses quotidiennes dont durées et dates restent inconnues. Le créneau ne fait donc plus sens en tant qu'unité de mesure des durées d'activités extra-pédagogiques (e.g. temps de trajet entre salles ou temps de pause entre séances). Nous présentons dans les sections suivantes une ré-interprétation de certains des attributs du schéma ITC qui correspondent à des durées.

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
Durée nominale (de créneau) | *standard (slot) duration* | la durée nominale des créneaux | 80 minutes
Créneau-type | *daily slot* | une tranche horaire d'enseignement quotidien de durée nominale | 8h-9h20
Journée-type | *weekday* | une énumération chronologique de créneaux-type ne se chevauchant pas | (8h-9h20, 9h30-10h50, ..., 17h-18h20)
Semaine-type | *workweek* | une énumération chronologique de journées-type | (lundi, ..., vendredi)
Horizon | *horizon* | un nombre de semaines-type associé au nombre de journées-type dans la semaine-type et au nombre de créneaux-type dans la journée-type | 10 semaines-type à 5 journées-type/semaine et 8 créneaux-type/jour
Semaine | *week* | une des semaines-type que recouvre l'horizon | semaine 9
Jour | *day* | une des journées-type que recouvre l'horizon | jour 8
Créneau | *slot* | un des créneaux-type que recouvre l'horizon | créneau 350

### Programmes
La confection d'un emploi du temps doit tenir compte des plages de fermetures programmées pour les salles et des plages d'enseignement programmées pour les classes.[^f-teacher] Le schéma ITC introduit deux types d'éléments à cet effet : `unavailable` pour les salles, `time` pour les classes. Un élément `unavailable` représente un programme de fermeture pour une salle, une même salle pouvant cumuler plusieurs programmes. Un élément `time` représente un programme d'enseignement pour une classe, plusieurs programmes alternatifs pouvant être associés à une même classe.

[^f-teacher]: L'indisponibilité des enseignants est aussi à prendre compte mais ne peut qu'être modélisée indirectement dans une instance ITC (cf. section *Cours*), les notions d'enseignant et d'agenda personnel n'étant pas réifiées.


Dans le schéma ITC, un *programme* modélise la récurrence d'une plage horaire sur certains jours de la semaine et sur certaines semaines de l'horizon. Formellement, les éléments `unavailable` et `time` sont dotés d'un quadruplet d'attributs - `weeks`, `days`, `start` et `length` - qui dénotent respectivement les semaines de programmation, les journées-type de programmation, le créneau-type de démarrage de la plage et sa durée. Par exemple, sur un horizon à 10 semaines, 5 jours/semaines et 5 minutes/créneau, un programme  `weeks="0101010101",days="10010",start="96",length="12"` représente toutes les plages d'1 heure  (12\*5 minutes) démarrant à 8h (96\*5 minutes à partir de 0h00) les premiers et quatrièmes jours des semaines de rang pair.

##### Adaptation UA
Dans le schéma ITC, la durée des plages peut varier selon les classes. Comme évoqué plus haut, notre approche impose que toute séance d'enseignement soit de durée nominale. Autrement dit, on impose la contrainte `length=1` pour tous les éléments `time`.[^f-prog] A noter que notre approche ne permet plus d'inférer d'horaire de départ à partir des éléments `start` (e.g. 8h dans l'exemple) puisqu'ils ne dénotent que le rang d'un créneau d'enseignement dans la journée-type.

[^f-prog]: Tout programme construit sur une plage de $n$ créneaux consécutifs se décompose en $n$ programmes construit sur des plages ''nominales'' (i.e. de durée égale à la durée nominale des créneaux). On peut ainsi reformuler toute instance ITC sans perte d'informations, et en préservant la conformité au schéma, afin de satisfaire à l'exigence de programmes uniquement construits sur des séances nominales. Dans le cas des fermetures de salle, il suffit de remplacer dans l'instance ITC tout programme non-nominal (élément `unavailable`) par les programmes résultant de sa décomposition. Dans le cas des enseignements, on peut, modulo l'introduction de classes supplémentaires et de contraintes de consécutivité entre classes, reformuler un programme `time` en associant un programme de sa décomposition à chacune des classes introduites.

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
Semaines de programmation | *scheduled weeks* | un sous-ensemble non-vide de semaines de l'horizon | {2,4,6,8,10}
Journées de programmation | *scheduled days* | un sous-ensemble non-vide de la semaine-type | {lundi,jeudi}
Créneau de programmation   | *scheduled slot* | un créneau de la journée-type | 8h-9h20
Durée de programmation   | *scheduled duration* | une durée quotidienne mesurée en nombre de créneaux-type (supposée égale à 1 dans notre approche) | 1
Programme | *schedule* | plage périodique (supposée de durée nominale dans notre approche) représentée par un quadruplet associant ses semaines de programmation, ses journées de programmation, son créneau de programmation et sa durée de programmation  | <{2,4,6,8,10},{lundi,jeudi},11h-12h20,1> représente le créneau 11h-12h20 des lundis et jeudis des semaines de rang pair sur un horizon à 10 semaines


### Cours
Nous adoptons la modélisation du schéma ITC pour représenter et structurer les enseignements :
- L'instance comporte un catalogue de cours (l'élément `courses`).
- Un ou plusieurs cours (éléments `course`) peuvent être spécifiés dans le catalogue.
- Une ou plusieurs configurations (éléments `configuration`) peuvent être spécifiées par cours.
- Une ou plusieurs classes-type (éléments `subparts`) peuvent être spécifiées par configuration.
- Une ou plusieurs classes (éléments `classes`) peuvent être spécifiées par classe-type.
- Certaines classes entretiennent une relation de parenté (attribut `parent`) ce qui signifie que l'effectif de la classe fille doit être intégré à celui de la classe mère.[^f-parent]
- A chaque classe est attribué un effectif maximum d'étudiants (attribut `limit`), une liste de salles autorisées[^f-salle-e] (sous-éléments `room`), et un ou plusieurs programmes alternatifs de cours (sous-éléments `time`).
 
La notion de catalogue permet de modéliser toute maquette recouvrant les cours d'un ou plusieurs cursus (e.g., un parcours, une filière, un niveau, les filières d'une faculté). La notion de cours fait quant à elle référence à une matière enseignée et peut être assimilée à celle d'élément constitutif d'une unité d'enseignement. On peut y englober d'autres éléments pédagogiques tels les dispositifs d'accompagnement (e.g. tutorat, conférence) et d'évaluation (e.g., examens, soutenances). La notion peut aussi être détournée pour modéliser les périodes chômées d'un calendrier[^f-general] ou les absences du personnel enseignant.[^f-agenda]

Les configurations d'un cours correspondent à ses mises en oeuvre possibles (e.g. CM et TP vs. CM et projet). Chaque classe-type est constitutive d'une configuration et modélise une modalité pédagogique particulière dans l'enseignement d'un cours (e.g. CM, TD ou TP). Les classes-type peuvent aussi modéliser une décomposition chronologique  (e.g. seconde session hebdomadaire de TP, deuxième CC). Les classes affinent quant à elles la notion de classe-type en y intégrant la notion d'effectif de groupe. A noter qu'une classe peut n'avoir aucune salle déclarée (l'attribut optionel `room`de l'élément correspondant doit alors être défini avec la valeur `false`). On peut ainsi modéliser des classes virtuelles d'EAD sans limite de capacité ou des classes fictives correspondant à des absences ou des créneaux chômés.

[^f-parent]: La relation de parenté se limite au périmètre des classes d'une même configuration et est supposée acyclique.
[^f-salle-e]: Ces listes compilent les contraintes d'incompatibilité entre salles et classes, qu'elles soient matérielles (e.g. équipements insuffisants) ou administratives (e.g. salle réservée à un département d'enseignement).
[^f-general]: Les créneaux qui coïncident avec une fermeture pédagogique exceptionnelle en cours de journée ou de semaine d'enseignement (portes ouvertes, salon, jour férié, journée de vacances, etc) ne peuvent pas être supprimés de l'horizon de temps tel qu'il est représenté. Pour les prendre en compte, il suffit de pré-traiter l'instance ITC en supprimant les programmations de classes qui chevauchent ces créneaux. Alternativement, on peut simuler des séances ''chômées'' en modélisant dans le catalogue des cours fictifs programmés sur ces créneaux. Dans le cas particulier où une semaine est intégralement ''chômée'' (semaine de vacances, semaine d'examens, etc), elle peut être omise de l'horizon de temps puisqu'aucune hypothèse n'est faite sur la consécutivité des semaines de l'horizon relativement au calendrier universitaire.
[^f-agenda]: Les périodes d'indisponibilité du personnel enseignant peuvent être pré-compilées si l'affectation des classes aux enseignants est connue au préalable : il suffit pour chaque classe de supprimer tout programme comportant une séance où l'enseignant est absent. Alternativement, on peut associer à chaque enseignant des classes fictives représentant son agenda et imposer des contraintes de non-simultanéité avec les classes qu'il dispense.

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
Catalogue | *catalog* | un ensemble de cours constitutifs d'unité d'enseignement ou d'accompagnement (UEA) | cours des filières de licence 1 d'une université
Cours | *course* | un élément pédagogique d'UEA | Tutorat, *S1_UE3_Algorithmique_1*
Configuration | *configuration* | une décomposition possible de cours en classes-type | *<CM,TD,TP>*, *<CM,Projet>*
Classe-type | ** | un ensemble de classes d'une même configuration de cours caractérisées par les mêmes modalités pédagogiques | cours magistral (CM), second cours magistral hebdomadaire, travaux dirigés (TD), CM et TD intégrés, travaux pratiques (TP), projet, tutorat, entretien individuel, conférence, TP noté, contrôle continu (CC), CC commun (CCC), soutenance
Classe | *class* | une classe dont les séances sont dispensées par le même enseignant, au même groupe d'étudiants, et dans la même salle | *Algo_CM_1*, *Algo_TD_3B*
Classe parente | *parent class* | classe dont l'effectif recouvre celui de la dite classe | l'effectif de la classe *Algo_TP_2B* doit être intégré à celui de la classe *Algo_CM_2*
Séance de classe | *class slot* | l'affectation d'un créneau de l'horizon à une classe | 
Programme de cours | *class schedule* | un programme possible de séances pour une classe | 1^er^ créneau les jours 3 et 5 des semaines 2 à 9
Effectif maximum de classe | *class headcount limit* | le seuil d'effectif maximum pour une classe | `80` pour `Algo_CM_3`, `40` pour `Algo_TD_3B`, `20` pour `Algo_TP_3B2`
Salle autorisée | *Allowed class room* | une salle compatible pour l'accueil d'une classe | `G101` pour `Algo_TP_3B2`


### Salles
Nous adoptons la modélisation du schéma ITC pour représenter les salles :
- L'instance comporte un inventaire de salles d'enseignement (l'élément `rooms`).
- A chaque salle (élément `room`) est attribuée une capacité d'accueil mesurée par un nombre d'étudiants (attribut `capacity`).[^f-salle-v]
- A chaque salle peut être associé un ou plusieurs programmes de fermeture (éléments `unavailable`).

[^f-salle-v]: Cette mesure est applicable aux salles virtuelles d'EAD dont la capacité est limitée et se mesure en nombre de connexions étudiantes simultanées.

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
Inventaire de salles | *room inventory* | un parc de salles d'enseignement | salles du campus de l'UFR-Sciences, salles du bâtiment G
Salle | *room* | une salle d'enseignement, potentiellement virtuelle | salle H002, salon *Algorithmique* du serveur Discord *L1_MPCIE*
Capacité | *capacity* | une capacité d'accueil de salle mesurée en termes d'effectif (salle réelle) ou nombre de connexions simultanées autorisées (salle virtuelle) | 40
Programme de fermeture | *room closure schedule* | un programme de séances de fermeture pour une salle | 3^ème^ créneau de la 2^ème^ journée des 4^ème^ et 7^ème^semaines



### Trajets et pauses
Une règle classique dans les problèmes d'emploi du temps stipule que deux salles ne peuvent être allouées à deux séances consécutives impliquant un même participant (enseignant ou étudiant) que si le temps de pause entre les séances excède le temps de trajet entre salles. Le schéma ITC permet de formuler ces contraintes de déplacement à l'aide d'un prédicat[^f-attendees] et de les rendre impératives ou facultatives selon les classes et les participants (e.g. contraintes impératives sur les classes d'un enseignant, contraintes facultatives sur les classes de chaque étudiant).[^f-pred]

[^f-attendees]: Le prédicat `SameAttendees` est utilisé à cet effet.
[^f-pred]: Le schéma ITC permet aussi de contraindre à l'aide de prédicats de distribution les temps de pause entre différentes séances, e.g. durée maximum ou durée minimum pour permettre le déplacement entre salles.

Pour être vérifiable, chaque contrainte doit pouvoir comparer temps de trajet et temps de pause, tous deux étant mesurés en nombres de créneaux (i.e. multiples de la durée nominale). Le temps de trajet entre deux salles est supposé constant dans le schéma ITC et spécifié par l'attribut `travel`. Le temps de pause entre deux séances dépend quant à lui des dates de départ et de fin affectée aux séances dans l'emploi du temps. Il ne peut donc pas être spécifié à priori et peut prendre n'importe quelle valeur dans la plage $1\ldots nr\_slots-1$.

##### Adaptation UA
Dans notre approche, la durée nominale des créneaux d'enseignement et les temps de pause entre créneaux consécutifs ne peuvent être ni spécifiés, ni inférés à partir des seules données d'une instance ITC. Par conséquent, le délai entre deux séances ne peut pas être calculé de manière absolu et donc comparé à un temps de trajet pour vérifier une contrainte de déplacement. Néanmoins il est possible de compiler ces contraintes sans déroger au schéma ITC en adoptant un autre domaine de valeurs pour l'attribut `travel`.

Dans notre représentation de l'horizon de temps, la journée-type d'enseignement caractérise implicitement un programme quotidien de pauses. Ces pauses peuvent être de durées différentes mais, par hypothèse, restent invariables sur tout l'horizon. Puisque toutes les séances sont de durée nominale et se programment sur un seul créneau, il suffit d'indiquer pour une paire de salles, si pour chaque créneau-type de la journée, la pause à suivre garantit ou non un temps de déplacement suffisant entre les deux salles avant le début du créneau suivant.[^f-break] La valeur attendue d'un attribut `travel` est donc un vecteur booléen (bitset) indexé sur les créneaux-type de la journée, à l'exception du dernier, et dont le $i$-ème élément indique si oui (valeur `1`) ou non (valeur `0`) la pause entre les $i$ et $i+1$-èmes créneaux suffit à se déplacer entre les deux salles concernées.

[^f-break]: Pour être complet, ce type d'information devrait être compilée par paire de salles pour toutes les paires ordonnées de créneaux-type qu'ils soient consécutifs ou non. Un tel encodage semble toutefois d'un intérêt limité car on peut supposer dans la pratique que la durée nominale (e.g. 80 minutes) suffit à se déplacer entre toutes salles. C'est l'hypothèse que nous adoptons et qui considère les contraintes de déplacement nécessairement vérifiées entre séances consécutives dès lors qu'un créneau au moins les sépare.


Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
Pause | *break* | laps de temps entre deux créneaux-type consécutifs | pause entre les deux premiers créneaux-type


### Etudiants
Nous adoptons la modélisation du schéma ITC pour représenter les étudiants et leurs inscriptions :
- L'instance comporte un unique listing d'étudiants (l'élément `students`).
- A chaque étudiant (élément `student`) est associée la liste des cours auxquels il s'est inscrit (sous-élément `course`).

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
Cohorte | ** | la cohorte des étudiants | `L3_informatique`, `L1_MPCIE`
Etudiant | *student* | un étudiant | Otto Didakt
Inscription | *registration* | inscription d'un étudiant à un cours |  


### Décisions, contraintes et coûts

#### Décisions
La confection d'un emploi du temps consiste à arrêter un certain nombre de décisions. Chacune revient à choisir une unique alternative parmi celles qui, en nombre fini, lui sont associées. L'éventail de décisions auquel se limite le schéma ITC est le suivant :
- l'enrôlement ou non d'un étudiant dans l'effectif d'une classe,
- le choix d'un programme de séances par classe *ouverte* (i.e. à effectif non-nul),
- le choix d'une salle par classe ouverte.


#### Contraintes implicites
Les décisions sont, individuellement ou collectivement, soumises à contraintes. Chaque contrainte restreint l'éventail des choix possibles pour le sous-ensemble des décisions qui la concernent. La plupart des contraintes sont implicites dans le schéma ITC. C'est le cas des contraintes de configuration de cours, de fermeture, d'occupation et de capacité de salles, de sectionnement d'effectifs et d'inscriptions aux cours, et de déplacement et de disponibilité d'étudiants.


#### Contraintes explicites de distribution
Les contraintes explicites dans une instance ITC se formulent avec un langage fondé sur 19 prédicats qui permettent de contraindre la distribution temporelle des classes. Chaque contrainte (élément `distribution`) instancie un prédicat (attribut `type`) sur un sous-ensemble de classes (sous-éléments `class`) et, selon sa signature, fournit des valeurs pour les paramètres attendus.

##### Adaptation UA
Les prédicats paramétrés (`WorkDay(S), MinGap(G), MaxDays(D), MaxDayLoad(S), MaxBreaks(R,S), MaxBlock(M,S)`) ne sont pas à ce jour supportés dans notre approche.

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
| Prédicat de distribution | *distribution predicate* | un prédicat modélisant une règle de distribution temporelle entre classes | même créneau pour deux classes, mêmes semaines pour trois classes | 
| Portée d'une contrainte de distribution | *distribution constraint scope* | ensemble de classes soumises à la contrainte | 


#### Dureté des contraintes de distribution
Le schéma ITC supporte deux types de contraintes : des contraintes dites *dures* qui doivent être impérativement satisfaites, et des contraintes dites *souples* qui peuvent être violées mais dont la violation induit un coût. En particulier, chaque contrainte de distribution peut être déclarée dure (présence de l'attribut optionnel `required`) ou bien souple (présence de l'attribut optionnel `penalty`).

##### Adaptation UA
Les contraintes de distribution souples et de pénalité nulle n'ont aucune incidence sur la consistance ou le coût des solutions candidates. Par conséquent, nous interprétons une pénalité nulle comme le fait que la contrainte soit dure. 

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
| Contrainte dure | *hard constraint* | une contrainte à satisfaire impérativement |
| Contrainte souple | *soft constraint* | une contrainte pouvant être violée et dont la violation induit un coût


#### Pénalités
Le schéma ITC définit le coût de violation d'une contrainte de distribution souple comme le produit de sa pénalité et d'une fonction qui évalue le degré de violation du prédicat sur les classes concernées selon leur programmation dans l'emploi du temps. La fonction est propre au prédicat utilisé. Si le prédicat est non paramétré, elle comptabilise le nombre de paires de classes le violant. Dans le cas contraire, elle met en jeu les paramètres du prédicat.

Le schéma ITC associe aussi une pénalité non-négative à chaque programme de séances et à chaque salle envisageables pour une classe (attribut `penalty`). Les choix de programmation et d'allocation pour chaque classe induisent donc des pénalités qui sont imputées au coût de l'emploi du temps (cf. section Coût).

Concept | Anglais | Définition | Exemple
---- | ---- | ---- | ---- | ----
| Pénalité de contrainte de distribution | *distribution constraint penalty* | pénalité associée à la violation d'une contrainte de distribution souple |
| Pénalité d'un programme de classe | *class schedule penalty* | pénalité encourue si le programme est choisi pour la classe |
| Pénalité d'hébergement de classe | *class room penalty* | pénalité encourue si la salle est allouée à la classe |


#### Critères
Les pénalités résultant d'un emploi du temps sont imputées sur différents critères de coûts. Les critères sont au nombre de quatre dans le schéma ITC :
- le critère de programmation mesure la somme des pénalités de programmation,
- le critère d'allocation mesure la somme des pénalités d'allocation,
- le critère de distribution mesure la somme des coûts de violation des contraintes souples de distribution,
- le critère de disponibilité étudiante comptabilise sur la totalité des étudiants le nombre de paires de classes consécutives auxquelles un étudiant ne peut assister par manque de temps de déplacement ou parce que ses classes se chevauchent.

##### Adaptation UA
Notre approche impose que tout étudiant puisse assister à toutes les classes dans lesquelles il est enrôlé. Autrement dit, les contraintes de disponibilité sont considérées dures. Le critère de disponibilité perd alors sa pertinence.

#### Coût
Le schéma ITC définit le coût d'un emploi du temps comme la somme pondérée des coûts imputés sur les 4 critères. Il associe donc un poids à chaque critère (attributs `time,room,distribution,student` de l'élément  `optimization`) dont la valeur est propre à chaque instance.


##  Formats XML et Minizinc

Nous rappelons dans différents tableaux les éléments du schéma ITC et en donnons une modélisation dans le langage Minizinc. Cette modélisation associe à chaque type d'élément et d'attribut XML une plage d'entiers Minizinc servant d'identifiants. Les listes de sous-éléments et les valeurs d'attributs sont quant à elles modélisées par des vecteurs ou des matrices indexés sur ces plages.

Dans chaque tableau, la colonne `XML` donne la modélisation dans le schéma ITC des différents concepts. Les colonnes `DZN` et `MZN` fournissent respectivement les données sources qui figurent dans le jeu de données représentant une instance ITC (fichier de suffixe `dzn`) et les données qui sont propres au modèle Minizinc (fichiers de suffixe .mzn).

### Horizon
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Nombre de semaines-type | attribut `nrWeeks` de `problem` | entier `nr_weeks` | |
| Nombre de journées-type par semaine-type | attribut `nrDays` de `problem` | entier `nr_days_per_week` |
| Nombre de créneaux-type par journée-type | attribut `slotsPerDay` de `problem` | entier `nr_slots_per_day` |
| Nombre de créneaux | implicite | | entier `nr_slots = nr_slots_per_day * nr_days_per_week * nr_weeks`
| Les semaines de l'horizon | implicite | | plage `WEEKS = 1..nr_weeks`
| La semaine-type | implicite  | | plage `WEEKDAYS = 1..nr_days_per_week`
| La journée-type | implicite | | plage `DAYSLOTS = 1..nr_slots_per_day`
| Liste chronologique des créneaux de l'horizon | implicite | | plage `SLOTS = 1..nr_slots`


### Programmes
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Programme | quadruplet d'attributs `weeks,days,start,length` d'élément `unavailable` ou `time` | quadruplet de valeurs repérées par le même indice dans 4 vecteurs indexés sur la même plage (soit `ROOMS`, soit `TIMES`)
| Les semaines d'un programme | attribut `weeks` à valeur dans $\{0,1\}^{nr\_weeks}\backslash\{0\}^{nr\_weeks}$  | élément d'un vecteur à valeurs dans `set of WEEKS`
| Les journées d'un programme | attribut `days` à valeur dans $\{0,1\}^{nr\_days\_per\_week}\backslash\{0\}^{nr\_days\_per\_weeks}$ | élément d'un vecteur à valeurs dans `set of WEEKDAYS`
| Le créneau d'un programme | attribut `start` à valeur dans $\{1,\ldots,nr\_slots\_per\_day\}$ | élément d'un vecteur à valeurs dans `DAYSLOTS`
| La durée d'un programme | attribut `length` à valeur dans $\{1,\ldots,nr\_slots\_per\_day\}$ | élément d'un vecteur à valeurs dans `SLOTS`[^f-len]

[^f-len]: La plage est réduite à `1..1` dans le modèle Minizinc.


### Cours
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Nombre de cours | implicite | entier `nr_courses` |
| Nombre de configurations | implicite | entier `nr_configs` |
| Nombre de classes-type | implicite | entier `nr_subparts` |
| Nombre de classes | implicite | entier `nr_classes` |
| Nombre de programmes de cours | implicite | entier `nr_times` |
| Liste des cours | les éléments `course` | | plage `COURSES = 1..nr_courses`
| Liste des configurations | les éléments `config` | | plage `CONFIGS = 1..nr_configs`
| Liste des classes-type | les éléments `subpart` | | plage `SUBPARTS = 1..nr_subparts`
| Liste des classes | les éléments `class` | | plage `CLASSES = 1..nr_classes`
| Liste des programmes des cours | les éléments `time` | | plage `TIMES = 1..nr_times`
| Un cours | sous-élément `course` de `courses` | | élément de `COURSES`
| Les configurations d'un cours | les sous-éléments `config` d'un élément `course` | élément du vecteur `configs` indexé sur `COURSES` et à valeurs dans `set of CONFIGS` |
| Les classes-type d'une configuration | les sous-éléments `subpart` d'un élément `config` | élément du vecteur `subparts` indexé sur `CONFIGS` et à valeurs dans `set of SUBPARTS` |
| Les classes d'une classe-type | les sous-éléments `class` d'un élément `subpart` | élément du vecteur `classes` indexé sur `SUBPARTS` et à valeurs dans `set of CLASSES` |
| L'effectif maximum d'une classe | attribut `limit` d'un élément `class` | élément du vecteur `limit` indexé sur `CLASSES` et à valeurs dans `0..nr_students` |
| Une classe virtuelle | présence de l'attribut optionnel `room` de valeur `false` dans un élément `class` | élément de valeur `0` du vecteur `limit`  |
| Une classe parente | présence de l'attribut optionnel `parent` dans un élément `class` | élément de valeur différente de `0` du vecteur `virtual_class` indexé sur `CLASSES` et à valeurs dans `0..nr_classes`  |
| Les salles d'une classe non-virtuelle | les sous-éléments `room` d'un élément `class` | élément du vecteur `rooms` indexé sur `CLASSES` et à valeurs dans `set of ROOMS` |
| Les programmes d'une classe | les sous-éléments `time` d'un élément `class` | élément du vecteur `times` indexé sur `CLASSES` et à valeurs dans `set of TIMES` |
| Les semaines d'un programme de classe | attribut `weeks` d'un élément `time` | élément du vecteur `time_weeks` indexé sur `TIMES` et à valeurs dans `set of WEEKS` |
| Les journées d'un programme de classe | attribut `days` d'un élément `time` | élément du vecteur `time_days` indexé sur `TIMES` et à valeurs dans `set of WEEKDAYS` |
| Le créneau d'un programme de classe | attribut `start` d'un élément `time` | élément du vecteur `time_start` indexé sur `TIMES` et à valeurs dans `DAYSLOTS` |
| La durée d'un programme de classe | attribut `length` d'un élément `time` | élément du vecteur `time_length` indexé sur `TIMES` et à valeurs dans `SLOTS`[^f-len] |
| Un programme de classe | sous-élément `time` d'élément `class` | | élément de `TIMES` indexant un quadruplet de valeurs dans `time_weeks`, `time_days`, `time_start` et `time_length`


### Salles
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Nombre de salles | implicite | entier `nr_rooms`
| Capacité d'accueil maximum | implicite | entier `max_capacity`
| Nombre de programmes de fermetures | implicite | entier `nr_closures`
| Liste des salles | les éléments `room` | | plage `ROOMS = 1..nr_rooms`
| Plage de capacité | implicite | | plage `CAPACITY = 1..max_capacity`
| Liste des programmes de fermetures | les éléments `unavailable` |  | plage `CLOSURES = 1..nr_closures`
| Une salle | sous-élément `room` de `rooms` | | élément de `ROOMS`
| Une capacité de salle | attribut `capacity` d'élément `room` | élément du vecteur `capacity` indexé sur `ROOMS` et à valeurs dans `CAPACITY` |
| Les programmes de fermeture d'une salle | les sous-éléments `unavailable` d'un élément `room` | élément du vecteur `closures` indexé sur `ROOMS` et à valeurs dans `set of CLOSURES` |
| Les semaines d'un programme de fermeture d'une salle | attribut `weeks` d'un élément `unavailable` | élément du vecteur `closure_weeks` indexé sur `ROOMS` et à valeurs dans `set of WEEKS` |
| Les journées d'un programme de fermeture d'une salle | attribut `days` d'un élément `unavailable` | élément du vecteur `closure_days` indexé sur `ROOMS` et à valeurs dans `set of WEEKDAYS` |
| Le créneau d'un programme de fermeture d'une salle | attribut `start` d'un élément `unavailable` | élément du vecteur `closure_start` indexé sur `ROOMS` et à valeurs dans `DAYSLOTS` |
| La durée d'un programme de fermeture d'une salle | attribut `length` d'un élément `unavailable` | élément du vecteur `closure_length` indexé sur `ROOMS` et à valeurs dans `SLOTS`[^f-len] |
| Un programme de fermeture d'une salle | sous-élément `unavailable` d'élément `room` | | élément de `CLOSURES` indexant un quadruplet de valeurs dans les vecteurs `closure_weeks`, `closure_days`, `closure_start` et `closure_length`


### Trajets et pauses
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Compatibilité du délai de déplacement entre deux salles au regard des temps de pauses | attribut `travel` de sous-élément `room` d'élément `room`  | élément de la matrice `travel` indexée sur `[ROOMS,ROOMS]` et à valeurs dans `set of DAYSLOTS` où `travel[i,j]` dénote l'ensemble des créneaux-type qui interdisent chacun la programmation de 2 classes à suivre si elles sont placées dans les salles `i` et `j`[^f-travel]

[^f-travel]: La matrice est symétrique et les valeurs (ensemblistes) ne peuvent pas contenir le dernier créneau-type de la journée.


### Etudiants
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Nombre d'étudiants | implicite | entier `nr_students` |
| Liste des étudiants | les éléments `student`| | plage `STUDENTS = 1..nr_students`
| Un étudiant | sous-élément `student` de `students` | | élément de `STUDENTS` |
| Une inscription d'étudiant à un cours | sous-élément `course` d'élément `student` | élément du vecteur `registrations` indexé sur `STUDENTS` et à valeurs dans `set of COURSES` |


### Contraintes de distribution
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Nombre de contraintes de distribution | implicite | entier `nr_distributions` |
| Liste des contraintes de distribution | les éléments `distribution` | | plage `DISTRIBUTIONS = 1..nr_distributions`
| Langage de prédicats | le langage `SameStart, SameTime, SameDays, SameWeeks, SameRoom, DifferentTime, DifferentDays, DifferentWeeks, DifferentRoom, Overlap, SameAttendees, Precedence, WorkDay(S), MinGap(G), NotOverlap, MaxDays(D), MaxDayLoad(S), MaxBreaks(R,S), MaxBlock(M,S)` où `S`, `G`, `D`, `R`et `M` dénotent des valeurs entières | | énumération `DISTRIBUTION = {same_start, same_time, same_days, same_weeks, same_room, different_time, different_days, different_weeks, different_room, overlap, same_attendees, precedence,not_overlap}`[^f-dist]
| Le prédicat d'une contrainte de distribution | attribut `type` d'un élément `distribution` prenant un prédicat de distribution comme valeur | élément du vecteur `distribution` indexé sur `DISTRIBUTIONS` et à valeurs dans `DISTRIBUTION` 
| La portée d'une contrainte de distribution | liste des sous-éléments `class` d'un élément `distribution` | ligne de la matrice `distribution_classes` indexée sur `[DISTRIBUTION,CLASSES]` et à valeurs dans `0..nr_classes` : les `n` premières valeurs non-nulles de la ligne `i` identifient les `n` premières classes de la contrainte `i`[^f-scope]

[^f-dist]: Les prédicats paramétrés ne sont pas implémentés dans le modèle Minizinc.
[^f-scope]: Une portée est une liste non vide et sans doublons. On impose que la première valeur de tout vecteur ligne de `distribution_classes` soit non-nulle et on interprète la première valeur nulle rencontrée comme la fin de la portée, sauf si la portée couvre l'ensemble des classes.


### Dureté des contraintes de distribution
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Contrainte souple | présence de l'attribut `penalty` dans un élément `distribution` | élément du vecteur `distribution_penalty` de valeur non-nulle[^f-pen]
| Contrainte dure | présence de l'attribut `required` dans un élément `distribution` | élément du vecteur `distribution_penalty` de valeur nulle[^f-pen]

[^f-pen]: Nous interprétons une pénalité de valeur `0` comme le fait que la contrainte est dure. 


### Pénalités
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Plage de pénalités | entiers non-négatifs | | plage `PENALTY = 0..100`
| Pénalité de distribution | attribut `penalty` d'élément `distribution` | élément du vecteur `distribution_penalty` indexé sur `DISTRIBUTIONS` et à valeurs dans `PENALTY`[^f-pen] |
| Pénalité de programmation de classe | attribut `penalty` d'élément `time` | élément du vecteur `time_penalty` indexé sur `TIMES` et à valeurs dans `PENALTY` |
| Pénalité d'allocation de salle | attribut `penalty` de sous-élément `room` d'élément `class` | élément de la matrice `room_penalty` indexée sur `[CLASSES,ROOMS]` et à valeurs dans `PENALTY` |


### Critères et coût
| Concept | XML | DZN | MZN|
|:--------|:----|:---|:---|
| Critères | attributs `time,room,student,distribution` de `optimization` | | énumération `CRITERION={k_time,k_room,k_student,k_distribution}` et plage correspondante `CRITERIA = 1..4` |
| Plage de poids de critère | entiers non-négatifs | | plage `WEIGHTS = 0..10`[^f-weight]
| Vecteur de poids | valeurs des attributs `time,room,student,distribution` de `optimization` | vecteur `weight` indexé sur `CRITERIA` et à valeurs dans `WEIGHTS` |

[^f-weight]: La valeur maximum de la plage est ici fixée arbitrairement. Pour chaque instance, il est possible de déterminer a priori 5 valeurs de poids (si on y inclut la valeur 0 pour pouvoir ''annuler'' un critère) afin de garantir n'importe quel ordre lexicographique sur les 4 critères. Ces valeurs sont instances-dépendantes et peuvent se calculer analytiquement.
<!--stackedit_data:
eyJwcm9wZXJ0aWVzIjoidGl0bGU6IFNjaMOpbWEgZGUgbW9kw6
lsaXNhdGlvbiBkZSBwcm9ibMOobWVzIGQnZW1wbG9pIGR1IHRl
bXBzIHVuaXZlcnNpdGFpcmVzXG5hdXRob3I6IERhdmlkIExlc2
FpbnQgKExFUklBKVxuZGF0ZTogJzIwMjAtMDktMTQnXG4iLCJo
aXN0b3J5IjpbLTE1OTIxOTMxMTEsNjUzODM1OTA5LC04MjE4Nz
U2MzMsLTIxMTY5MTYxMzIsMTAzMzkyOTAzNyw3NDEzMzMxMTks
OTMzNDYwMDMzLDEzNDA0MDg4MjIsLTEyMzU0NTg4NTcsLTQ2Nj
UzMjY0LC04OTAwNzIxNDIsLTE0MDE5Mjg3NzEsLTE1MTc3ODEz
MSwtODgyMDExMzI5LDE4MjAxMDIxNDAsMTg1Mjg3OTU3LDEwND
gwNDY0MDUsLTIxMjI2NDg0NjgsLTE4NTU4NDYzMjgsNDA1NDE2
MzM2XX0=
-->