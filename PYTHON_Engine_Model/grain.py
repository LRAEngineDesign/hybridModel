import math

def grain(dt, oxMdot, ID, length):
    oxflux = oxMdot * math.pi * length * ID #kg s^-1 m^-2
    ### Constants
    a = 0.417 #constants are based on mm/s and g/cm^2
    n = 0.347
    fuelDensity = 950 #kg/m^3

    regressionRate = 1000 * a * math.pow(oxflux*0.1, n) #m s^-1 
    fMdot = ((regressionRate * dt + ID*0.5)^2 - (ID*0.5)^2) * math.pi * 0.5 * length * fuelDensity # Fuel mass flow rate 
        
    OFRatio = oxMdot/fMdot
    ID = regressionRate * dt + ID*0.5

    return [ID, OFRatio]