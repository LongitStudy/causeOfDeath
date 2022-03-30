/*icd20

This .do file derives a variable indicating underlying cause of death variables
using the ICD8, ICD9 and ICD10 underlying cause of death variables

Uses the following variables:
DETH -	ic10ude (underlying cod using icd10 used from 2001 onwards), 
		ic10ufde (final under-lying cause of death using icd10 (2001 onwards)), 
		ucde3dde (underlying cod (1st 3 digits) using icd9 (1/1/1979-31/12/1992),
		icd9ude(underlying cod (4 digit code) using icd9 (1/1/1993-2001),
		icd9ufde (final underlying cod (4 digit code) using icd9 (1/1/1993-2001),
		ucde3cde (underlying cod (1st 3 digits) using icd8 (1/1/1971-4/4/1981)
		deyrbde (year of death)
		
1) Make sure that you change your working directory to your project area
cd "P:\......"

2) Open the dataset that you want to add the derived variable to. Make sure that 
it has all the variables that are in the variables list above)*/
********************************************************************************

gen icd10 = ic10ude
gen icd10a = ic10ufde
gen icd9 = ucde3dde
gen icd9b = icd9ude  
gen icd9c = icd9ufde 
gen icd8 = ucde3cde

* If final cause of death set post 1993 set cause of death to final cause

gen finalflag = real(icd9c)

replace icd9b=icd9c if finalflag >0 & finalflag != .

drop finalflag

gen final10 = trim(icd10a)

replace icd10 = icd10a if final10 != "" & final10 != "-9" & final10 != "-8" 

drop final10 icd10a icd9c

* Code to split cause of death into Ischaemic Heart Disease, Stroke, Pulmonary Disease, Lung Cancer and Other Cancers
* Note default value 0 = still alive

gen byte udcod = 0

*1 IHD
replace udcod = 1 if inrange(icd9,"410","414")
replace udcod = 1 if inrange(icd9b,"410 ","4149")
replace udcod = 1 if inrange(icd8,"410","414")
replace udcod = 1 if inrange(icd10,"I20 ","I259")

*2 Stroke
replace udcod = 2 if inrange(icd9,"430","439")
replace udcod = 2 if inrange(icd9b,"4300","4399")
replace udcod = 2 if inrange(icd8,"430","438")
replace udcod = 2 if inrange(icd10,"I60","I639")
replace udcod = 2 if icd10 == "G464" | icd10 == "G463"
replace udcod = 2 if udcod  ==0 & match(icd9,"674")
replace udcod = 2 if udcod  ==0 & inrange(icd9b,"674 ","6749")

*3 Pulmonary Disease
replace udcod = 3 if inrange(icd9,"490","496")
replace udcod = 3 if inrange(icd9b,"4900","4969")
replace udcod = 3 if inrange(icd8,"490","493")
replace udcod = 3 if inrange(icd8,"480","486")
replace udcod = 3 if inrange(icd8,"500","519")

replace udcod = 3 if icd8 == "516" | icd8 == "518" | icd8 == "783"
replace udcod = 3 if match(icd10,"J*")
replace udcod = 3 if inrange(icd9,"460","489")
replace udcod = 3 if inrange(icd9b,"4600","4899")
replace udcod = 3 if inrange(icd9,"500","519")
replace udcod = 3 if inrange(icd9b,"500 ","5199")

*4 Lung Cancer
replace udcod = 4 if icd9 =="162"
replace udcod = 4 if inrange(icd9b,"1620","1629")
replace udcod = 4 if icd8 =="162"
replace udcod = 4 if icd10 == "D022"
replace udcod = 4 if match(icd10,"C34*")

* 5Other Cancers
* All malignant neoplasms
replace udcod = 5 if match(icd10,"C*") & udcod ==0
replace udcod = 5 if inrange(icd9,"140","161")
replace udcod = 5 if inrange(icd9,"163","208")
replace udcod = 5 if inrange(icd9b,"1400","1619")
replace udcod = 5 if inrange(icd9b,"1630","2089")
replace udcod = 5 if inrange(icd8,"140","161")
replace udcod = 5 if inrange(icd8,"163","209")

