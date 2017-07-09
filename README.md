# domoticz_scripts
Scripts for Domoticz made for my personal use

script_device_chaufffage.lua : 
	(EN) script in LUA in order to control group of multilevel selectors (used in real life for controling heaters )
	(FR) script en LUA pour positionner des groupes d'interrupteurs dans Domoticz (utilisés pour contrôler les chauffages) 

	L'intégration des chauffages dans Domoticz est super facile : il suffit d'intégrer chaque chauffage (=fil pilote) en créant des "dummy device" en tant que "multilevel selector" et d'associer les commandes http://remora/?setfp=5a (h, e, c).
		
	On peut utiliser la même méthode pour créer des groupes de chauffage, et les commander avec des commandes groupées : par exemple http://remora/?fp=AAAAAAA	(tous les chauffages) ou http://remora/?fp=---A-A- (chauffage 4 et 6). Mais quand on clique dessus, les boutons individuels de chaque chauffage ne changent pas d'état.
		
	Je vous propose ici un script qui permet de gérer cela : https://github.com/laurentlemercier/domoticz_scripts . Le macrochauffage fait basculer l'état des chaufffages individuels, mais le changement des chauffages individuels fait aussi basculer l'état des macrochauffages (à Unused quand tous les chauffages n'ont pas le même état, à l'état partagé par tous les chauffages sinon)
		
	1/ dans domoticz, vous définissez vos chauffages individuels (avec les actions http), vos groupes de chauffage (macrochauffage)
	2/ vous paramétrez le script script_device_chauffage.lua en reprenant les valeurs que vous avez définies dans Domoticz et en fonction des groupes que vous voulez créer
	3/ vous positionnez le script script_device_chauffage.lua dans le répertoire domoticz/scripts/lua
        4/ vous testez chaque niveau de macrochauffage afin que les variables soient créées automatiquement
        5/ vous pouvez maintenant jouer avec les  différents chauffages et voir le basculement des différents états
	
	Il y a une option DEBUG dans le script qui rend les logs de Domoticz plus verbeux, utile pour la mise au point. Le script est fourni "as is", sans garantie. Je suis preneur de vos retours.
		
	Vous pouvez ainsi utiliser la puissance de Domoticz (gestion du planning, intégration avec d'autres capteurs) et toute la puissance de Remora.

		
script_time_checkremora.lua : 
	(EN) script in LUA in order to check/set the value of Remora board inside Domoticz 
	(FR) script en LUA pour vérifier/repositionner les valeurs de Remora au sein de Domoticz
        1/ vous paramétrez le script script_time_checkremora.lua en reprenant exactement le nom des devices définis dans Domoticz 
	2/ vous positionnez le script script_time_checkremora.lua dans le répertoire domoticz/scripts/lua
	3/ un changement d'état dans Remora est maintenant détecté au bout d'une minute par Domoticz


