%include "at_most.mzn";
include "cumulative.mzn";
%include "disjunctive.mzn";
%include "partition_set.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTRAINTES

%% PROGRAMMATION/DEPROGRAMMATION (PRE-RESERVATIONS)
% (c-r-1) [dure] Une classe est soit déprogrammée, soit programmée sur une des séances qui lui sont pré-réservées : aucune autre séance ne peut lui être attribuée.
constraint
  forall(c in CLASSES)(
      x_time[c] in times[c]
    )
;

% (c-r-2) [souple] La programmation d'une classe sur une séance induit une pénalité.
constraint
  forall(c in CLASSES)(
      x_p_time[c] == time_penalty[x_time[c]]
    )
;

%% POSITIONNEMENT/DEPOSITIONNEMENT (PRE-ALLOCATIONS)
% (c-a-1) [dure] Une classe est soit dépositionnée, soit positionnée dans une des salles qui lui sont pré-allouées : aucune autre salle ne peut lui être allouée.
constraint
  forall(c in CLASSES)(
      x_room[c] in rooms[c]
    )
;

% (c-a-2) [souple] Le positionnement d'une classe dans une salle induit une pénalité.
constraint
  forall(c in CLASSES)(
      x_p_room[c] == room_penalty[c,x_room[c]] % ! 0 par sémantique relationnelle de mzn si salle nulle
    )
;

%% DIMENSIONNEMENT/ENROLEMENT (EFFECTIFS)
% (c-d-1) [dure] L'effectif d'une classe est le nombre d'étudiants enrôlés dans la classe.
constraint
  forall(c in CLASSES)(
      x_headcount[c] == sum(s in STUDENTS)(bool2int(enrolled(s,c)))
    )
;

%% DIMENSIONNEMENT (LIMITES)
% (c-d-2) [dure] L'effectif d'une classe ne peut dépasser son seuil autorisé.
constraint
  forall(c in CLASSES)(
      x_headcount[c] <= limit[c]
    )
;

%% ENROLEMENT (INSCRIPTIONS)
% (c-e-1) [dure] Un étudiant ne peut être enrôlé que dans des classes de cours auxquels il est inscrit.
constraint
  forall(s in STUDENTS, c in CLASSES)(
      enrolled(s,c) -> registered(s,c)
    )
;

%% ENROLEMENT (CONFIGURATION)
% (c-e-2) [dure] Un étudiant ne peut être enrôlé que dans les classes associées à chaque classe-type.
constraint
  forall(e in STUDENTS, s in SUBPARTS)(
      x_class[e,s] in classes[s] union {cst_null_class}
    )
;

%% ENROLEMENT (SECTIONNEMENT) 
% (c-e-4) [dure] Pour chaque cours auquel il est inscrit, un étudiant est enrôlé dans une classe par classe-type d'une des configurations du cours.
constraint
  forall(e in STUDENTS, u in COURSES where u in registrations[e])(
    sum(p in configs[u])(product(s in subparts[p])(sum(c in classes[s])(bool2int(x_class[e,s]==c)))) == 1
    )
;

% (c-e-5) [dure] Un étudiant n'est enrôlé dans aucune des classes des des cours auxquels il n'est pas inscrit.
% Force l'affectation de la classe nulle.
constraint
  forall(e in STUDENTS, u in COURSES where not (u in registrations[e]))(
    sum(p in configs[u])(sum(s in subparts[p])(sum(c in classes[s])(bool2int(x_class[e,s]==c)))) == 0
    )
;

% (c-e-7) [dure] Un étudiant enrôlé dans une classe enfant doit l'être dans la classe parente.
constraint
  forall(s in STUDENTS, c in CLASSES where parent[c]!=cst_null_class)(
     enrolled(s,c) -> enrolled(s,parent[c])
    )
;

% % % PROGRAMMATION/ENROLEMENT (SEQUENCAGE PAR ETUDIANT)
% % (c-r-2) [souple] Une pénalité de 1 est encourue pour tout étudiant et toute paire de classes dans lequelles il est enrôlé si leurs séances se chevauchent ou ne garantissent pas un temps de déplacement suffisant entre leurs salles le cas échéant.
% % !! Clause restreinte aux cours auxquels l'étudiant est inscrit du fait de (c-e-1) et non explicitement conditionnée à leur ouverture du fait de (c-e-2)
% constraint
%   forall(e in STUDENTS)(
%     x_p_student[e] == 0
% %      sum(c1,c2 in CLASSES where c1<c2 /\ c1 in student_classes[e] /\ c2 in student_classes[e])(
% %        1 - bool2int(
% %          (enrolled(e,c1) /\ enrolled(e,c2))
% %          ->
% %          same_attendees({c1,c2})
% %        )
% %      )
%   )
% ;