* 6 Infectious and Parasitic Diseases
replace udcod=6 if match(icd10,"A*")
replace udcod=6 if match(icd10,"B*")
replace udcod=6 if match(icd10,"H6*")
replace udcod=6 if inrange(icd9,"001","139")
replace udcod=6 if inrange(icd9b,"001 ","1399")
replace udcod=6 if inrange(icd8,"000","136")
replace udcod=6 if inrange(icd8,"460","474")

* 7 "Diabetes mellitus" 
replace udcod = 7 if inrange(icd10,"E10 ","E149")
replace udcod = 7 if match(icd9,"250")
replace udcod = 7 if inrange(icd9b,"250 ","2509")
replace udcod = 7 if match(icd8,"250")

* 8 Intestinal disease
replace udcod = 8 if inrange(icd10,"K1  ","K699")
replace udcod = 8 if match(icd10,"K9*")
replace udcod=8 if inrange(icd9,"530","569")
replace udcod=8 if inrange(icd9b,"530 ","5699")
replace udcod=8 if inrange(icd9,"570","576")
replace udcod=8 if inrange(icd9b,"570 ","5769")
replace udcod=8 if inrange(icd9,"577","579")
replace udcod=8 if inrange(icd9b,"577 ","5799")
replace udcod=8 if inrange(icd8,"784","785")
replace udcod=8 if inrange(icd8,"530","569")
replace udcod=8 if inrange(icd8,"750","751")

* 9 Liver Disease
replace udcod = 9 if inrange(icd10,"K7  ","K899")
replace udcod=9 if inrange(icd9,"570","576")
replace udcod=9 if inrange(icd9b,"570 ","5769")
replace udcod=9 if inrange(icd8,"570","576")

*10 Mental and behavioural
replace udcod = 10 if match(icd10,"F*")
replace udcod=10 if inrange(icd9,"290","319")
replace udcod=10 if inrange(icd9b,"290 ","3199")
replace udcod=10 if inrange(icd8,"290","315")
replace udcod=10 if match(icd8,"794")

*11 Abnormalities & Lab Results
replace udcod = 11 if match(icd10,"R*")
replace udcod = 11 if match(icd10,"Q*")
replace udcod=11 if inrange(icd9,"740","759")
replace udcod=11 if inrange(icd9b,"740 ","7599")
replace udcod=11 if inrange(icd9,"780","799")
replace udcod=11 if inrange(icd9b,"780 ","7999")
replace udcod = 11 if icd8 == "788" | icd8 == "792" |icd8 == "796"

* 12 Other Circulatory diseases
replace udcod = 12 if udcod  ==0 & match(icd10,"I*")
replace udcod = 12 if udcod  ==0 & inrange(icd9,"390","409")
replace udcod = 12 if udcod  ==0 & inrange(icd9,"415","429")
replace udcod = 12 if udcod  ==0 & inrange(icd9,"439","459")
replace udcod = 12 if udcod  ==0 & inrange(icd9b,"390 ","4099")
replace udcod = 12 if udcod  ==0 & inrange(icd9b,"415 ","4299")
replace udcod = 12 if udcod  ==0 & inrange(icd9b,"439 ","4599")
replace udcod = 12 if udcod  ==0 & inrange(icd9,"671","673")
replace udcod = 12 if udcod  ==0 & inrange(icd9b,"671 ","6739")
replace udcod = 12 if udcod  ==0 & icd8 == "782" 
replace udcod = 12 if udcod  ==0 & inrange(icd8,"393","404")
replace udcod = 12 if udcod  ==0 & inrange(icd8,"420","429")
replace udcod = 12 if udcod  ==0 & inrange(icd8,"440","458")

* 13 Accidents & Self Harm
replace udcod = 13 if udcod ==0 & match(icd10,"X*")
replace udcod = 13 if udcod ==0 & match(icd10,"V*")
replace udcod = 13 if udcod ==0 & inrange(icd10,"Y600","Y699")
replace udcod = 13 if udcod ==0 & inrange(icd10,"Y40 ","Y599")
replace udcod = 13 if udcod ==0 & match(icd10,"S72*")
*replace udcod = 13 if inrange(icd9b,"8000","9999") // not for this time period
replace udcod = 13 if inrange(icd9,"800","999")
replace udcod = 13 if udcod  ==0 & match(icd10,"W*")
replace udcod = 13 if udcod  ==0 & match(icd9,"E*")
replace udcod = 13 if udcod  ==0 & match(icd9b,"E*")
replace udcod = 13 if inrange(icd8,"800","999")

