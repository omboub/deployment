%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAGES/ENSEMBLES

%% PLAGES CONSTANTES (INSTANCE-INDEPENDANTES)
enum CONSTRAINT_TYPE = {hard,soft}; % type des contraintes : dure ou souple
enum DISTRIBUTION = {same_start, same_time, same_days, same_weeks, same_room, different_time, different_days, different_weeks, different_room, overlap, same_attendees, precedence, work_day, min_gap, not_overlap, max_days, max_day_load, max_breaks, max_block}; % identifiants des prédicats de distribution %TODO renommage, eg PREDICATE_DIST
enum CRITERION = {k_time, k_room, k_student, k_distribution}; % critères de coût


%% PLAGES FONDAMENTALES
set of int: WEEKS = 1..nr_weeks;
set of int: WEEKDAYS = 1..nr_days_per_week;
set of int: DAYSLOTS = 1..nr_slots_per_day;
set of int: COURSES = 1..nr_courses;
set of int: CONFIGS = 1..nr_configs;
set of int: SUBPARTS = 1..nr_subparts;
set of int: CLASSES = 1..nr_classes;
set of int: HEADCOUNT = 0..nr_students;
set of int: TIMES = 1..nr_times;
set of int: ROOMS = 1..nr_rooms; 
set of int: CAPACITY = 0..max_capacity;
set of int: CLOSURES = 1..nr_closures;
set of int: STUDENTS = 1..nr_students;
set of int: DISTRIBUTIONS = 1..nr_distributions;
set of int: PENALTY = 0..100;
set of int: CRITERIA = 1..nr_criteria;
set of int: WEIGHTS = 0..10; %TODO borne max à exprimer en fonction des dimensions de l'instance de sorte à permettre différents ordres lexicographiques sur les critères


%% PLAGES AUXILIAIRES
set of int: WEEKLY_SLOTS = 1..nr_slots_per_day*nr_days_per_week;
set of int: SLOTS = 1..nr_slots;
set of int: DURATION = 0..1; % La valeur 0 est utilisée dans des contraintes de capacité

% On ajoute un *élément nul* (modélisant un objet fictif) à certaines dimensions afin de réifier la non-sélection de composant dans la *configuration* de l'EDT solution (eg. classe fictive choisie pour un cours fermé, programme fictif affecté à une classe fermée, salle fictive allouée à une classe fermée). La valeur adoptée pour l'élément nul d'une dimension peut simplifier (ou non !) l'expression de contraintes de configuration.

% int: cst_null_config = 0; % configuration nulle assignée à un cours fermé
% set of int: CONFIGS_P = {cst_null_config} union CONFIGS;
int: cst_null_class = 0; % classe nulle assignée à une classe-type fermée en cas de configuration fermée
set of int: CLASSES_P = {cst_null_class} union CLASSES;
% int: cst_null_time = 0; % programme nul assigné à une classe fermée
% set of int: TIMES_P = {cst_null_time} union TIMES;
% int: cst_null_room = 0; % salle nulle allouée à une classe fermée 
% set of int: ROOMS_P = {cst_null_room} union ROOMS;
int: cst_null_penalty = 0; % pénalité nulle
