%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSERTIONS

constraint assert(nr_weeks > 0, "Invalid datafile: " ++  "Number of weeks should be strictly positive");
constraint assert(nr_days_per_week in 1..7, "Invalid datafile: " ++  "Number of days per week should belong to 1..7");
constraint assert(nr_slots_per_day in 1..144, "Invalid datafile: " ++  "Number of slots per days should belong to 1..24*6, ie, the minimum granularity allowed is 10 minutes each slot");
constraint assert(nr_slots == nr_weeks * nr_days_per_week * nr_slots_per_day, "Invalid datafile: " ++  "Incorrect number of slots");
%constraint assert(nr_breaks > 0, "Invalid datafile: " ++  "Number of break types should be strictly positive");
constraint assert(nr_courses > 0, "Invalid datafile: " ++  "Number of courses should be strictly positive");
constraint assert(nr_configs >= nr_courses, "Invalid datafile: " ++  "Number of configurations should be greater than or equal to the number of courses");
constraint assert(nr_subparts >= nr_configs, "Invalid datafile: " ++  "Number of subparts should be greater than or equal to the number of configurations");
constraint assert(nr_classes >= nr_subparts, "Invalid datafile: " ++  "Number of classes should be greater than or equal to the number of subparts");
constraint assert(nr_times >= nr_classes, "Invalid datafile: " ++  "Number of times should be greater than or equal to the number of classes");
constraint assert(nr_rooms > 0, "Invalid datafile: " ++  "Number of rooms should be strictly positive");
% NB. Pas d'assertion sur capacité maximum
% NB. Pas d'assertion sur nombre de fermetures
constraint assert(nr_students > 0, "Invalid datafile: " ++  "Number of students should be strictly positive");
% NB. Pas d'assertion sur nombre de distributions


% test assert( partition_set(configs,CONFIGS), "Invalid datafile: " ++  "The set of courses induces a partition of the set of configurations");
constraint assert( forall(u in COURSES) (configs[u]!={}), "Invalid datafile: " ++  "At least one configuration required per course");
constraint assert( forall(u in COURSES where u<max(COURSES)) (max(p in CONFIGS where p in configs[u])(p)+1==min(p in CONFIGS where p in configs[u+1])(p)), "Invalid datafile: " ++  "Configurations must be indexed consistently with courses");

% constraint assert( partition_set(subparts,SUBPARTS), "Invalid datafile: " ++  "The set of configurations induces a partition of the set of subparts");
constraint assert( forall(p in CONFIGS) (subparts[p]!={}), "Invalid datafile: " ++  "At least one subpart required per configuration");
constraint assert( forall(p in CONFIGS where p<nr_configs) (max(s in SUBPARTS where s in subparts[p])(s)+1==min(s in SUBPARTS where s in subparts[p+1])(s)), "Invalid datafile: " ++  "Subparts must be indexed consistently with configurations");

% constraint assert( partition_set(classes,CLASSES), "Invalid datafile: " ++  "The set of subparts induces a partition of the set of classes");
constraint assert( forall(s in SUBPARTS) (classes[s]!={}), "Invalid datafile: " ++  "At least one class required per subpart");
constraint assert( forall(s in SUBPARTS where s<nr_subparts) (max(c in CLASSES where c in classes[s])(c)+1==min(c in CLASSES where c in classes[s+1])(c)), "Invalid datafile: " ++  "Classes must be indexed consistently with subparts");

% Relation de parenté confinée au périmètre des cours
constraint assert( forall(c1,c2 in CLASSES where parent[c1]==c2) (course[config[subpart[c1]]]==course[config[subpart[c2]]]), "Invalid datafile: " ++  "Parenthood should link classes of the same course");
% Relation de parenté élevée aux classes-type
%% si une classe a un parent alors les autres classes de sa classe-type sont des enfants et leurs parents sont dans la même classe-type
constraint assert( forall(c1,c2 in CLASSES where parent[c1]!=cst_null_class /\ subpart[c1]==subpart[c2]) (subpart[parent[c1]]==subpart[parent[c2]]), "Invalid datafile: " ++  "Classes of a subpart containing a child class should be children whose parents belong to the same subpart");
%% si une classe a un enfant alors les autres classes de sa classe-type ont un enfant dans la même classe-type
% constraint assert( forall(c1,c2 in CLASSES where children[c1]!={} /\ subpart[c1]==subpart[c2]) ({ s | s in SUBPARTS, c in CLASSES where c in children[c1] /\ s==subpart[c]}=={ s | s in SUBPARTS, c in CLASSES where c in children[c2] /\ s==subpart[c]}), "Invalid datafile: " ++  "Classes of a subpart containing a child class should all be children whose parents belong to the same subpart");
%% la relation de parenté entre classes est consistante avec l'indexation des classes-types induite par l'ordre de leur déclaration, assurant donc une forêt de parentés par cours
constraint assert( forall(c1,c2 in CLASSES where parent[c1]==c2) (subpart[c1]>subpart[c2]), "Invalid datafile: " ++  "Parenthood over classes must be consistent with subpart indexing");

% la limite cumulée des classes d'un cours calculée sur ses classes-type *feuilles* excède l'effectif d'étudiants inscrits au cours
constraint assert( forall(u in COURSES)(sum(c in CLASSES, s in SUBPARTS where s==subpart[c] /\ u==course[config[s]] /\ s==max(s1 in subparts[config[s]])(s1))(limit[c]) >= card(students[u])) , "Invalid datafile: " ++  "The number of students registered to a course should be smaller or equal to the cumulated headcount limit computed over the final subparts of the course");

% constraint assert( partition_set(times,TIMES), "Invalid datafile: " ++  "The set of classes induces a partition of the set of times");
constraint assert( forall(c in CLASSES) (times[c]!={}), "Invalid datafile: " ++  "At least one time required per class");
constraint assert( forall(c in CLASSES where c<nr_classes) (max(t in TIMES where t in times[c])(t)+1==min(t in TIMES where t in times[c+1])(t)), "Invalid datafile: " ++  "Times must be indexed consistently with classes");

% TODO Hypothèse faite dans la compétition ITC : la limite en effectif d'une classe est inférieure à la capacité minimum des salles pouvant lui être allouée. A rajouter ?

% constraint assert( forall(r in ROOMS) (break[r,r]=cst_null_break), "Invalid datafile: " ++  "Unreachability is irreflexive");
% constraint assert( forall(r1,r2 in ROOMS where r1<r2) (break[r1,r2]=break[r2,r1]), "Invalid datafile: " ++  "Unreachability is symmetric");

% TODO Hypothèse faite dans la compétition ITC : un cours doit être requis par un étudiant au moins. A supprimer ?
constraint assert( forall(u in COURSES) (students[u]!={}), "Invalid datafile: " ++  "At least one student registers for a class");
