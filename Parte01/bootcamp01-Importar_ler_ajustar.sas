/*****************************
*
* Dados do SUS - importando
* http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sih/cnv/qibr.def
*****************************/

libname dataSus 'G:\developer\Bootcamp_DataScience_Alura\SAS_DB';

/* nome da variável deve ter 8 caracteres */
filename procHosp 'G:\developer\Bootcamp_DataScience_Alura\DataSus_PROCEDIMENTOS_HOSPITALARES_DO_SUS-POR_LOCAL_DE_INTERNAÇÃO-BRASIL-20201112.txt' encoding="utf-8";
filename demoAlur 'G:\developer\Bootcamp_DataScience_Alura\A151346189_28_143_208.csv';

options validvarname=v7;
proc import datafile=procHosp
 out=datasus.procHospBR dbms=dlm replace;
 	delimiter=';';
	getnames=yes;
	guessingrows=all;
run;

options validvarname=v7;
proc import datafile=demoAlur
 out=datasus.alurHospBR dbms=dlm replace;
 	delimiter=';';
	guessingrows=all;
	getnames=yes;
	datarow= 5;
run;

data work.configEnvironment;
	sessionTime = time();
	yesterdayWas = intnx('day', today(),-1);
	todayIs =today();

	/*5pm, time of a new file... 
	They use to be delayed and, finally, 2020-04-13, they changed from 61200 (5pm) to 64800 (6pm)*/
	if sessionTime > (19*3600) then /*I decided to get the new file only after 7pm : 7*3600 = */
		dataCSV = todayIs;
	else 
		dataCSV = yesterdayWas;

	/*It doesn't work anymore - you can check in the repo. They have changed the file name.*/
	covidSaude = catx('','"https://covid.saude.gov.br/assets/files/COVID19_',compress(put(dataCSV,yymmddb10.)),'.csv"');
	covidSaude = compress(covidSaude);
	covidBrFileName = compress(put(dataCSV,yymmddb10.));
run;

proc sql;
	select covidSaude
	into :covidSaude
	from work.configEnvironment;
quit;