%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRUCTURES DE DONNEES

%% STRUCTURES LUES EN ENTREE
array[COURSES] of set of CONFIGS: configs; % les configurations des cours
array[CONFIGS] of set of SUBPARTS: subparts; % les classes-type des configurations
array[SUBPARTS] of set of CLASSES: classes; % les classes des classes-type
array[CLASSES] of CLASSES_P: parent; % les classes parentes (la classe nulle est attribuée aux classes sans parent)
array[CLASSES] of STUDENTS: limit; % la limite d'effectif des classes (la valeur nulle est attribué aux classes fictives et aux classe virtuelles sans limite de capacité)
array[CLASSES] of set of TIMES: times; % les programmes alternatifs des classes
array[TIMES] of set of WEEKS: time_weeks; % les semaines des programmes 
array[TIMES] of set of WEEKDAYS: time_days; % les journées des programmes
array[TIMES] of DAYSLOTS: time_start; % les créneaux-type des programmes
array[TIMES] of DAYSLOTS: time_length; % les durées des programmes (supposées égales à 1)
array[TIMES] of PENALTY: time_penalty; % les pénalités des programmes
array[CLASSES] of set of ROOMS: rooms; % les salles allouables aux classes
array[CLASSES,ROOMS] of PENALTY: room_penalty; % la pénalité encourue par salle par classe 
array[ROOMS] of CAPACITY: capacity; % les capacités des salles
array[ROOMS] of set of CLOSURES: closures; % les (programmes de) fermetures des salles
array[CLOSURES] of set of WEEKS: closure_weeks; % les semaines des fermetures
array[CLOSURES] of set of WEEKDAYS: closure_days; % les journées des fermetures
array[CLOSURES] of DAYSLOTS: closure_slot; % les créneaux-type des fermetures
array[CLOSURES] of DAYSLOTS: closure_length; % les durées des fermetures (supposées égales à 1)
array[ROOMS,ROOMS] of set of DAYSLOTS: travel; % les créneaux-type impossibles par paire de salles (ne permettant pas un temps de déplacement suffisant avant le créneau suivant)
array[STUDENTS] of set of COURSES: registrations; % les inscriptions des étudiants
array[DISTRIBUTIONS] of DISTRIBUTION: distribution; % les contraintes de distribution
array[DISTRIBUTIONS] of PENALTY: distribution_penalty; % les pénalités des contraintes de distribution (la pénalité nulle est attribuée aux contraintes dures)
array[DISTRIBUTIONS,CLASSES] of CLASSES_P: distribution_classes; % les classes concernées des contraintes de distribution : *[m,i]=c si la classe `c` est la i-ème classe dans la portée de la contrainte `m`, *[m,i]==cst_null_class si la classe `c` n'est pas dans la portée de la contrainte `m`
array[CRITERIA] of WEIGHTS: weight; % le vecteur de poids associés aux critères


%% STRUCTURES AUXILIAIRES
array[TIMES] of DAYSLOTS: time_end = [time_start[t]+time_length[t]-1 | t in TIMES];
array[SLOTS] of WEEKS: week = [ ((i-1) div (nr_slots_per_day*nr_days_per_week)) + 1 | i in SLOTS]; % la semaine associée à chaque point de l'horizon 
array[SLOTS] of WEEKDAYS: weekday = [ (((i-1) mod (nr_slots_per_day*nr_days_per_week)) div nr_slots_per_day) + 1 | i in SLOTS]; % la journée associée à chaque point de l'horizon 
array[SLOTS] of DAYSLOTS: dayslot = [ (((i-1) mod (nr_slots_per_day*nr_days_per_week)) mod nr_slots_per_day) + 1 | i in SLOTS]; % le créneau associé à chaque point de l'horizon 
array[TIMES, SLOTS] of 0..1: open_slots = array2d(TIMES, SLOTS,[bool2int(week[s] in time_weeks[t] /\ weekday[s] in time_days[t] /\ dayslot[s]==time_start[t]) | t in TIMES, s in SLOTS]);
array[CLOSURES, SLOTS] of 0..1: closed_slots = array2d(CLOSURES, SLOTS, [bool2int(week[s] in closure_weeks[t] /\ weekday[s] in closure_days[t] /\ dayslot[s]==closure_slot[t]) | t in CLOSURES, s in SLOTS]);
%array[ROOMS, SLOTS] of 0..1: room_closed_slots = array2d(ROOMS, SLOTS,[bool2int(s in {i | t1 in CLOSURES, i in SLOTS where closed_slots[t1,i] == 1 /\ t1 in closures[r]}) | r in ROOMS, s in SLOTS]);
array[ROOMS, SLOTS] of 0..1: room_closed_slots = array2d(ROOMS, SLOTS,[bool2int({t | t in CLOSURES where closed_slots[t,s]==1 /\ t in closures[r]}!={}) | r in ROOMS, s in SLOTS]);

function SLOTS: termSlot(WEEKS: w, WEEKLY_SLOTS: s) = 
  s + w*nr_days_per_week*nr_slots_per_day;
  