* 14 Muscular Disease
replace udcod= 14 if match(icd10,"M*")
replace udcod  = 14 if inrange(icd9b,"710 ","7399")
replace udcod  = 14 if inrange(icd9,"710","739")
replace udcod  = 14 if inrange(icd8,"732","734")

* 15 Benign Neoplasms
replace udcod =15 if match(icd10,"D*")
replace udcod  = 15 if inrange(icd9b,"210 ","2399")
replace udcod  = 15 if inrange(icd9,"210","239")
replace udcod  = 15 if inrange(icd8,"210","239")

* 16 Nervous System Diseases
replace udcod =16 if match(icd10,"G*")
replace udcod  = 16 if inrange(icd9b,"320 ","3899")
replace udcod  = 16 if inrange(icd9,"320","389")
replace udcod  = 16 if (icd8 == "781" | icd8 == "780" | icd8 =="794" | icd8 == "790")
replace udcod  = 16 if inrange(icd8,"320","359")

* 17 Genito-Urinary
replace udcod =17 if match(icd10,"N*")
replace udcod  = 17 if inrange(icd9b,"580 ","6299")
replace udcod  = 17 if inrange(icd9,"580","629")
replace udcod  = 17 if icd8 == "786" | icd8 == "789" | icd8 =="580"
replace udcod  = 17 if inrange(icd8,"580","629")

* 18 Other Endocrine (Excludes Diabetes)
replace udcod =18 if inrange(icd10,"E00 ","E099")
replace udcod =18 if inrange(icd10,"E15 ","E999")
replace udcod  = 18 if inrange(icd9b,"240 ","2499")
replace udcod  = 18 if inrange(icd9,"240","249")
replace udcod  = 18 if inrange(icd9b,"251 ","2599")
replace udcod  = 18 if inrange(icd9,"251","259")
replace udcod  = 18 if inrange(icd8,"251","259")
replace udcod  = 18 if inrange(icd8,"240","249")

* 19 Skin
replace udcod=19 if match(icd10,"L*")
replace udcod=19 if inrange(icd9,"680","709")
replace udcod=19 if inrange(icd9b,"680 ","7099")
replace udcod=19 if inrange(icd8,"680","709")

* 20Remains
replace udcod = 20 if udcod == 0 & deyrbde != .

label define cause 0 "Alive" 1 "IHD" 2 "Stroke" 3 "Pulmonary Disease" 4 "Lung Cancer" 5 "Other Cancers" /*
*/ 6 " Infectious&Parasitic" 7 "Diabetes" 8 "Intestinal Disease" 9 "Liver Disease" 10 "Mental & Behavioural" /*
*/11 "Abnormalities & Lab results" 12 "Other Circulatory Disease" 13 "Accidents etc" 14 "Muscular Diseases" /*
*/ 15 "Benign Neoplasms" 16 "Nervous System" 17 "Genito-Urinary" 18 "Other Endocrine" 19 "Skin disease" /*
*/ 20 "Other Cause" 


label values udcod cause

tab udcod,m
********************************************************************************

** GENERATING UNDERLYING CAUSE OF DEATH VARIABLE - FINER CLASSIFICATION

gen finecause = .

label variable finecause "Underlying Cause of Death - fine classification"

