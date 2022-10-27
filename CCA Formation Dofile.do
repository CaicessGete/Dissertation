*Paper 1 Formation of CCAs in IL
import excel "/Users/jd/Desktop/Dissertation/Data/Paper1/IL CCA Formation Data.xlsx", sheet("Sheet1") firstrow
drop if MedianIncome==.
destring Unem20to64, replace force
replace Manager=0 if GovForm==1
save "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation IL.dta", replace

clear
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation IL.dta"

asdoc sum CCARef Ideology GovForm MedianIncome Population HighSchool BachelorOver White Black HispanicLatino Unem MedianAge FuelElectric, dec(2)

*1. Summarize Data and Distribution
describe
summarize CCARef ideology GovForm Manager GovIdeology ManagerIdeology education race unemployment sex MedianIncome Population MedianAge FuelElectric
regress CCARef Ideology GovForm Manager GovIdeology ManagerIdeology Education race Unemployment Sex MedianIncome Population MedianAge FuelElectric
estimates store m1, title(OSL, replace)

predict r, resid
kdensity r, normal

*2. Checking Homoskedasticity of Residuals
regress CCARef ideology GovForm Manager GovIdeology ManagerIdeology education race unemployment sex MedianIncome Population MedianAge FuelElectric
rvfplot, yline (0)
estat imtest, white
* heteroskedasticity p=.0000; skewness p=.0000; 
* kurtosis p=.0000
estat hettest
* Ho: constant variance p=.0086, reject the null
* to solve, with the Robust option

* Logit Model Assumption Tests

*1. DV should be categorical
tab CCARef
* only 0 and 1

*2. Observations are independent
* checked, no repeated subjects

*3. Multicollinearity
logit CCARef Ideology GovForm BachelorOver HighSchool MedianIncome Population MedianAge FuelElectric 
collin ideology GovForm Manager education race unemployment sex MedianIncome Population MedianAge FuelElectric 
corr ideology GovForm Manager education race unemployment sex MedianIncome Population MedianAge FuelElectric 
* race and ideology are moderatelt correlated (-.66)
* MedianIncome and Education are highly correlated (.8)
* race and MedianIncome are not significant predictors in the model
* drop?

*4. No extreme outliers
logit CCARef ideology GovForm Manager education MedianAge FuelElectric Population sex unemployment
leastlikely
predict r2, resid
iqr r2
* 3 mild outliers, but looks not serious

*5. Linearity of continuous IVs and the logit transformation 
* of the DV
* drop extreme values
scatter CCARef ideology, mlabel(Municipality)
tab ideology
scatter CCARef education, mlabel(Municipality)
tab education
scatter CCARef unemployment, mlabel(Municipality)
tab unemployment
scatter CCARef sex, mlabel(Municipality)
tab sex
scatter CCARef Population, mlabel(Municipality)
tab Population
scatter CCARef MedianAge, mlabel(Municipality)
tab MedianAge
scatter CCARef FuelElectric, mlabel(Municipality)
tab FuelElectric

* Cheking linearity between continuous IVs and the DV odd ratios
logit CCARef ideology GovForm Manager GovIdeology ManagerIdeology education MedianAge FuelElectric Population sex unemployment
predict yhat
twoway scatter yhat ideology, sort ylabel(0 1)
twoway scatter yhat GovForm, sort ylabel(0 1)
twoway scatter yhat Manager, sort ylabel(0 1)
twoway scatter yhat GovIdeology, sort ylabel(0 1)
twoway scatter yhat ManagerIdeology, sort ylabel(0 1)
twoway scatter yhat education, sort ylabel(0 1)
twoway scatter yhat MedianAge, sort ylabel(0 1)
twoway scatter yhat FuelElectric, sort ylabel(0 1)
twoway scatter yhat Population, sort ylabel(0 1)
twoway scatter yhat race, sort ylabel(0 1)
twoway scatter yhat sex, sort ylabel(0 1)
twoway scatter yhat unemployment, sort ylabel(0 1)

* Linearity test and transformation of non-linear continuous IVs
boxtid logit CCARef Ideology MedianAge FuelElectric Population SES Minor, ltolerance (10)
gen population2=Population^-0.26
gen population3=ln(Population)
boxtid logit CCARef ideology GovIdeology ManagerIdeology education MedianAge FuelElectric population2 unemployment sex, ltolerance (10)
boxtid logit CCARef ideology GovIdeology ManagerIdeology education MedianAge FuelElectric population3 unemployment sex, ltolerance (10)
* log Population cannot solve the problem

logit CCARef ideology GovForm Manager GovIdeology ManagerIdeology education MedianAge FuelElectric Population sex unemployment
logit CCARef ideology GovForm Manager GovIdeology ManagerIdeology education MedianAge FuelElectric population2 sex unemployment
* totally different results

* Simple to Complex Logit modeols
logit CCARef Ideology GovForm Manager, robust
estimates store m1, title(Logit 1)

logit CCARef Ideology GovForm Manager Education MedianAge FuelElectric Population Sex Unemployment, robust
estimates store m2, title(Logit 2)

logit CCARef Ideology GovForm Manager c.Ideology#c.GovForm c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, robust
estimates store m3, title(Logit 3)

logit CCARef ideology GovForm Manager GovIdeology education MedianAge FuelElectric Population sex unemployment
logit CCARef ideology GovForm Manager ManagerIdeology education MedianAge FuelElectric Population sex unemployment


