import math

def grain(dt, oxMdot, ID, length): # Use SI units pleaseeee
    oxflux = oxMdot/(math.pow(ID,2) * math.pi * 0.25) #kg s^-1 m^-2
    ### Constants
    a = 0.417 #constants are based on mm/s and g/cm^2
    n = 0.347
    fuelDensity = 950 #kg m^-3

    regressionRate = 0.001 * a * math.pow(oxflux*0.1, n) #m s^-1, radius regression rate. Const
    fMdot = ((math.pow((regressionRate * dt + ID*0.5),2) - math.pow(ID*0.5, 2)) * math.pi * 0.5 * length * fuelDensity)/dt # Fuel mass flow rate 
    OFRatio = oxMdot/fMdot # no dimension
    ID = 2 * regressionRate * dt + ID
    return [ID, OFRatio]

'''
#This is here for sanity checking
dt = 0.001
t = 0
oxMdot = 1
ID = 0.03
OD = 0.08
length = 0.5
while(ID < OD):
    [ID, OFRatio] = grain(dt, oxMdot, ID, length)
    t += dt

print(t)
print(OFRatio)
'''