label define fc 1 "Infectious&Parasitic" 2 "Diabetes" 3 "Pneumonia" 4 "Stomach Neoplasm"/*
*/5 "Neoplsm:Colon,Rectum,Anun" 6 "Neoplasm: Pancreas"  /*
*/7 "Neop:Larynx,Trachea,Lung" 8 "Neop:Breast" 9 "Other Neoplasms" 10 "Intestinal Disease" /*
*/ 11 "Liver Disease" 12 "IHD" 13 "CerebrVascu" 14 "Mental&Behavioural" 15 "Abnormalities & Lab Results" /*
*/16 "Respiratory System" 17 "Other Circulatory" 18 "Muscular Disease" 19 "Accident&Violence" /*
*/20 "Accidental Poisoning" 21 "Suicide/Self Harm" 22 "Assault" 23 "Undetermined intent" 24 "Other Accident&Violence"/*
*/25 "Benign Neoplasm" 26 "Nervous System" 27 "Other Respiratory" 28 "Genito-Urinary" 29 "Other Endocrine" /*
*/30 "Metabolic" 31 "Skin Disease" 32 "Other digestive" 33 "Pregnancy Complications" 35 "Cause Unknown"

label values finecause fc

* 1 Infections
replace finecause = 1 if udcod==6

*2 Diabetes
replace finecause =2 if udcod==7

* 3 Pneumonia
replace finecause = 3 if inrange(icd10,"J00 ","J199")
replace finecause = 3 if inrange(icd9,"480","486")
replace finecause = 3 if inrange(icd9b,"480 ","4869")
replace finecause = 3 if inrange(icd8,"480","486")

* 4 Malignant neoplasm of stomach
replace finecause = 4 if match(icd10,"C16*")
replace finecause = 4 if match(icd9,"151")
replace finecause = 4 if inrange(icd9b,"151 ","1519")
replace finecause = 4 if match(icd8,"151")

* 5 Malignant neoplasm of colon, rectum, anus, anal canal
replace finecause = 5 if match(icd10,"C18*")
replace finecause = 5 if match(icd10,"C19*")
replace finecause = 5 if match(icd10,"C20*")
replace finecause = 5 if match(icd10,"C21*")
replace finecause = 5 if inrange(icd9,"153","154")
replace finecause = 5 if inrange(icd9b,"153 ","1549")
replace finecause = 5 if inrange(icd8,"153","154")

* 6 Malignant neoplasm of pancreas
replace finecause = 6 if match(icd10,"C25*")
replace finecause = 6 if match(icd9,"157")
replace finecause = 6 if inrange(icd9b,"1570","1579")
replace finecause = 6 if match(icd8,"157")

* 7 Malignant neoplasm of larynx, trachea, bronchus and lung
replace finecause = 7 if match(icd10,"C32*")
replace finecause = 7 if match(icd10,"C33*")
replace finecause = 7 if match(icd10,"C34*")
replace finecause = 7 if inrange(icd9,"161","162")
replace finecause = 7 if inrange(icd9b,"161 ","1629")
replace finecause = 7 if inrange(icd8,"161","162")

* 8 Malignant neoplasm of breast
replace finecause = 8 if match(icd10,"C50*")
replace finecause = 8 if match(icd9,"174")
replace finecause = 8 if inrange(icd9b,"174 ","1749")
replace finecause = 8 if match(icd8,"174")

* 9 Recode remaining malignant neoplasms into 'other malignant neoplasms category'
replace finecause = 9 if udcod==5 & finecause==.

* 10 Intestinal disease
replace finecause = 10 if inrange(icd10,"K1  ","K699")
replace finecause = 10 if match(icd10,"K9*")
replace finecause=10 if inrange(icd9,"530","569")
replace finecause=10 if inrange(icd9b,"530 ","5699")
replace finecause=10 if inrange(icd9,"577","579")
replace finecause=10 if inrange(icd9b,"577 ","5799")
replace finecause=10 if inrange(icd8,"530","569")
replace finecause=10 if inrange(icd8,"577","579")

* 11 Liver Disease
replace finecause = 11 if inrange(icd10,"K7  ","K899")
replace finecause=11 if inrange(icd9,"570","576")
replace finecause=11 if inrange(icd9b,"570 ","5769")
replace finecause=11 if inrange(icd8,"570","576")

* Circulatory system
* 12 Ischaemic heart diseases
replace finecause = 12 if match(icd10,"I20*")
replace finecause = 12 if match(icd10,"I21*")
replace finecause = 12 if match(icd10,"I22*")
replace finecause = 12 if match(icd10,"I23*")
replace finecause = 12 if match(icd10,"I24*")
replace finecause = 12 if match(icd10,"I25*")
replace finecause = 12 if inrange(icd9,"410","414")
replace finecause = 12 if icd9b >="410 " & icd9b <="4149"
replace finecause = 12 if inrange(icd8,"410","414")


