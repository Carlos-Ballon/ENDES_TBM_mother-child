global ruta_endes "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024"

********************************************************************************
* PASO 1: Preparar bases de datos de anemia
********************************************************************************
use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\RECH0_2024.dta"
sort HHID
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save RECH0_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\RECH1_2024.dta"
sort HHID HVIDX
rename HVIDX HC0
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save RECH1_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\RECH4_2024.dta"
sort HHID IDXH4
rename IDXH4 HC0
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save RECH4_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\RECH23_2024.dta"
sort HHID
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save RECH23_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\RECH6_2024.dta"
sort HHID HC0
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save RECH6_2024.dta, replace
clear

********************************************************************************
* PASO 2: 1ra Unión de bases de datos
********************************************************************************
use RECH23_2024.dta
merge 1:1 hhid using RECH0_2024.dta, nogenerate
save rech0_rech23.dta, replace

use RECH1_2024.dta, clear
merge 1:1  hhid hc0  using  RECH4_2024.dta, nogen
merge 1:1  hhid hc0  using  RECH6_2024.dta
rename _m rech6
save rech1_rech4_rech6.dta, replace
 
use rech1_rech4_rech6.dta, clear
merge m:1 hhid using rech0_rech23.dta
save anemiafinal.dta, replace
clear

********************************************************************************
* PASO 3: Preparar bases de datos de EDA e IRA
********************************************************************************

global ruta_endes "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024"

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\REC0111_2024.dta"
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save REC0111_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\REC91_2024.dta"
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save REC91_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\REC21_2024.dta"
rename BIDX MIDX
sort CASEID MIDX
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save REC21_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\REC42_2024.dta"
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save REC42_2024.dta, replace
clear

use "C:\Users\RODRIGO\OneDrive\rodrigo.dagasoto\Anterior drive\Escritorio\ENDES 2024\REC43_2024.dta"
rename HIDX MIDX
ds
foreach v in `r(varlist)' {
    local newname = lower("`v'")
    capture confirm variable `newname'
    if _rc {
        rename `v' `newname'
    }
}
ds
save REC43_2024.dta, replace
clear

********************************************************************************
* PASO 4: 2da Unión de bases de datos
********************************************************************************

use REC0111_2024.dta
merge 1:1 caseid using REC91_2024.dta, nogen
merge 1:1 caseid using REC42_2024.dta, nogen
save rec0111_rec91_rec42.dta, replace
clear

use REC21_2024.dta
merge 1:1 caseid midx using REC43_2024.dta, nogen
save rec21_rec43.dta, replace

use rec0111_rec91_rec42.dta, clear
merge 1:m caseid using rec21_rec43.dta, nogen
save edaira.dta, replace



*********************************













********************************************************************************
* PASO 3: Peso muestral
********************************************************************************
gen peso =HV005/1000000

********************************************************************************
* PASO 4: Variable anemia categorizada en menores de 6 a 35 meses
********************************************************************************
gen     anemia=HC57A if HV103==1 &  HC1<36
replace anemia=.    if HC57==9
label define anemia 1 "Severa" 2 "Moderada" 3 "Leve" 4 "Sin anemia"
label values anemia anemia 
tab HV025 anemia [iweight=peso], row
tab SHREGION anemia [iweight=peso], row

********************************************************************************
* PASO 4: Variable combustible
********************************************************************************
gen combustible_cat = .

replace combustible_cat = 1 if inlist(HV226, 1, 2, 3) // Electricidad, GLP, Gas natural
replace combustible_cat = 2 if inlist(HV226, 4, 5, 6, 7, 8, 9, 10) // Kerosene, Carbones, Leña, Bosta, etc.
replace combustible_cat = 3 if inlist(HV226, 11, 96) // No cocina u otro

label define combustible_cat 1 "Limpio/moderno" ///
                             2 "Contaminante/biomasa" ///
                             3 "No cocina/Otro"
label values combustible_cat combustible_cat

********************************************************************************
* PASO 4: Variable anemia dictomica en menores de 6 a 35 meses
********************************************************************************
gen anemia_b_6a35 = .
replace anemia_b_6a35 = 1 if inlist(anemia, 1, 2, 3)   // Anemia
replace anemia_b_6a35 = 0 if anemia == 4              // Sin anemia
label define anemia_b_6a35 0 "Sin anemia" 1 "Anemia"
label values anemia_b_6a35 anemia_b_6a35


********************************************************************************
* PASO 5: Variable anemia dictomica en menores 35 meses
********************************************************************************
gen anemia_b_m35 = .
replace anemia_b_m35 = 1 if inlist(anemia, 1, 2, 3)   // Anemia
replace anemia_b_m35 = 0 if anemia == 4              // Sin anemia
label define anemia_b_m35 0 "Sin anemia" 1 "Anemia"
label values anemia_b_m35 anemia_b_m35


----------------------------

********************************************************************************
* PASO : Tablas bivariadas anemia en menores de 6 a 35 meses
********************************************************************************
svy, over(HV025):    proportion ANEMIA
svy, over(SHREGION): proportion ANEMIA
svy, over(ambito):   proportion ANEMIA
svy, over(HV270):    proportion ANEMIA


stepwise, pe(0.10): logistic anemia_bin i.combustible_cat i.HV025 ///
    c.HC1 i.HC27 i.HC61 i.HV201 i.HV205 i.HV209 i.HV206 i.HV213

----------------------------

********************************************************************************
* PASO 7: Configuración del diseño muestral complejo
********************************************************************************
svyset HV021 [pw=HV005], strata(HV022)

********************************************************************************
* PASO 8: Generación de variables binarias clave para análisis
********************************************************************************
gen anemia_bin = (HA57 < 4) if HA57 < .
gen dcc_bin = (HA5 < -200) if HA5 < .
gen diarrea_bin = (H12A == 1) if H12A < .
gen fiebre_bin = (H22 == 1) if H22 < .
gen ira_bin = (H31 == 1 & H31B == 1) if H31 < . & H31B < .

********************************************************************************
* PASO 9: Análisis de agrupamiento (K-means)
********************************************************************************
cluster kmeans anemia_bin dcc_bin diarrea_bin fiebre_bin ira_bin, k(3) name(clusters_salud) measure(L2) reps(100) start(random)
predict cluster_id, cname(clusters_salud)

********************************************************************************
* PASO 10: Regresión logística multinomial ajustada por diseño muestral
********************************************************************************
svy: mlogit cluster_id i.HV024 i.HV025 HV040, base(1) rrr

********************************************************************************
* PASO 11: Modelos de Ecuaciones Estructurales (SEM)
********************************************************************************
gsem (cluster_id <- HV024 HV025 HV040), mlogit
estat gof, stats(all)

********************************************************************************