function WEEKLY_SLOTS: weeklySlot(WEEKDAYS: d, DAYSLOTS: s) = 
  s + (d-1)*nr_slots_per_day;
  
function WEEKLY_SLOTS: timeWeeklySlot(TIMES: t) = 
  weeklySlot(min(time_days[t]),time_start[t]);% !! Modelling assumption : 1 day/time
  
function set of WEEKLY_SLOTS: classWeeklySlots(CLASSES: c) = 
  {timeWeeklySlot(t) | t in times[c]};


% Structures inverses
array[CONFIGS] of COURSES: course = [ min(u in COURSES where p in configs[u])(u) | p in CONFIGS]; % `configs` est le graphe de la fonction `course`
array[SUBPARTS] of CONFIGS: config = [ min(p in CONFIGS where s in subparts[p])(p) | s in SUBPARTS]; % `subparts` est le graphe de la fonction `config`
array[CLASSES] of SUBPARTS: subpart = [ min(s in SUBPARTS where c in classes[s])(s) | c in CLASSES]; % `classes` est le graphe de la fonction `subpart`
%  array[CLASSES] of set of CLASSES: children = [ { c | c in CLASSES where parent[c]==p} | p in CLASSES]; % `children` est le graphe de la fonction `parent` privé de la classe nulle
array[TIMES] of CLASSES: class = [ min(c in CLASSES where t in times[c])(c) | t in TIMES]; % `times` est le graphe de la fonction `time`
array[ROOMS] of set of CLASSES: room_classes = [{ c | c in CLASSES where r in rooms[c]} | r in ROOMS ]; % `room_classes` est l'inverse de `rooms`
array[COURSES] of set of STUDENTS: students = [{ s | s in STUDENTS where u in registrations[s]} | u in COURSES ]; % `students` est l'inverse de `registrations`
array[STUDENTS] of set of SUBPARTS: student_subpart_set = [array_union([subparts[p] | u in registrations[e], p in configs[u]]) | e in STUDENTS]; % ensemble des classes-type des cours auxquelles un étudiant est inscrit
array[STUDENTS] of set of CLASSES: student_classes = [array_union([classes[s] | u in registrations[e], p in configs[u], s in subparts[p]]) | e in STUDENTS]; % ensemble des classes des cours auxquelles un étudiant est inscrit

array[WEEKS] of set of CLASSES: week_classes = [ {c | c in CLASSES where w in time_weeks[min(times[c])]} | w in WEEKS];% !! Modelling assumption : same weeks for all times of a class
array[ROOMS,WEEKS] of set of CLASSES: room_week_classes = array2d(ROOMS,WEEKS,[room_classes[r] intersect week_classes[w] | r in ROOMS, w in WEEKS]);
array[STUDENTS,WEEKS] of set of CLASSES: student_week_classes = array2d(STUDENTS,WEEKS,[student_classes[e] intersect week_classes[w] | e in STUDENTS, w in WEEKS]);
array[STUDENTS] of set of TIMES: student_times = [array_union([times[c] | c in student_classes[e]]) | e in STUDENTS];
array[ROOMS] of set of TIMES: room_times = [array_union([times[c] | c in room_classes[r]]) | r in ROOMS];

array[CONSTRAINT_TYPE] of set of DISTRIBUTIONS: typed_distributions = [{m | m in DISTRIBUTIONS where distribution_penalty[m]==cst_null_penalty /\ hard==1},{m | m in DISTRIBUTIONS where distribution_penalty[m]!=cst_null_penalty /\ soft==2}]; % contraintes de distribution par type de contraintes
array[DISTRIBUTIONS] of set of CLASSES: distribution_scope = [{distribution_classes[m,i] | i in CLASSES where distribution_classes[m,i]!=cst_null_class} | m in DISTRIBUTIONS]; % ensemble des classes dans la portée d'une contrainte de distribution
array[CRITERIA] of set of int: COST_RANGE = [0..c_k_time,0..c_k_room,0..c_k_student,0..c_k_distribution]; % plage de coût possible par critère par élément imputable
int: c_k_time = sum(c in CLASSES)(max(t in times[c])(time_penalty[t]));
int: c_k_room = sum(c in CLASSES)(max(r in rooms[c])(room_penalty[c,r])); % ! 0 for classes with no room assigned
int: c_k_student = sum(s in STUDENTS)(card(student_subpart_set[s]) * (card(student_subpart_set[s]) - 1) div 2);
int: c_k_distribution = sum(m in typed_distributions[soft] where m<=min_gap)(distribution_penalty[m] * card(distribution_scope[m]) * (card(distribution_scope[m]) - 1) div 2)
+ sum(m in typed_distributions[soft] where m==max_days)(distribution_penalty[m] * max(WEEKDAYS))
+ sum(m in typed_distributions[soft] where m>=max_day_load)(distribution_penalty[m] * max(WEEKDAYS) * card(distribution_scope[m]));
set of int: COST = 0..sum(k in CRITERIA)(weight[k]*card(COST_RANGE[k])); % plage de la fonction coût
