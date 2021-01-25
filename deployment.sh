#!/bin/bash

cp /home/user/M2/Management_de_projet/interfaces-de-saisies-et-de-visualisation-emploi-du-temps/isve-backend/target/isve-backend-0.0.1-SNAPSHOT.jar /home/user/M2/Management_de_projet/deployment
cp /home/user/M2/Management_de_projet/interfaces-de-saisies-et-de-visualisation-emploi-du-temps/isve-solveur/target/isve-solveur-0.0.1-SNAPSHOT.jar /home/user/M2/Management_de_projet/deployment
rm -r /home/user/M2/Management_de_projet/deployment/isve-frontend/*
cp -r /home/user/M2/Management_de_projet/interfaces-de-saisies-et-de-visualisation-emploi-du-temps/isve-frontend/src/main/web/dist/isve-frontend/* /home/user/M2/Management_de_projet/deployment/isve-frontend/
