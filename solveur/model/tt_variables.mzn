%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

%% VARIABLES DE PROGRAMMATION/DEPROGRAMMATION
% (x-r-1) programmation par classe
array[CLASSES] of var TIMES: x_time;

%% VARIABLES DE POSITIONNEMENT/DEPOSITIONNEMENT
% (x-a-1) positionnement par classe
array[CLASSES] of var ROOMS: x_room;

%% VARIABLES D'ENROLEMENT/DESENROLEMENT
% (x-e-1) enrôlement d'étudiant ou désenrôlement par classe-type
array[STUDENTS,SUBPARTS] of var CLASSES_P: x_class; % classe nulle==désenrôlement, classe non-nulle==classe d'enrôlement pour la classe-type

%% VARIABLES DE DIMENSIONNEMENT
% (x-d-1) taille d'effectif enrôlé dans chaque classe
array[CLASSES] of var HEADCOUNT: x_headcount; 

%% VARIABLES DE COUT
% TODO le domaine de chaque variable serait à borner par contraintes ou plage pré-calculée
% (x-p-1) pénalités encourues pour réservation de programme par classe
array[CLASSES] of var COST_RANGE[k_time]: x_p_time; % 
% (x-p-2) pénalités encourues pour allocation de salle par classe
array[CLASSES] of var COST_RANGE[k_room]: x_p_room; % 
% (x-p-3) pénalités encourues pour préférence de séquençage par étudiant
array[STUDENTS] of var COST_RANGE[k_student]: x_p_student; % 
% (x-p-4) pénalités encourues pour préférence de distribution
array[DISTRIBUTIONS] of var COST_RANGE[k_distribution] : x_p_distribution; % COST_RANGE[k_distribution]
% (x-p-5) coût de l'edt
var COST: x_cost;

array[CLASSES] of var WEEKLY_SLOTS: x_w_start;
array[STUDENTS,CLASSES] of var DURATION: x_ec_duration;
array[ROOMS,CLASSES] of var DURATION: x_rc_duration;