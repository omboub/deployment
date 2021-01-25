include "all_different.mzn";
include "all_equal.mzn";
include "arg_max.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREDICATS

%%% UTILITAIRES
% (p_registered) Requiert que l'étudiant `s` soit inscrit dans le cours de la classe `c`
predicate registered(var STUDENTS: s, var CLASSES: c) = 
   s in students[course[config[subpart[c]]]];

% (p_enrolled) Requiert que l'étudiant `s` soit enrôlé dans la classe `c`
predicate enrolled(var STUDENTS: s, var CLASSES: c) = 
   x_class[s,subpart[c]] == c;


% %%% PREDICATS DE DISTRIBUTION
% (p_same_start) Un créneau journalier en commun, indépendamment des journées et semaines
% L'égalité suffit puisque chaque séance est de durée unitaire
predicate same_start(array[int] of CLASSES: sc) = 
  all_equal([time_start[x_time[c]] | c in sc]);


% (p_same_time) Equivaut à `same_start` ici puisque les séances sont supposées de longueur 1
predicate same_time(array[int] of CLASSES: sc) = 
  forall(c1,c2 in sc where c1<c2)(
    (time_start[x_time[c1]] <= time_start[x_time[c2]]
     /\
     time_end[x_time[c2]] <= time_end[x_time[c1]])
     \/
    (time_start[x_time[c2]] <= time_start[x_time[c1]]
     /\
     time_end[x_time[c1]] <= time_end[x_time[c2]])
  )
;


% (p_different_time) Aucun créneau journalier en commun, indépendamment des journées et semaines
% L'inégalité suffit puisque chaque séance est de durée unitaire
predicate different_time(array[int] of CLASSES: sc) = 
  forall(c1,c2 in sc where c1<c2)(
        time_start[x_time[c1]] != time_start[x_time[c2]]
% Version générique (non-THELEME) :
%      time_end[x_time[c2]] < time_start[x_time[c1]]
%      \/
%      time_end[x_time[c1]] < time_start[x_time[c2]]
)
;


% (p_same_days) Egalité ou inclusion entre ensembles de journées, indépendamment des créneaux et semaines
predicate same_days(array[int] of CLASSES: sc) = 
  let {array[int] of var set of WEEKDAYS: x = [time_days[x_time[c]] | c in sc]}
  in
  array_union(x) subset x[arg_max([card(x[i]) | i in index_set(x)])];


% (p_different_days) Aucune journée commune, indépendamment des créneaux et semaines
predicate different_days(array[int] of CLASSES: sc) = 
  all_different([min(time_days[x_time[c]]) | c in sc]);
% Version générique (non-THELEME) :
%   let {array[int] of var set of WEEKDAYS: x = [time_days[x_time[c]] | c in sc]}
%   in
%   card(array_union(x))==sum(i in x)(card(i));


% (p_same_weeks) Egalité ou inclusion entre ensembles de semaines, indépendamment des créneaux et journées
% ! à n'utiliser que sur des paires -> ajouter assertion
predicate same_weeks(array[int] of CLASSES: sc) = 
  let {array[int] of var set of WEEKS: x = [time_weeks[x_time[c]] | c in sc]}
  in
  array_union(x) subset x[arg_max([card(x[i]) | i in index_set(x)])];


% (p_different_weeks) Aucune semaine en commun, indépendamment des créneaux et journées
predicate different_weeks(array[int] of CLASSES: sc) = 
  let {array[int] of var set of WEEKS: x = [time_weeks[x_time[c]] | c in sc]}
  in
  card(array_union(x))==sum(i in x)(card(i));


% (p_same_room) Même salle
predicate same_room(array[int] of CLASSES: sc) = 
  all_equal([x_room[c] | c in sc]);


% (p_different_room) Aucune salle commune
predicate different_room(array[int] of CLASSES: sc) = 
  all_different([x_room[c] | c in sc]);


% (p_overlap) Au moins un créneau journalier en commun (== créneau identique),  au moins une journée commune, au moins une semaine commune
predicate overlap(array[int] of CLASSES: sc) =
  forall(c1,c2 in sc where c1<c2)(
        (time_start[x_time[c2]] <= time_end[x_time[c1]]) /\ (time_start[x_time[c1]] <= time_end[x_time[c2]])
    /\ (time_days[x_time[c1]] intersect time_days[x_time[c2]] != {})
    /\ (time_weeks[x_time[c1]] intersect time_weeks[x_time[c2]] != {})
  )
;


% (p_not_overlap) Aucun créneau journalier en commun ou aucune journée commune ou aucune semaine commune
predicate not_overlap(array[int] of CLASSES: sc) = 
  forall(c1,c2 in sc where c1<c2)(
        different_time([c1,c2])
    \/ different_days([c1,c2])
    \/ different_weeks([c1,c2])
  )
;

% (p_same_attendees) Pas de chevauchement ou bien temps de déplacement suffisant
predicate same_attendees(array[int] of CLASSES: sc) = 
  forall(c1,c2 in sc where c1<c2)(
    time_weeks[min(times[c1])] intersect time_weeks[min(times[c2])] != {}
    -> x_w_start[c1] != x_w_start[c2]
  )
;

%% TODO adapter à nouvelle sémantique de `travel`
% % array[int] of var DAYSLOTS: x, array[int] of var set of WEEKDAYS: y, array[int] of var set of WEEKS: z, array[int] of var ROOMS: r
% % [time_start[x_time[c]] | c in sc],[time_days[x_time[c]] | c in sc],[time_weeks[x_time[c]] | c in sc],[x_room[c] | c in sc]
%   forall(c1,c2 in sc where c1<c2)(
%     not_overlap([c1,c2])
% %     /\
% %     (
% %       (same_days({c1,c2})/\same_weeks({c1,c2}))
% %       ->
% %       (
% %         (time_start[x_time[c1]] + time_length[x_time[c1]] + travel[x_room[c1], x_room[c2]] <= time_start[x_time[c2]])
% %         \/
% %         (time_start[x_time[c2]] + time_length[x_time[c2]] + travel[x_room[c1], x_room[c2]] <= time_start[x_time[c1]])
% %       )
% %     )
%   )
% ;


% (p_precedence) Première séance d'une classe de rang i précède les premières séances des classes de rang supérieur (semaine antérieure, ou journée antérieure, ou créneau antérieur)
predicate precedence(array[int] of CLASSES: sc) =
  let{ array[int] of var DAYSLOTS: x = [time_start[x_time[c]] | c in sc],
  array[int] of var set of WEEKDAYS: y = [time_days[x_time[c]] | c in sc],
  array[int] of var set of WEEKS: z = [time_weeks[x_time[c]] | c in sc]}
  in
   forall(i,j in index_set(x) where i<j)(precedes(x[i],x[j],y[i],y[j],z[i],z[j]))
;

predicate precedes(var DAYSLOTS: x1, var DAYSLOTS: x2, var set of WEEKDAYS: y1, var set of WEEKDAYS: y2, var set of  WEEKS: z1, var set of WEEKS: z2) = 
    min([i | i in z1])>=min([i | i in z2])
    -> (min([i | i in y1])>=min([i | i in y2])
           -> (x1<x2)
         )
;