* Generalized Additive Model
rename Ideology Ideo
rename GovForm GovF
rename Manager Man
rename GovIdeology GovIde
rename ManagerIdeology MIdeo
rename Education Edu
rename MedianAge MAge
rename FuelElectric FuelE
rename Population Pop
rename Unemployment Unem

which gam
findfile gam.exe
copy "http://fmwww.bc.edu/repec/bocode/g/gam.zip" "`c(sysdir_plus)'g/" , replace
unzipfile "`c(sysdir_plus)'g/gam.zip" , replace

gam CCARef Ideology GovForm Manager GovIdeology ManagerIdeology Education MedianAge FuelElectric Population Sex Unemployment, link(logit)

gam CCARef Ideo GovF Man GovIde MIdeo Edu MAge FuelE Pop Sex Unem, link(logit)

gam CCARef ideology GovForm Manager GovIdeology education MedianAge FuelElectric Population sex unemployment, link(logit)
gam CCARef ideology GovForm Manager ManagerIdeology education MedianAge FuelElectric Population sex unemployment, link(logit)

* the standard logit model and the Generalize Linear model
* give similar results
* Whereas the model with transformed Population
* gives a totally changed image on the ideology (1.95 to -1.43), 
* form of government (slighly significant to very insignificant), 
* and interaction variables (changed signes and significances)
* Population (0.179 to 0.000) became significant

* Generalized Linear Model

glm CCARef Ideology GovForm Manager c.Ideology#c.GovForm c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, link(logit) robust
estimates store m3, title(GLM Logit)

* Fractional Polynomial Model
clear
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation IL.dta"

fp <Population>, power(2.5): logit CCARef Ideology GovForm Manager c.Ideology#c.GovForm c.Ideology#c.Manager Education MedianAge FuelElectric Sex Unemployment <Population>
estimates store m4, title(FPM Logit)

fp plot, residuals(none)
* power=-3, p(m=1) is 0.072, reject at the 0.1 level
* power=-2.5, p=0.001, reject at the 0.1 level
* power=-2, p=0.000
* power=-1.5, p=0.000
* power=-1, p=0.000
* power=-0.5, p=0.000
* power=0, p=0.000
* power=0.5, p=error
* power=1, p=0.000
* power=1.5, p=0.000
* power=2, p=0.044
* power=2.5, p=0.401, fail to reject the null *********selected
* power=3, p=0.966

* Probit model
probit CCARef ideology GovForm Manager, robust
probit CCARef Ideology GovForm Manager GovIdeology ManagerIdeology Education MedianAge FuelElectric Population Sex Unemployment, robust
estimates store m4, title(Probit)

*** Table Output ***
#delimit ;
estout m1 m2 m3 m6 m7, cells(b(star fmt(2)) se(par fmt(2)))  ///
   legend label varlabels(_cons constant)  ///
   starl (* 0.10 ** 0.05 *** 0.01) ///
   stats(N aic bic)
   
*** Marginal Effect Plot
margins, dydx(Ideology) at(GovForm=(0 1))
marginsplot, yline(0)
margins, dydx(GovForm) at(Ideology=(0.2(0.05)0.8))
marginsplot, yline(0)

*** Robustness Check
probit CCARef Ideology GovForm Manager c.Ideology#c.GovForm c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, robust
estimates store m8, title(Probit)

glm CCARef Ideology GovForm Manager c.Ideology#c.GovForm c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, link(probit) robust
estimates store m9, title(GLM Probit)

fp <Population>, power(2.5): probit CCARef Ideology GovForm Manager c.Ideology#c.GovForm c.Ideology#c.Manager Education MedianAge FuelElectric Sex Unemployment <Population>
estimates store m10, title(FPM Probit)

estout m8 m9 m10, cells(b(star fmt(2)) se(par fmt(2)))  ///
   legend label varlabels(_cons constant)  ///
   starl (* 0.10 ** 0.05 *** 0.01) ///
   stats(N aic bic)

logit CCARef Ideology GovForm Manager
logit CCARef Ideology GovForm Manager c.Ideology#c.GovForm Education MedianAge FuelElectric
logit CCARef Ideology GovForm Manager Education MedianAge 
logit CCARef Ideology GovForm Manager Education MedianAge FuelElectric

logit Manager Education FuelElectric MedianAge Population Sex, robust
logit GovForm Education FuelElectric MedianAge Population Sex, robust

logit CCARef Ideology GovForm, robust
logit CCARef Ideology GovForm Education MedianAge FuelElectric Population Sex Unemployment, robust
logit CCARef Ideology GovForm c.Ideology#c.GovForm Education MedianAge FuelElectric Population Sex Unemployment, robust
probit CCARef Ideology GovForm c.Ideology#c.GovForm Education MedianAge FuelElectric Population Sex Unemployment, robust
glm CCARef Ideology GovForm c.Ideology#c.GovForm Education MedianAge FuelElectric Population Sex Unemployment, link(logit) robust
fp <Population>, power(2.5) replace: logit CCARef Ideology GovForm c.Ideology#c.GovForm Education MedianAge FuelElectric Sex Unemployment <Population>


