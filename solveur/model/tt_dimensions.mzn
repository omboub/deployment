%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIMENSIONS

%% DIMENSIONS LUES EN ENTREE
int: nr_weeks; % nombre de semaines sur l'horizon de temps
int: nr_days_per_week; % nombre de jours par semaine 
int: nr_slots_per_day; % nombre de créneaux par jour 
int: nr_courses; % nombre total de cours 
int: nr_configs; % nombre total de configurations 
int: nr_subparts; % nombre total de classes-type
int: nr_classes; % nombre total de classes
int: nr_times; % nombre total de (programmes de) séances de classes
int: nr_rooms; % nombre total de salles
int: max_capacity; % capacité maximale de salle recensée
int: nr_closures; % nombre total de (programmes de) fermetures de salles
int: nr_students; % nombre total d'étudiants
int: nr_distributions; % nombre total de contraintes de distribution

%% DIMENSIONS AUXILIAIRES
int: nr_criteria = 4;
int: nr_slots = nr_weeks * nr_days_per_week * nr_slots_per_day; % rang du dernier créneau de l'horizon