* 13 Cerebrovascular diseases
replace finecause = 13 if match(icd10,"I6*")
replace finecause = 13 if inrange(icd9,"430","438")
replace finecause = 13 if inrange(icd9b,"430 ","4389")
replace finecause = 13 if inrange(icd8,"430","438")
replace finecause = 13 if inrange(icd9b,"674 ","6749")
replace finecause = 13 if match(icd9,"674")

*14 Mental and behavioural
replace finecause = 14 if match(icd10,"F*")
replace finecause=14 if inrange(icd9,"290","319")
replace finecause=14 if inrange(icd9b,"290 ","3199")
replace finecause=14 if inrange(icd8,"290","315")
replace finecause = 14 if match(icd8,"794")

*15 Abnormalities & Lab Results
replace finecause=15 if match(icd10,"R*")
replace finecause=15 if match(icd10,"Q*")
replace finecause=15 if inrange(icd9,"740","759")
replace finecause=15 if inrange(icd9b,"740 ","7599")
replace finecause=15 if inrange(icd9,"780","799")
replace finecause=15 if inrange(icd9b,"780 ","7999")
replace finecause=15 if inrange(icd8,"740","759")
replace finecause=15 if inrange(icd8,"787","793")
replace finecause=15 if icd8 == "796"

* 16 Respiratory system
replace finecause = 16 if match(icd10,"J40*")
replace finecause = 16 if match(icd10,"J41*")
replace finecause = 16 if match(icd10,"J42*")
replace finecause = 16 if match(icd10,"J43*")
replace finecause = 16 if match(icd10,"J44*")
replace finecause = 16 if match(icd10,"J45*")
replace finecause = 16 if match(icd10,"J46*")
replace finecause = 16 if match(icd10,"J47*")
replace finecause = 16 if inrange(icd9b,"487 ","4969")
replace finecause = 16 if inrange(icd8,"490 ","493")
replace finecause = 16 if inrange(icd9,"487","496")
replace finecause = 16 if inrange(icd9,"460","479")
replace finecause = 16 if inrange(icd9b,"4600","4799")
replace finecause = 16 if inrange(icd9,"500","519")
replace finecause = 16 if inrange(icd9b,"500 ","5199")
replace finecause = 16 if inrange(icd8,"460","474")
replace finecause = 16 if inrange(icd8,"490","519") & finecause==.
replace finecause = 16 if icd8=="783"

* 17Other Circulatory diseases
replace finecause = 17 if finecause ==. & match(icd10,"I*")
replace finecause = 17 if inrange(icd9b,"390 ","4099")
replace finecause = 17 if inrange(icd9b,"415 ","4299")
replace finecause = 17 if inrange(icd9b,"439 ","4599")
replace finecause = 17 if inrange(icd9,"390","409")
replace finecause = 17 if inrange(icd9,"415","429")
replace finecause = 17 if inrange(icd9,"439","459")
replace finecause = 17 if inrange(icd9b,"280 ","2899")
replace finecause = 17 if inrange(icd9,"280","289")
replace finecause = 17 if finecause ==. & inrange(icd9,"671","673")
replace finecause = 17 if finecause ==. & inrange(icd9b,"671 ","6739")
replace finecause = 17 if inrange(icd8,"280","289")
replace finecause = 17 if inrange(icd8,"390","409")
replace finecause = 17 if inrange(icd8,"415","429")
replace finecause = 17 if inrange(icd8,"440","458") & finecause ==.
replace finecause = 17 if icd8=="782"

* 18 Muscular disease
replace finecause = 18 if match(icd10,"M*")
replace finecause = 18 if inrange(icd9b,"710 ","7399")
replace finecause  = 18 if inrange(icd9,"710","739")
replace finecause  = 18 if inrange(icd8,"710","739")