constraint
  forall(c in CLASSES)(
    x_w_start[c] in classWeeklySlots(c)
  )
;

constraint
  forall(c in CLASSES)(
    x_w_start[c] == time_start[x_time[c]] + (min(time_days[x_time[c]])-1)*nr_slots_per_day
  )
; %timeWeeklySlot(x_time[c])


constraint
  forall(e in STUDENTS, c in CLASSES)(
    x_ec_duration[e,c] == bool2int(enrolled(e,c))
  )
;

constraint
  forall(r in ROOMS, c in CLASSES)(
    x_rc_duration[r,c] == bool2int(x_room[c]==r)
  )
;

constraint
  forall(e in STUDENTS, w in WEEKS where student_week_classes[e,w]!={})(
      disjunctive(
        [x_w_start[c] | c in student_week_classes[e,w]],
        [x_ec_duration[e,c] | c in student_week_classes[e,w]]
      )
    )
;

%% Contrainte de capacité redondante
% constraint
%   forall(e in STUDENTS, s in SLOTS where {t | t in student_times[e] where open_slots[t,s]==1}!={})(
%      sum(t in student_times[e] where open_slots[t,s]==1)(bool2int(x_time[class[t]]==t)*bool2int(enrolled(e,class[t]))) <= 1
%   )
% ;

%% POSITIONNEMENT (CAPACITE DE SALLE REELLE)
% (c-a-3) [dure] Une salle doit avoir une capacité d'accueil suffisante pour héberger l'effectif enrôlé dans chacune des classes qui l'occupe.
constraint
   forall(r in ROOMS, c in room_classes[r])(
      (x_rc_duration[r,c]==1) -> (capacity[r]>=x_headcount[c]) 
   )
;

%% POSITIONNEMENT (PRE-FERMETURES ET SEQUENCEMENT PAR SALLE RELLE)
% (c-a-4) [dure] Une salle ne peut être allouée qu'à une classe à la fois par créneau, et en dehors de ses créneaux de fermeture.
% contrainte d'ordonnancement disjonctif : puisqu'une salle ne peut être allouée qu'à une seule séance par unité de temps, on utilise la contrainte `disjunctive`(équivalente à contrainte `cumulative` avec capacité de salle fixée à 1) et on simule l'occupation des créneaux sur les périodes prédéfinies de fermeture
% !! Clause restreinte aux salles autorisées pour une classe du fait de (c-a-1)

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS where c1, c2 in CLASSES where c1 < c2 /\ x_room[c1] == r /\ x_room[c2] == r)(
%     not_overlap([c1,c2])
%   )
% ;

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS, s in SLOTS where {t | t in room_times[r] where open_slots[t,s]==1}!={})(
% %   trace("\n room : "++ show(r) ++ " - slot " ++ show(s) ++ " - room_closed_slot " ++ show(room_closed_slots[r,s]) ++  "classes " ++ show({class[t] | t in room_times[r] where open_slots[t,s]==1}) ++  "times " ++ show({t | t in room_times[r] where open_slots[t,s]==1}),true) /\
%        sum(t in room_times[r] where open_slots[t,s]==1)(bool2int(x_time[class[t]]==t)*bool2int(x_room[class[t]]==r)) <= (1 - room_closed_slots[r,s])
%   ) 
% ;

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS, s in SLOTS where room_closed_slots[r,s]==0 /\  {t | t in room_times[r] where open_slots[t,s]==1}!={})(
%        atmost(1,[(x_time[class[t]]==t /\ x_room[class[t]]==r) | t in room_times[r] where open_slots[t,s]==1],true)
%   ) 
% ;

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS, s in SLOTS where room_closed_slots[r,s]==1 /\  {t | t in room_times[r] where open_slots[t,s]==1}!={})(
%        forall(t in room_times[r] where open_slots[t,s]==1)(x_time[class[t]]!=t \/ x_room[class[t]]!=r)
%   ) 
% ;

constraint
  forall(r in ROOMS, w in WEEKS where room_week_classes[r,w]!={})(
    let { array[int] of WEEKLY_SLOTS : room_closure_weekly_slots = [weeklySlot(weekday[s],dayslot[s]) | s in SLOTS where week[s]==w /\ room_closed_slots[r,s]==1];
           array[int] of DURATION : room_closure_count = [1 | s in index_set(room_closure_weekly_slots)];
    }
    in
      disjunctive(
        [x_w_start[c] | c in room_week_classes[r,w]] ++ room_closure_weekly_slots,
        [x_rc_duration[r,c] | c in room_week_classes[r,w]] ++ room_closure_count
      )
    )
;

