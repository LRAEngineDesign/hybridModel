import numpy as np
import matplotlib as plot
import yaml

# Probably dont need a yaml for nitrous coefficients
#with open('nitrous_coefficients.yaml') as file1:
#    nitrous = yaml.safe_load(file1)
blowdown_inputs = "C:/hybridModel/PYTHON_Engine_Model/blowdown_inputs.yaml"

with open(blowdown_inputs, 'r') as file2:
        inputs = yaml.safe_load(file2)


# Thermophysical Properties of Nitrous Oxide White Paper
# Range of applicability: -90C to 36C (-130F to 96.8F)
# Can only model based on temperature (eqns based off temp since using the saturation dome and too complex)

class Blowdown:
    def __init__(self, abs_temp, dt, massLiq, massVap):

        # --- Initial Conditions and Initializing State Variables ---
        self.absTemp = abs_temp # K
        self.oxFlowRate = 2     # kg/s, constant flow rate for now
        self.dt = dt            # seconds
        self.massLiq = massLiq  # kg
        self.massVap = massVap  # kg

        self.volTank = inputs['Tank_Volume']                     # m^3
        self.initialTemperature = inputs['Initial_Temperature']  # K
        self.oxMass = inputs['Ox_Mass']                          # kg

        # --- Critical Point of Nitrous ---
        self.critTemp = 309.57   # K
        self.critRho = 452       # kg/m^3
        self.critPressure = 7251 # kPa

        # --- Polynomial Constants from Paper ---
        self.vapPressure = [-6.7189, 1.35966, -1.3779, -4.051]       # vapor pressure (kPa)
        self.rhoL = [1.72328, -0.83950, 0.51060, -0.10412]           # liquid density (kg/m^3)
        self.rhoV = [-1.009, -6.28792, 7.50332, -7.90463, 0.629427]  # vapor density (kg/m^3)

        self.hL = [-200, 116.043,-917.225, 794.779, -589.587]        # liquid spec. enthalpy (kJ/kg)
        self.hV = [-200, 440.055, -459.701, 434.081, -485.338]       # vapor spec, enthalpy (kJ/kg)

        self.cL = [2.49973, 0.023454, -3.80136, 13.0945, -14.5180]   # liquid isobaric spec. heat capacity (kJ/kg*K)
        self.cV = [132.632, 0.052187, -0.364923, -1.20233, 0.536141] # vapor isobaric spec. heat capacity (kJ/kg*K)

    # ---------- Property Calculation from White Paper ----------
    def N2O_Properties(self):
        # Vapor Pressure (kPa)
        Tr = self.absTemp/self.critTemp
        self.vaporPressure = self.critPressure*np.exp((1/Tr)*(self.vapPressure[0]*(1-Tr) + self.vapPressure[1]*(1-Tr)**(3/2) + self.vapPressure[2]*(1-Tr)**(5/2) + self.vapPressure[3]*(1-Tr)**5))
        self.liquidDensity = self.critRho*np.exp(self.rhoL[0]*(1-Tr)**(1/3) + self.rhoL[1]*(1-Tr)**(2/3) + self.rhoL[2]*(1-Tr) + self.rhoL[3]*(1-Tr)**(4/3))
        self.vaporDensity = self.critRho*np.exp(self.rhoV[0]*(1/Tr-1)**(1/3) + self.rhoV[1]*(1/Tr-1)**(2/3) + self.rhoV[2]*(1/Tr-1) + self.rhoV[3]*(1/Tr-1)**(4/3) + self.rhoV[4]*(1/Tr-1)**(5/3))
        self.hVaporization = (self.hV[0]-self.hL[0]) + (self.hV[1]-self.hL[1])*(1-Tr)**(1/3) + (self.hV[2]-self.hL[2])*(1-Tr)**(2/3) + (self.hV[3]-self.hL[3])*(1-Tr) + (self.hV[4]-self.hL[4])*(1-Tr)**(4/3)
        self.liquidSpecHeat = self.cL[0]*(1 + self.cL[1]*(1-Tr)**(-1) + self.cL[2]*(1-Tr) + self.cL[3]*(1-Tr)**2 + self.cL[4]*(1-Tr)**3)
        self.vaporSpecHeat = self.cV[0]*(1 + self.cV[1]*(1-Tr)**(-2/3) + self.cV[2]*(1-Tr)**(-1/3) + self.cV[3]*(1-Tr)**(1/3) + self.cV[4]*(1-Tr)**(2/3))

        # sanity checking
        print(self.liquidDensity, self.vaporDensity, self.vaporPressure/6.89475, self.hVaporization, self.liquidSpecHeat, self.vaporSpecHeat)
        print(('this is working'))
    

    # ---------- Tank Discharge Calculations ----------

    # Using initial temperature, uses thermodynamic properties at that state to calculate
    # the starting mass of both liquid and vapor based on Law of Conservation of Mass and Volume

    #def Discharge(self):
        
        



# sanity checking
stuff = Blowdown(293,0)
stuff.N2O_Properties()
print(stuff.vaporPressure/6.89475)