logit CCARef Ideology Manager, robust
logit CCARef Ideology Manager Education MedianAge FuelElectric Population Sex Unemployment, robust
logit CCARef Ideology Manager c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, robust
probit CCARef Ideology Manager c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, robust
glm CCARef Ideology Manager c.Ideology#c.Manager Education MedianAge FuelElectric Population Sex Unemployment, link(logit) robust
fp <Population>, power(3) replace: logit CCARef Ideology Manager c.Ideology#c.Manager Education MedianAge FuelElectric Sex Unemployment <Population>


margins, dydx(Ideology) at(Manager=(0 1))
marginsplot, yline(0)
margins, dydx(Manager) at(Ideology=(0.1(0.1)1))
marginsplot, yline(0)

factor HighSchool BachelorOver MedianIncome FamilyPoverty Unemp
predict SES




clear
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation IL.dta"

import excel "/Users/jd/Desktop/Dissertation/Data/Paper1/IL CCA Formation Data1.xlsx", sheet("Sheet1") firstrow
save "CCA Formation.dta", replace
save "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation.dta", replace
clear
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation.dta"

* Modefying several variables
gen Ideo=Ideology/100
gen Bachelor=BachelorOver/100
gen High=HighSchool/100
gen RWhite=White/100
gen RBlack=Black/100
gen RHL=HispanicLatino/100
gen Minor=RBlack+RHL
destring Unemployment, generate(Unem) force
destring Manager, generate(Ma) force
gen Unemp=Unemployment/100
gen Poverty=FamilyPoverty/100
gen Pop=Population/10000
replace GovForm=0 if GovForm!=1
drop in 1257/1724

* Descriptive Statistics
asdoc sum CCARef Ideo GovForm Minor MedianIncome Pop High Bachelor RWhite RBlack RHL Unemp MedianAge FuelElectric Poverty, dec(2)

* Genrate the Socioeconomic Status Factor Variable
factor High Bachelor MedianIncome Poverty Unemp
predict SES

* Main Models (Logit Models)
logit CCARef Ideo GovForm , robust
logit CCARef Ideo GovForm SES, robust
logit CCARef Ideo GovForm SES Minor, robust
logit CCARef Ideo GovForm SES Minor MedianAge, robust
logit CCARef Ideo GovForm SES Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, robust

logit CCARef Ideo GovForm SES Pop Minor MedianAge FuelElectric, robust

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm SES Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, robust

* Logistic Model that Coefficients Are Odd Ratios (How many times more likely)
logistic CCARef Ideo GovForm
logistic CCARef Ideo GovForm SES Pop Minor MedianAge FuelElectric, robust
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust

* Robustness Checking Models
reg CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
ovtest
gen Ideo2=ln(Ideo)
reg CCARef Ideo2 GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
ovtest
logistic CCARef Ideo2 GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
probit CCARef Ideo2 GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
glm CCARef Ideo2 GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, link(logit) robust

probit CCARef Ideo GovForm, robust
probit CCARef Ideo GovForm SES, robust
probit CCARef Ideo GovForm SES Minor, robust
probit CCARef Ideo GovForm SES Minor MedianAge, robust
probit CCARef Ideo GovForm SES Minor MedianAge FuelElectric, robust
probit CCARef Ideo GovForm SES Pop Minor MedianAge FuelElectric, robust

probit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust

glm CCARef Ideo GovForm, link(logit) robust
glm CCARef Ideo GovForm SES, link(logit) robust
glm CCARef Ideo GovForm SES Minor, link(logit) robust
glm CCARef Ideo GovForm SES Minor MedianAge, link(logit) robust
glm CCARef Ideo GovForm SES Minor MedianAge FuelElectric, link(logit) robust
glm CCARef Ideo GovForm SES Pop Minor MedianAge FuelElectric, link(logit) robust

glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, link(logit) robust
gen GovIdeo=GovForm*Ideo
gam CCARef Ideo GovForm GovIdeo SES Pop Minor MedianAge FuelElectric, link(logit)

boxtid logit CCARef Ideo Pop MedianAge FuelElectric SES Minor, ltolerance (10)
gen Pop2=Pop^-0.11
boxtid logit CCARef Ideo Pop2 MedianAge FuelElectric SES Minor, ltolerance (10)
gen Minor2=Minor^6.5812
boxtid logit CCARef Ideo Pop2 MedianAge FuelElectric SES Minor2, ltolerance (10)

* Population
fp <Pop>, power(1.5) replace: logit CCARef Ideo GovForm SES Minor MedianAge FuelElectric <Pop>

fp <Pop>, power(2) replace: logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric <Pop>

*** Marginal Effect Plot
margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
linktest
predict yhat10
twoway scatter yhat10 Ideo, sort ylabel(0 1)
twoway scatter yhat10 SES, sort ylabel(0 1)
twoway scatter yhat10 MedianAge, sort ylabel(0 1)
twoway scatter yhat10 FuelElectric, sort ylabel(0 1)
twoway scatter yhat10 Pop, sort ylabel(0 1)
twoway scatter yhat10 Minor, sort ylabel(0 1)


* Maximum Likelihood Estimation
program define mylogit
          args lnf Xb
          quietly replace `lnf' = -ln(1+exp(-`Xb')) if $ML_y1==1
          quietly replace `lnf' = -`Xb' - ln(1+exp(-`Xb')) if $ML_y1==0
  end
