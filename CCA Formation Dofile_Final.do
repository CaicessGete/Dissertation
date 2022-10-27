*** Paper 1 CCA Formation, Citizen Paritisanship, 
    // and Governmentsal Institutions

* Import data
use "/Users/jd/Desktop/Dissertation/Data/Paper1/CCA Formation.dta", replace

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
drop in 1257/1724 /// empty rows after the 1256

* Genrate the Socioeconomic Status Factor Variable
factor High Bachelor MedianIncome Poverty Unemp
predict SES

* Descriptive Statistics
asdoc sum CCARef Ideo GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, dec(2)

* Check multicollinearity
collin CCARef Ideo GovForm SES Pop MedianAge RBlack RHL FuelElectric Franchise
* No VIF > 4 and no tolerance < 0.25, no indication of multicollinearity

* First Statistical Method (Logit Models) 
*		cannot pass the robustness check
logit CCARef Ideo GovForm , robust
logit CCARef Ideo GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust
logit CCARef Ideo GovForm c.Ideo#i.GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust

* Logistic Model that Coefficients Are Odd Ratios (How many times more likely)
logistic CCARef Ideo GovForm
logistic CCARef Ideo GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust
logistic CCARef Ideo GovForm c.Ideo#i.GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust

* Marginal Effects
* Effects of Ideology conditional on Government Form
margins, dydx(Ideo) at(GovForm=(0 1))

* Effects of Government Form conditional on Ideology
margins, dydx(GovForm) at(Ideo=(0(0.1)1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)

* Robustness Checking Models
probit CCARef Ideo GovForm c.Ideo#i.GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust
glm CCARef Ideo GovForm c.Ideo#i.GovForm SES Pop RBlack RHL MedianAge FuelElectric Franchise, link(logit) robust
gen GovIdeo = Ideo*GovForm
mfp: logit CCARef Ideo GovForm GovIdeo SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust

* Robustness Checking Tests
checkrob 3 7 RobustCheckResult.txt: logit CCARef Ideo GovForm GovIdeo SES Pop RBlack RHL MedianAge FuelElectric Franchise, robust

* The signs of interested coefficients from the robustness 
	/// check models and the test are somehow different from 
	/// the signs in the logit model,
	/// cannot pass the robustness check

* Checked the dataset, there is a separation issue that all 
	/// municipalities with population larger than 555,84 
	/// have adopted CCAs
	
* To solve the issue with model, we choose to use a penalized
	/// likelihood approach introduced by Firth in 1993
	

* Firth Penailized Likelihood Approach
firthlogit CCARef Ideo GovForm
firthlogit CCARef Ideo GovForm SES Pop MedianAge RBlack RHL FuelElectric Franchise
firthlogit CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge RBlack RHL FuelElectric Franchise

* Coefficients are odd ratios for easier interpretation
firthlogit CCARef Ideo GovForm, or
firthlogit CCARef Ideo GovForm SES Pop MedianAge RBlack RHL FuelElectric Franchise, or
firthlogit CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge RBlack RHL FuelElectric Franchise, or

* Marginal effects: probabilities
* Effects of Ideology conditional on Government Form
margins, dydx(Ideo) at(GovForm=(0 1)) expression(invlogit(predict(xb)))

* Effects of Government Form conditional on Ideology
margins, dydx(GovForm) at(Ideo=(0 (0.1) 1)) expression(invlogit(predict(xb)))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)
graph save Graph "/Users/jd/Desktop/Dissertation/Data/Paper1/FirthME.gph"

* Robustness Checking Models: Bias Reduced Generalized Linear
	/// Model (BRGLM) & Linear Probability Model (LPM)
* BRGLM
brglm CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge RBlack RHL FuelElectric Franchise, model(logit) vce(robust)

* Marginal effects: probabilities
* Effects of Ideology conditional on Government Form
margins, dydx(Ideo) at(GovForm=(0 1)) expression(invlogit(predict(xb)))

* Effects of Government Form conditional on Ideology
margins, dydx(GovForm) at(Ideo=(0 (0.1) 1)) expression(invlogit(predict(xb)))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)
graph save Graph "/Users/jd/Desktop/Dissertation/Data/Paper1/BRGLMME.gph"

* LPM	
reg CCARef Ideo GovForm c.GovForm#c.Ideo SES Pop MedianAge RBlack RHL FuelElectric Franchise, vce(robust)

* Effects of Ideology conditional on Government Form
margins, dydx(Ideo) at(GovForm=(0 1))

* Effects of Government Form conditional on Ideology
margins, dydx(GovForm) at(Ideo=(0 (0.1) 1))
marginsplot, yline(0) xlabel(0(0.1)1) recast(line) recastci(rarea) level(90)
graph save Graph "/Users/jd/Desktop/Dissertation/Data/Paper1/LPMME.gph"

* Robustness Checking Tests
checkrob 3 7 RobustCheckResultFirth.txt: firthlogit CCARef Ideo GovForm GovIdeo SES Pop MedianAge RBlack RHL FuelElectric Franchise