%% Contrainte de capacité redondante : sur pool de salles interchangeables par semaine
array[ROOMS,WEEKS] of set of ROOMS: room_pool = array2d(ROOMS,WEEKS,[{ rj | rj in ROOMS where room_week_classes[ri,w]==room_week_classes[rj,w] /\ room_classes[rj]==room_classes[ri]} | ri in ROOMS, w in WEEKS]);
constraint
  forall(r in ROOMS, w in WEEKS where card(room_pool[r,w])>1 /\ r==min(room_pool[r,w]))(
    let { array[int] of SLOTS : room_closure_slots = [s | s in SLOTS where week[s]==w /\ exists(r in room_pool[r,w])(room_closed_slots[r,s]==1)];
           array[int] of WEEKLY_SLOTS : room_closure_weekly_slots = [weeklySlot(weekday[s],dayslot[s]) | s in room_closure_slots];
           array[int] of DURATION : room_closure_count = [card({rj | rj in room_pool[r,w] where room_closed_slots[r,s]==1}) | s in room_closure_slots];
    }
    in
   trace("\n room : "++ show(r) ++ "room pool " ++ show(room_pool[r,w]),true) /\
      cumulative(
        [x_w_start[c] | c in room_week_classes[r,w]] ++ room_closure_weekly_slots, % start times
        [1 | c in room_week_classes[r,w]] ++ room_closure_count, % durations
        [1 | c in room_week_classes[r,w]] ++ room_closure_count, % consumption
        card(room_pool[r,w]) % capacity
      )
    )
;

%% POSITIONNEMENT (PRE-FERMETURES ET ORDONNANCEMENT PAR SALLE RELLE)
% (c-a-5) [dure] Une salle doit avoir une capacité d'accueil suffisante pour héberger l'effectif enrôlé dans chacune des classes qui l'occupe en dehors de ses créneaux de fermeture.
% constraint
%   forall(r in ROOMS)(
%     let{
%       var set of CLASSES: cds = {c | c in CLASSES where x_room[c] == r} % cds : classes dans salle
%     } in
%       forall(cc in cds)(
%         let{
%           var set of CLASSES: meme_temp = {c | c in cds where 
%             time_weeks[x_time[c]] intersect time_weeks[x_time[cc]] != {}
%             /\
%             time_days[x_time[c]] intersect time_days[x_time[cc]] != {}
%             /\
%             (
%               (time_start[x_time[c]] + time_length[x_time[c]] > time_start[x_time[cc]] /\ time_start[x_time[c]] < time_start[x_time[cc]])
%               \/
%               (time_start[x_time[cc]] + time_length[x_time[cc]] > time_start[x_time[c]] /\ time_start[x_time[cc]] < time_start[x_time[c]])
%             )
%             }
%         } in
%         sum(cla in meme_temp)(x_headcount[cla]) <= capacity[r]
%       )
%   )
% ;

% same_start
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_start)(
      same_start([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_start)(
      x_p_distribution[m] = (1 - bool2int(same_start([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;


% same_time
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_time)(
      same_time([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_time)(
      x_p_distribution[m] = (1 - bool2int(same_time([c | c in distribution_scope[m]]))) * card(distribution_scope[m])

    )
;

% different_time
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_time)(
      different_time([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_time)(
      x_p_distribution[m] = (1 - bool2int(different_time([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_days
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_days)(
      same_days([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_days)(
      x_p_distribution[m] = (1 - bool2int(same_days([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% different_days
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_days)(
      different_days([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_days)(
      x_p_distribution[m] = (1 - bool2int(different_days([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_weeks
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_weeks)(
      same_weeks([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_weeks)(
      x_p_distribution[m] = (1 - bool2int(same_weeks([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% different_weeks
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_weeks)(
      different_weeks([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_weeks)(
      x_p_distribution[m] = (1 - bool2int(different_weeks([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_room
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_room)(
      same_room([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_room)(
      x_p_distribution[m] = (1 - bool2int(same_room([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% different_room
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_room)(
      different_room([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_room)(
      x_p_distribution[m] = (1 - bool2int(different_room([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% overlap
constraint
  forall(m in typed_distributions[hard] where distribution[m]==overlap)(
      overlap([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==overlap)(
      x_p_distribution[m] = (1 - bool2int(overlap([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% not_overlap
constraint
  forall(m in typed_distributions[hard] where distribution[m]==not_overlap)(
      not_overlap([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==not_overlap)(
      x_p_distribution[m] = (1 - bool2int(not_overlap([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_attendees
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_attendees)(
      same_attendees([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_attendees)(
      x_p_distribution[m] = (1 - bool2int(same_attendees([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

%precedence
constraint
  forall(m in typed_distributions[hard] where distribution[m]==precedence)(
      precedence([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==precedence)(
    let { array[int] of CLASSES: sc = [c | i in CLASSES, c in CLASSES where distribution_classes[m,i]!=0 /\  distribution_classes[m,i]=c]}
    in
      x_p_distribution[m] = (1 - bool2int(precedence(sc))) * length(sc)
    )
;