ml model lf mylogit (CCARef= Ideology GovForm c.Ideology#c.GovForm SES Population Minor MedianAge FuelElectric)
ml maximize

logit CCARef Ideo GovForm SES Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric if Pop<200, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust

probit CCARef Ideo GovForm SES Minor MedianAge FuelElectric, robust
probit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust

glm CCARef Ideo GovForm SES Minor MedianAge FuelElectric, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, link(logit) robust

logit CCARef Ideo GovForm
logit CCARef Ideo GovForm Pop

* Marginal Effects
logistic CCARef Ideo GovForm
logistic CCARef Ideo GovForm SES Pop Minor MedianAge FuelElectric, robust
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust
corr Ideo GovForm SES Pop Minor MedianAge FuelElectric

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)


probit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, robust

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)


glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, link(logit) robust

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)


fp <Pop>, power(2) replace: logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric <Pop>

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)


*** Excluding Pop
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, robust
*** Excluding Minor
logistic CCARef Ideo GovForm c.Ideo#c.GovForm Pop SES MedianAge FuelElectric, robust
*** Excluding Pop and Minor
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES MedianAge FuelElectric, robust
*** Excluding SES
logistic CCARef Ideo GovForm c.Ideo#c.GovForm Pop Minor MedianAge FuelElectric, robust
*** Excluding MedianAge
logistic CCARef Ideo GovForm c.Ideo#c.GovForm Pop SES Minor FuelElectric, robust
*** Excluding FuelElectric
logistic CCARef Ideo GovForm c.Ideo#c.GovForm Pop SES Minor MedianAge, robust


margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)


probit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, robust

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)


glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, link(logit) robust

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

boxtid logit CCARef Ideo SES Minor MedianAge FuelElectric

logistic CCARef Ideo Manager c.Ideo#c.Manager SES Pop Minor MedianAge FuelElectric, robust

logit CCARef Ideo GovForm c.Ideo#c.GovForm, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm Minor, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm MedianAge, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES MedianAge, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm Minor MedianAge, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric Pop, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm Pop, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES FuelElectric Pop, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge Pop, robust

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES MedianAge Pop FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES MedianAge Pop Minor FuelElectric Poverty, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES MedianAge Pop Minor FuelElectric Poverty Bachelor, robust

logit CCARef Ideo GovForm , robust
logit CCARef Ideo GovForm SES, robust
logit CCARef Ideo GovForm SES Minor, robust
logit CCARef Ideo GovForm SES Minor MedianAge, robust
logit CCARef Ideo GovForm SES Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor MedianAge FuelElectric, robust

boxtid logit CCARef Ideo SES Minor Age FuelElectric PopC, ltolerance

logit CCARef Ideo GovForm SES PopC Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor MedianAge FuelElectric, robust
probit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor MedianAge FuelElectric, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor MedianAge FuelElectric, link(logit) robust


gen PopC=1 if Pop<10
replace PopC=0 if Pop<2
replace PopC=1 if Pop>=2 & Pop<4
replace PopC=2 if Pop>=4 & Pop<6
replace PopC=3 if Pop>=6 & Pop<8
replace PopC=4 if Pop>=8 & Pop<10
replace PopC=5 if Pop>=10 & Pop<12
replace PopC=6 if Pop>=12 & Pop<14
replace PopC=7 if Pop>=14 & Pop<16
replace PopC=8 if Pop>=16 & Pop<18
replace PopC=9 if Pop>=18 & Pop<20
replace PopC=10 if Pop>=20


logit CCARef Ideo GovForm SES PopC Minor MedianAge FuelElectric, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor MedianAge FuelElectric, robust
linktest
predict yhat1, xb
twoway scatter yhat1 Ideo, sort ylabel(0 1)
twoway scatter yhat1 SES, sort ylabel(0 1)
twoway scatter yhat1 MedianAge, sort ylabel(0 1)
twoway scatter yhat1 FuelElectric, sort ylabel(0 1)
twoway scatter yhat1 PopC, sort ylabel(0 1)
twoway scatter yhat1 Minor, sort ylabel(0 1)

gen Age=1 if MedianAge<30
replace Age=2 if MedianAge>=30 & MedianAge<40
replace Age=3 if MedianAge>=40 & MedianAge<50
replace Age=4 if MedianAge>=50 & MedianAge<60
replace Age=5 if MedianAge>=60 & MedianAge<90

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age FuelElectric, robust
linktest
predict yhat2, xb
twoway scatter yhat2 Ideo, sort ylabel(0 1)
twoway scatter yhat2 SES, sort ylabel(0 1)
twoway scatter yhat2 Age, sort ylabel(0 1)
twoway scatter yhat2 FuelElectric, sort ylabel(0 1)
twoway scatter yhat2 PopC, sort ylabel(0 1)
twoway scatter yhat2 Minor, sort ylabel(0 1)

