import numpy as np
import matplotlib as plot

# Thermophysical Properties of Nitrous Oxide White Paper
# Range of applicability: -90C to 36C (-130F to 96.8F)
# Can only model based on temperature (eqns based off temp since
# using the saturation dome and too complex)

# Critical Point of Nitrous
critTemp = 309.57   # K
critRho = 452       # kg/m**3
critPressure = 7251 # kPa

# ---------- Polynomial Constants from Paper ----------
vapPressure = [-6.7189, 1.35966, -1.3779, -4.051]       # vapor pressure (kPa)
rhoL = [1.72328, -0.83950, 0.51060, -0.10412]           # liquid density (kg/m**3)
rhoV = [-1.009, -6.28792, 7.50332, -7.90463, 0.629427]  # vapor density (kg/m**3)

hL = [-200, 116.043,-917.225, 794.779, -589.587]        # liquid spec. enthalpy (kJ/kg)
hV = [-200, 440.055, -459.701, 434.081, -485.338]       # vapor spec, enthalpy (kJ/kg)

cL = [2.49973, 0.023454, -3.80136, 13.0945, -14.5180]   # liquid isobaric spec. heat capacity (kJ/kg*K)
cV = [132.632, 0.052187, -0.364923, -1.20233, 0.536141] # vapor isobaric spec. heat capacity (kJ/kg*K)

# ---------- Property Calculation from White Paper ----------
def N2O_Properties(absTemp):
    Tr = absTemp/critTemp
    vaporPressure = critTemp*np.exp((1/Tr)*(vapPressure[0]*(1-Tr) + vapPressure[1]*(1-Tr)**(3/2) + vapPressure[2]*(1-Tr)**(5/2) + vapPressure[3]*(1-Tr)**5))
    liquidDensity = critRho*np.exp(rhoL[0]*(1-Tr)**(1/3) + rhoL[1]*(1-Tr)**(2/3) + rhoL[2]*(1-Tr) + rhoL[3]*(1-Tr)**(4/3))
    vaporDensity = critRho*np.exp(rhoV[0]*(1/Tr-1)**(1/3) + rhoV[1]*(1/Tr-1)**(2/3) + rhoV[2]*(1/Tr-1) + rhoV[3]*(1/Tr-1)**(4/3) + rhoV[4]*(1/Tr-1)**(5/3))
    hVaporization = (hV[0]-hL[0]) + (hV[1]-hL[1])*(1-Tr)**(1/3) + (hV[2]-hL[2])*(1-Tr)**(2/3) + (hV[3]-hL[3])*(1-Tr) + (hV[4]-hL[4])*(1-Tr)**(4/3)
    liquidSpecHeat = cL[0]*(1 + cL[1]*(1-Tr)**(-1) + cL[2]*(1-Tr) + cL[3]*(1-Tr)**2 + cL[4]*(1-Tr)**3)
    vaporSpecHeat = cV[0]*(1 + cV[1]*(1-Tr)**(-2/3) + cV[2]*(1-Tr)**(-1/3) + cV[3]*(1-Tr)**(1/3) + cV[4]*(1-Tr)**(2/3))

    return(liquidDensity, vaporDensity, vaporPressure/6.89475, hVaporization, liquidSpecHeat, vaporSpecHeat)

n2o = N2O_Properties(100)
print(n2o[1])