* Accidents + violence
* 19 Land traffic & other land transport accidents
replace finecause = 19 if match(icd10,"V0*")
replace finecause = 19 if match(icd10,"V1*")
replace finecause = 19 if match(icd10,"V2*")
replace finecause = 19 if match(icd10,"V3*")
replace finecause = 19 if match(icd10,"V4*")
replace finecause = 19 if match(icd10,"V5*")
replace finecause = 19 if match(icd10,"V6*")
replace finecause = 19 if match(icd10,"V7*")
replace finecause = 19 if match(icd10,"V8*")
replace finecause = 19 if match(icd10,"S72*")
replace finecause = 19 if match(icd9,"80*")
replace finecause = 19 if match(icd9,"81*")
replace finecause = 19 if match(icd9,"82*")
replace finecause = 19 if match(icd9,"83*")
replace finecause = 19 if match(icd9,"84*")
replace finecause = 19 if inrange(icd9,"900","943")
*replace finecause = 19 if inrange(icd9b,"900 ","9439") // not for this time period
*replace finecause = 19 if inrange(icd9b,"800 ","8299") // not for this time period
replace finecause = 19 if inrange(icd9b,"E900 ","E9439")
replace finecause = 19 if inrange(icd9b,"E800 ","E8299")
replace finecause = 19 if match(icd8,"80*")
replace finecause = 19 if match(icd8,"81*")
replace finecause = 19 if match(icd8,"82*")
replace finecause = 19 if match(icd8,"83*")
replace finecause = 19 if match(icd8,"84*")
replace finecause = 19 if match(icd8,"88*")
replace finecause = 19 if match(icd8,"89*")
replace finecause = 19 if inrange(icd8,"900","943")


* 20 Accidental poisonings
replace finecause = 20 if match(icd10,"X4*")
replace finecause = 20 if match(icd9,"85*")
replace finecause = 20 if match(icd9,"86*")
*replace finecause = 20 if inrange(icd9b,"850 ","8699") // not for this time period
replace finecause = 20 if inrange(icd9b,"E850 ","E8699")
replace finecause = 20 if match(icd8,"85*")
replace finecause = 20 if match(icd8,"86*")
replace finecause = 20 if match(icd8,"87*")
replace finecause = 20 if inrange(icd10,"Y40 ","Y599")

* 21 Suicides & sequelae of intentional self-harm
replace finecause = 21 if match(icd10,"X6*")
replace finecause = 21 if match(icd10,"X7*")
replace finecause = 21 if match(icd10,"X80*")
replace finecause = 21 if match(icd10,"X81*")
replace finecause = 21 if match(icd10,"X82*")
replace finecause = 21 if match(icd10,"X83*")
replace finecause = 21 if match(icd10,"X84*")
replace finecause = 21 if match(icd9,"95*")
replace finecause = 21 if inrange(icd9b,"950 ","9599")
replace finecause = 21 if match(icd8,"95*")

* 22 Assaults & sequelae of assaults
replace finecause = 22 if match(icd10,"X85*")
replace finecause = 22 if match(icd10,"X86*")
replace finecause = 22 if match(icd10,"X87*")
replace finecause = 22 if match(icd10,"X88*")
replace finecause = 22 if match(icd10,"X89*")
replace finecause = 22 if match(icd10,"X9*")
replace finecause = 22 if match(icd10,"Y0*")
replace finecause = 22 if match(icd9,"96*")
*replace finecause = 22 if inrange(icd9b,"960 ","9699")// not for this time period
replace finecause = 22 if inrange(icd9b,"E960 ","E9699")
replace finecause = 22 if match(icd8,"96*")

* 23 Event of undetermined intent & sequelae
replace finecause = 23 if match(icd10,"Y1*")
replace finecause = 23 if match(icd10,"Y2*")
replace finecause = 23 if match(icd10,"Y30*")
replace finecause = 23 if match(icd10,"Y31*")
replace finecause = 23 if match(icd10,"Y32*")
replace finecause = 23 if match(icd10,"Y33*")
replace finecause = 23 if match(icd10,"Y34*")
replace finecause = 23 if match(icd9,"98*")
*replace finecause = 23 if inrange(icd9b,"980 ","9899")// not for this time period
replace finecause = 23 if inrange(icd9b,"E980 ","E9899")
replace finecause = 23 if match(icd8,"98*")
replace finecause = 23 if match(icd10,"Y8*")