gen Fuel=1 if FuelElectric<0.1
replace Fuel=2 if FuelElectric>=0.1 & FuelElectric<0.2
replace Fuel=3 if FuelElectric>=0.2 & FuelElectric<0.3
replace Fuel=4 if FuelElectric>=0.3 & FuelElectric<0.4
replace Fuel=5 if FuelElectric>=0.4 & FuelElectric<0.5
replace Fuel=6 if FuelElectric>=0.5 & FuelElectric<0.6
replace Fuel=7 if FuelElectric>=0.6 & FuelElectric<0.7
replace Fuel=8 if FuelElectric>=0.7 & FuelElectric<0.8

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age Fuel, robust
linktest
predict yhat3, xb
twoway scatter yhat3 Ideo, sort ylabel(0 1)
twoway scatter yhat3 SES, sort ylabel(0 1)
twoway scatter yhat3 Age, sort ylabel(0 1)
twoway scatter yhat3 Fuel, sort ylabel(0 1)
twoway scatter yhat3 PopC, sort ylabel(0 1)
twoway scatter yhat3 Minor, sort ylabel(0 1)

probit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age FuelElectric, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age FuelElectric, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age Fuel, link(logit) robust
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age FuelElectric, robust
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor Age Fuel, robust

checkrob 3 5 result.txt: logit CCARef Ideo GovForm GovIdeo SES PopC Minor Age Fuel, robust
* result checkrob 3
checkrob 3 5 result1.txt: logit CCARef Ideo GovForm GovIdeo SES PopC Minor Age FuelElectric, robust
* result checkrob 2

logit CCARef Ideo GovForm SES PopC MedianAge FuelElectric Minor, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC MedianAge FuelElectric Minor, robust
logistic CCARef Ideo GovForm SES PopC MedianAge FuelElectric Minor, robust
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC MedianAge FuelElectric Minor, robust

margins, dydx(Ideo) at(GovForm=(0 1))
marginsplot, yline(0) xlabel(0(1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

probit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC Minor MedianAge FuelElectric, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC MedianAge FuelElectric Minor, link(logit) robust
fp <MedianAge>, power(-7) replace: logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Minor <MedianAge> FuelElectric PopC
mfp: logit CCARef Ideo GovForm GovIdeo SES PopC MedianAge FuelElectric Minor, robust

checkrob 3 5 result2.txt: logit CCARef Ideo GovForm GovIdeo SES PopC Minor MedianAge FuelElectric, robust

gen PopC2=1 if Pop<1
replace PopC2=2 if Pop>=1 & Pop<2
replace PopC2=3 if Pop>=2 & Pop<3
replace PopC2=4 if Pop>=3 & Pop<4
replace PopC2=5 if Pop>=4 & Pop<5
replace PopC2=6 if Pop>=5 & Pop<6
replace PopC2=7 if Pop>=6 & Pop<7
replace PopC2=8 if Pop>=7 & Pop<8
replace PopC2=9 if Pop>=8 & Pop<9
replace PopC2=10 if Pop>=9 & Pop<10
replace PopC2=11 if Pop>=10

logit CCARef Ideo GovForm SES PopC2 MedianAge FuelElectric Minor, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 MedianAge FuelElectric Minor, robust
logistic CCARef Ideo GovForm SES PopC2 MedianAge FuelElectric Minor, robust
logistic CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 MedianAge FuelElectric Minor, robust
probit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 Minor MedianAge FuelElectric, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 Minor MedianAge FuelElectric, link(logit) robust
mfp: logit CCARef Ideo GovForm GovIdeo SES PopC2 MedianAge FuelElectric Minor, robust

gen Pop5=ln(Pop)
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop5 MedianAge FuelElectric Minor, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric Minor if Municipality!="Chicago", robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop Minor MedianAge FuelElectric, link(logit) robust


*** With Chicago Metropolitan Statistics Area
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 7 result3.txt: logit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL CMA, robust

glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

kdensity CCARef, normal
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC MedianAge FuelElectric RBlack RHL, robust
predict yhat,xb
kdensity yhat, normal
gen lgCCARef=ln(CCARef)
logit lgCCARef Ideo GovForm c.Ideo#c.GovForm SES PopC MedianAge FuelElectric RBlack RHL, robust
drop lgCCARef


logit CCARef Ideo GovForm SES PopC2 MedianAge FuelElectric RBlack RHL CMA, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 MedianAge FuelElectric RBlack RHL CMA, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 MedianAge FuelElectric RBlack RHL CMA, link(logit) robust
mfp: logit CCARef Ideo GovForm GovIdeo SES PopC2 MedianAge FuelElectric RBlack RHL CMA, robust


gen lgPop=ln(Pop)
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES lgPop MedianAge FuelElectric RBlack RHL CMA, robust
predict yhatlog, xb
twoway scatter yhatlog lgPop, sort ylabel(0 1)

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES lgPop MedianAge FuelElectric RBlack RHL CMA if Municipality!="Chicago", robust
predict yhatlog2, xb
twoway scatter yhatlog2 lgPop, sort ylabel(0 1)

glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust


logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA if Municipality!="Chicago", robust


*** Clustering by CMA
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, vce(cluster CMA)
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, robust


*** Plot of Influential Observations: Y=Cook versus X=Observation Number
logit CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, robust
predict cook, dbeta
label variable cook "Cook Distance"
gen index=_n
graph twoway (scatter cook index, msymbol(d)), xlabel(0(100)1000) title("Plot of Cook Distance versus Observation Number") xtitle("Observation Number") ytitle("Cook Distance") caption("cook.png", size(vsmall))

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if cook<0.2, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if cook<0.2, link(logit) robust


*** Excluding Population more than 100,000
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<10, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<10, link(logit) robust

*** Excluding Population more than 80,000
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<8, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<8, link(logit) robust

*** Excluding Population more than 20,000
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<2, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<2, link(logit) robust

*** Excluding Population more than 10,000
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<1, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<1, link(logit) robust

*** Excluding Population more than 5,000
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<0.5, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if Pop<0.5, link(logit) robust


*** Weight & Robust Regression
reg CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL
lvr2plot, mlabel(Municipality)
* Chicago has an extreme leverage

predict d1, cooksd
clist Municipality Ideo Pop MedianAge FuelElectric d1 if d1>4/1253, noobs
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if d1<=4/1253, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if d1<1, robust
checkrob 3 6 result4.txt: logit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL if d1<1, robust

glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL if d1<1, link(log) robust

predict r1, rstandard
gen absr1 = abs(r1)
gsort -absr1
clist Municipality absr1 in 1/10, noobs

rreg CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, gen(weight)
clist Municipality weight if Municipality =="Chicago", noobs

sort weight
clist Municipality Pop Ideo weight absr1 d1 in 1/10, noobs

*** Different links for GLM
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(i) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(log) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(nb) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(loglog) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(logc) robust


** Population divide is 50,000
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD1 MedianAge FuelElectric RBlack RHL, link(logit) robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD1 MedianAge FuelElectric RBlack RHL, robust

checkrob 3 6 result5.txt: glm CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL, link(logit) robust


logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC3 MedianAge FuelElectric RBlack RHL, robust


logit CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL, robust
logit CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust
mfp: logit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL, robust
mfp: logit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL CMA, robust

gen Pop100=Pop*100

*** Log 
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES lgPop MedianAge FuelElectric RBlack RHL, robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES lgPop MedianAge FuelElectric RBlack RHL, link(logit) robust
checkrob 3 6 result7.txt: logit CCARef Ideo GovForm GovIdeo SES lgPop MedianAge FuelElectric RBlack RHL, robust

histogram Pop
histogram lgPop


clear
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation.dta"

asdoc sum CCARef Ideo GovForm Pop RBlack RHL MedianAge FuelElectric SES Franchise, dec(2)

*** Original Population
logit CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL Franchise, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL Franchise, robust

gen GovIdeo=GovForm*Ideo
checkrob 3 6 resultPop.txt: logit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPop_.txt: glm CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL, link(logit) robust

*** With CMA
logit CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, robust
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL CMA, robust

checkrob 3 7 resultPop1.txt: logit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 7 resultPop1_.txt: glm CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

*** Log Pop
gen lgPop=ln(Pop)
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES lgPop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultlgPop.txt: logit CCARef Ideo GovForm GovIdeo SES lgPop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultlgPop_.txt: glm CCARef Ideo GovForm GovIdeo SES lgPop MedianAge FuelElectric RBlack RHL, link(logit) robust

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES lgPop MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 7 resultlgPop1.txt: logit CCARef Ideo GovForm GovIdeo SES lgPop MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 7 resultlgPop1_.txt: glm CCARef Ideo GovForm GovIdeo SES lgPop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

*** Squre-root
gen sqrt_Pop = Pop^(1/2)
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES sqrt_Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultsrPop.txt: logit CCARef Ideo GovForm GovIdeo SES sqrt_Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultsrPop_.txt: glm CCARef Ideo GovForm GovIdeo SES sqrt_Pop MedianAge FuelElectric RBlack RHL, link(logit) robust

histogram sqrt_Pop

*** Cube-root
gen cube_Pop = Pop^(1/3)
histogram cube_Pop
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES cube_Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultcbPop.txt: logit CCARef Ideo GovForm GovIdeo SES cube_Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultcbPop_.txt: glm CCARef Ideo GovForm GovIdeo SES cube_Pop MedianAge FuelElectric RBlack RHL, link(logit) robust

*** Reciprocal
gen re_Pop = 1/Pop
histogram re_Pop
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES re_Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultrePop.txt: logit CCARef Ideo GovForm GovIdeo SES re_Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultrePop_.txt: glm CCARef Ideo GovForm GovIdeo SES re_Pop MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES re_Pop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

*** Log base 10
gen l10Pop = log10(Pop)
histogram l10Pop
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES l10Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultl10Pop.txt: logit CCARef Ideo GovForm GovIdeo SES l10Pop MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultl10Pop_.txt: glm CCARef Ideo GovForm GovIdeo SES l10Pop MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES l10Pop MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

*** Pop Category per 50,000
gen PopC5=0 if Pop<5
replace PopC5=1 if Pop>=5 & Pop<10
replace PopC5=2 if Pop>=10 & Pop<15
replace PopC5=3 if Pop>=15 & Pop<20
replace PopC5=4 if Pop>=20

logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC5 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC5.txt: logit CCARef Ideo GovForm GovIdeo SES PopC5 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC5_.txt: glm CCARef Ideo GovForm GovIdeo SES PopC5 MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC5 MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

*** Pop Category per 20,000
gen PopC2=0 if Pop<2
replace PopC2=1 if Pop>=2 & Pop<4
replace PopC2=2 if Pop>=4 & Pop<6
replace PopC2=3 if Pop>=6 & Pop<8
replace PopC2=4 if Pop>=8 & Pop<10
replace PopC2=5 if Pop>=10 & Pop<12
replace PopC2=6 if Pop>=12 & Pop<14
replace PopC2=7 if Pop>=14 & Pop<16
replace PopC2=8 if Pop>=16 & Pop<18
replace PopC2=9 if Pop>=18 & Pop<20
replace PopC2=10 if Pop>=20

histogram PopC2
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC2.txt: logit CCARef Ideo GovForm GovIdeo SES PopC2 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC2_.txt: glm CCARef Ideo GovForm GovIdeo SES PopC2 MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC2 MedianAge FuelElectric RBlack RHL CMA, link(logit) robust

*** Pop Category per 10,000
gen PopC1=0 if Pop<1
replace PopC1=1 if Pop>=1 & Pop<2
replace PopC1=2 if Pop>=2 & Pop<3
replace PopC1=3 if Pop>=3 & Pop<4
replace PopC1=4 if Pop>=4 & Pop<5
replace PopC1=5 if Pop>=5 & Pop<6
replace PopC1=6 if Pop>=6 & Pop<7
replace PopC1=7 if Pop>=7 & Pop<8
replace PopC1=8 if Pop>=8 & Pop<9
replace PopC1=9 if Pop>=9 & Pop<10
replace PopC1=10 if Pop>=10 & Pop<11
replace PopC1=11 if Pop>=11 & Pop<12
replace PopC1=12 if Pop>=12 & Pop<13
replace PopC1=13 if Pop>=13 & Pop<14
replace PopC1=14 if Pop>=14 & Pop<15
replace PopC1=15 if Pop>=15 & Pop<16
replace PopC1=16 if Pop>=16 & Pop<17
replace PopC1=17 if Pop>=17 & Pop<18
replace PopC1=18 if Pop>=18 & Pop<19
replace PopC1=19 if Pop>=19 & Pop<20
replace PopC1=20 if Pop>=20 

histogram PopC1
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC1 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC1.txt: logit CCARef Ideo GovForm GovIdeo SES PopC1 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC1_.txt: glm CCARef Ideo GovForm GovIdeo SES PopC1 MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC1 MedianAge FuelElectric RBlack RHL CMA, link(logit) robust


predict CCARefPopC1, xb
twoway scatter CCARefPopC1 PopC1
twoway scatter CCARefPopC1 Ideo

*** Pop Category per 5,000
gen PopC0_5=0 if Pop<0.5
replace PopC0_5=1 if Pop>=0.5 & Pop<1
replace PopC0_5=2 if Pop>=1 & Pop<1.5
replace PopC0_5=3 if Pop>=1.5 & Pop<2
replace PopC0_5=4 if Pop>=2 & Pop<2.5
replace PopC0_5=5 if Pop>=2.5 & Pop<3
replace PopC0_5=6 if Pop>=3 & Pop<3.5
replace PopC0_5=7 if Pop>=3.5 & Pop<4
replace PopC0_5=8 if Pop>=4 & Pop<4.5
replace PopC0_5=9 if Pop>=4.5 & Pop<5
replace PopC0_5=10 if Pop>=5 & Pop<5.5
replace PopC0_5=11 if Pop>=5.5 & Pop<6
replace PopC0_5=12 if Pop>=6 & Pop<6.5
replace PopC0_5=13 if Pop>=6.5 & Pop<7
replace PopC0_5=14 if Pop>=7 & Pop<7.5
replace PopC0_5=15 if Pop>=7.5 & Pop<8
replace PopC0_5=16 if Pop>=8 & Pop<8.5
replace PopC0_5=17 if Pop>=8.5 & Pop<9
replace PopC0_5=18 if Pop>=9 & Pop<9.5
replace PopC0_5=19 if Pop>=9.5 & Pop<10
replace PopC0_5=20 if Pop>=10 & Pop<10.5
replace PopC0_5=21 if Pop>=10.5 & Pop<11
replace PopC0_5=22 if Pop>=11 & Pop<11.5
replace PopC0_5=23 if Pop>=11.5 & Pop<12
replace PopC0_5=24 if Pop>=12 & Pop<12.5
replace PopC0_5=25 if Pop>=12.5 & Pop<13
replace PopC0_5=26 if Pop>=13 & Pop<13.5
replace PopC0_5=27 if Pop>=13.5 & Pop<14
replace PopC0_5=28 if Pop>=14 & Pop<14.5
replace PopC0_5=29 if Pop>=14.5 & Pop<15
replace PopC0_5=30 if Pop>=15 & Pop<15.5
replace PopC0_5=31 if Pop>=15.5 & Pop<16
replace PopC0_5=32 if Pop>=16 & Pop<16.5
replace PopC0_5=33 if Pop>=16.5 & Pop<17
replace PopC0_5=34 if Pop>=17 & Pop<17.5
replace PopC0_5=35 if Pop>=17.5 & Pop<18
replace PopC0_5=36 if Pop>=18 & Pop<18.5
replace PopC0_5=37 if Pop>=18.5 & Pop<19
replace PopC0_5=38 if Pop>=19 & Pop<19.5
replace PopC0_5=39 if Pop>=19.5 & Pop<20
replace PopC0_5=40 if Pop>=20



histogram PopC0_5
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC0_5 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC0_5.txt: logit CCARef Ideo GovForm GovIdeo SES PopC0_5 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopC0_5_.txt: glm CCARef Ideo GovForm GovIdeo SES PopC0_5 MedianAge FuelElectric RBlack RHL, link(logit) robust
glm CCARef Ideo GovForm c.Ideo#c.GovForm SES PopC0_5 MedianAge FuelElectric RBlack RHL CMA, link(logit) robust


predict CCARefPopC0_5, xb
twoway scatter CCARefPopC0_5 PopC0_5
twoway scatter CCARefPopC0_5 Ideo


*** Pop dummies
gen PopD0_05=1 if Pop>0.05
replace PopD0_05=0 if Pop<=0.05
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD0_05 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD0_05.txt: logit CCARef Ideo GovForm GovIdeo SES PopD0_05 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD0_05_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD0_05 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD0_1=1 if Pop>0.1
replace PopD0_1=0 if Pop<=0.1
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD0_1 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD0_1.txt: logit CCARef Ideo GovForm GovIdeo SES PopD0_1 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD0_1_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD0_1 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD0_2=1 if Pop>0.2
replace PopD0_2=0 if Pop<=0.2
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD0_2 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD0_2.txt: logit CCARef Ideo GovForm GovIdeo SES PopD0_2 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD0_2_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD0_2 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD0_5=1 if Pop>0.5
replace PopD0_5=0 if Pop<=0.5
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD0_5 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD0_5.txt: logit CCARef Ideo GovForm GovIdeo SES PopD0_5 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD0_5_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD0_5 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD1=1 if Pop>1
replace PopD1=0 if Pop<=1
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD1 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD1.txt: logit CCARef Ideo GovForm GovIdeo SES PopD1 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD1_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD1 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD2=1 if Pop>2
replace PopD2=0 if Pop<=2
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD2 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD2.txt: logit CCARef Ideo GovForm GovIdeo SES PopD2 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD2_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD2 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD5=1 if Pop>5
replace PopD5=0 if Pop<=5
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD5 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD5.txt: logit CCARef Ideo GovForm GovIdeo SES PopD5 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD5_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD5 MedianAge FuelElectric RBlack RHL, link(logit) robust

gen PopD8=1 if Pop>8
replace PopD8=0 if Pop<=8
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES PopD8 MedianAge FuelElectric RBlack RHL CMA, robust
checkrob 3 6 resultPopD10.txt: logit CCARef Ideo GovForm GovIdeo SES PopD10 MedianAge FuelElectric RBlack RHL, robust
checkrob 3 6 resultPopD10_.txt: glm CCARef Ideo GovForm GovIdeo SES PopD10 MedianAge FuelElectric RBlack RHL, link(logit) robust

histogram Pop, frequency
histogram PopC0_5, frequency
histogram PopC1, frequency
histogram PopC2, frequency
histogram PopC5, frequency

histogram PopD0_05, frequency
histogram PopD0_5, frequency
histogram PopD1, frequency
histogram PopD2, frequency
histogram PopD5, frequency


*** Linear Probability Model ***
clear
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation.dta"

asdoc sum CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL, dec(2)

reg CCARef Ideo GovForm, vce(robust)
reg CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL Franchise, vce(robust)
reg CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge FuelElectric RBlack RHL Franchise, vce(robust)

predict yhatreg, xb
sum if yhatreg>1
sum if yhatreg<0

*** Marginal Effects
margins, dydx(Ideo) at(GovForm=(0 1))

margins, dydx(GovForm) at(Ideo=(0 (0.1) 1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

*** Robustness Check
gen GovIdeo=GovForm*Ideo
checkrob 3 7 resultPopReg.txt: reg CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL Franchise, vce(robust)
checkrob 3 7 resultPopReg_drop.txt: reg CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL Franchise, vce(robust)

*** Firthlogit provides inconsistent coefficients across models

*** Logit Predicted Values
logit CCARef Ideo GovForm c.Ideo#c.GovForm SES Pop MedianAge FuelElectric RBlack RHL, robust
predict yhatlogit, pr
sum if yhatlogit>0.2 & yhatlogit<0.8
*** most predicted values are between 0.2 to 0.8

collin CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL

brglm CCARef Ideo GovForm, model(logit) vce(robust)
brglm CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL Franchise, model(logit) vce(robust)
brglm CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge FuelElectric RBlack RHL Franchise, model(logit) vce(robust)
margins, dydx(Ideo) at(GovForm=(0 1)) expression(invlogit(predict(xb)))

reg   CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge FuelElectric RBlack RHL Franchise, vce(robust)
margins, dydx(Ideo) at(GovForm=(0 1))

margins, dydx(GovForm) at(Ideo=(0 (0.1) 1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

margins, dydx(GovForm) at(Ideo=(0 (0.1) 1)) expression(invlogit(predict(xb)))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

firthlogit CCARef Ideo GovForm, or
firthlogit CCARef Ideo GovForm SES Pop MedianAge FuelElectric RBlack RHL Franchise, or
firthlogit CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge FuelElectric RBlack RHL Franchise, or

margins, dydx(Ideo) at(GovForm=(0 1)) expression(invlogit(predict(xb)))


margins, dydx(GovForm) at(Ideo=(0 (0.1) 1)) expression(invlogit(predict(xb)))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

checkrob 3 7 resultPopFirth.txt: firthlogit CCARef Ideo GovForm GovIdeo SES Pop MedianAge FuelElectric RBlack RHL Franchise