* 24 Recode remaining accidents and violence into 'other accidental and violent causes category'
* Includes ICD10 T* category for external causes
replace finecause = 24 if finecause ==. & match(icd10,"X*")
replace finecause = 24 if finecause ==. & match(icd10,"T*")
*replace finecause = 24 if finecause ==. & inrange(icd9b,"800 ","9999")// not for this time period
replace finecause = 24 if finecause ==. & inrange(icd9b,"E800 ","E9999")
replace finecause = 24 if finecause ==. & inrange(icd9,"800","999")
replace finecause = 24 if finecause ==. & match(icd10,"W*")
replace finecause = 24 if finecause ==. & match(icd9,"E*")
replace finecause = 24 if finecause ==. & match(icd9b,"E*")
replace finecause = 24 if inrange(icd10,"Y600","Y699")
replace finecause = 24 if finecause ==. & match(icd10,"X5*")
replace finecause = 24 if finecause ==. & inrange(icd8,"800","999")


* 25 Benign Neoplasms
replace finecause =25 if match(icd10,"D*")
replace finecause  = 25 if inrange(icd9b,"210 ","2399")
replace finecause  = 25 if inrange(icd9,"210","239")
replace finecause  = 25 if inrange(icd8,"210","239")

*26 Nervous System Diseases

replace finecause =26 if match(icd10,"G*")
replace finecause  = 26 if inrange(icd9b,"320 ","3899")
replace finecause  = 26 if inrange(icd9,"320","389")
replace finecause  = 26 if inrange(icd8,"320","389")
replace finecause  = 26 if inrange(icd8,"780","781")

*27 Other respiratory
replace finecause =27 if finecause ==. & udcod==3

*28 Genito-Urinary
replace finecause =28 if match(icd10,"N*")
replace finecause  = 28 if inrange(icd9b,"580 ","6299")
replace finecause  = 28 if inrange(icd9,"580","629")
replace finecause  = 28 if inrange(icd8,"580","629")
replace finecause  = 28 if icd8=="786"

* 29 Other Endocrine (Excludes Diabetes)
replace finecause  = 29 if inrange(icd10,"E00 ","E099")
replace finecause  = 29 if inrange(icd10,"E15 ","E699")
replace finecause  = 29 if inrange(icd9b,"240 ","2499")
replace finecause  = 29 if inrange(icd9,"240","249")
replace finecause  = 29 if inrange(icd9b,"251 ","2599")
replace finecause  = 29 if inrange(icd9,"251","259")
replace finecause  = 29 if inrange(icd8,"240","246")
replace finecause  = 29 if inrange(icd8,"251","269")

* 30 Metabolic
replace finecause  = 30 if inrange(icd10,"E70 ","E999")
replace finecause  = 30 if inrange(icd9b,"260 ","2799")
replace finecause  = 30 if inrange(icd9,"260","279")
replace finecause  = 30 if inrange(icd8,"270","279")

* 31 Skin
replace finecause  = 31 if match(icd10,"L*")
replace finecause  = 31 if inrange(icd9,"680","709")
replace finecause  = 31 if inrange(icd9b,"680 ","7099")
replace finecause  = 31 if inrange(icd8,"680","709")

* 32 Other Digestive
replace finecause =32 if inrange(icd9,"527","529")
replace finecause =32 if inrange(icd9b,"527 ","5299")
replace finecause  = 32 if inrange(icd8,"526","528")
replace finecause  = 32 if inrange(icd8,"784","785")

*33 Complications of Pregnancy
replace finecause =33 if finecause==. & inrange(icd9,"630","676")
replace finecause =33 if finecause==. & inrange(icd9b,"630 ","6769")
replace finecause =33 if finecause==. & inrange(icd9,"760","779")
replace finecause =33 if finecause==. & inrange(icd9b,"760 ","7799")
replace finecause =33 if finecause==. & inrange(icd8,"630","678")
replace finecause = 33 if finecause==. & match(icd10,"P*")

* 35 Set all remaining to unknown cause
replace finecause =35 if finecause ==. & udcod>0

tab finecause,m

save "deth.dta", replace
