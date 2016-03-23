import math
from i2clibraries import i2c
from time import sleep
from sys import stderr

class i2c_hmc5883l:
    
    ConfigurationRegisterA = 0x00
    ConfigurationRegisterB = 0x01
    ModeRegister = 0x02
    AxisXDataRegisterMSB = 0x03
    AxisXDataRegisterLSB = 0x04
    AxisZDataRegisterMSB = 0x05
    AxisZDataRegisterLSB = 0x06
    AxisYDataRegisterMSB = 0x07
    AxisYDataRegisterLSB = 0x08
    StatusRegister = 0x09
    IdentificationRegisterA = 0x10
    IdentificationRegisterB = 0x11
    IdentificationRegisterC = 0x12
    
    # Configuration register A
    MeasurementModeNormal = 0x00
    MeasurementModePositiveBias = 0x01
    MeasurementModeNegativeBias = 0x02
    
    # Data outout rates [Hz]
    DataOutputRate0_75 = 0x00 << 2
    DataOutputRate1_5  = 0x01 << 2
    DataOutputRate3    = 0x02 << 2
    DataOutputRate7_5  = 0x03 << 2
    DataOutputRate15   = 0x04 << 2
    DataOutputRate30   = 0x05 << 2
    DataOutputRate75   = 0x06 << 2
         
    # Configuration register B [Gauss]
    SensorRange0_88       = 0x00 << 5
    SensorRange1_3       = 0x01 << 5
    SensorRange1_9       = 0x02 << 5
    SensorRange2_5       = 0x03 << 5
    SensorRange4_0       = 0x04 << 5
    SensorRange4_7       = 0x05 << 5
    SensorRange5_6       = 0x06 << 5
    SensorRange8_1       = 0x07 << 5
    
    # Mode register
    MeasurementContinuous = 0x00
    MeasurementSingleShot = 0x01
    MeasurementIdle = 0x03
    
    # Default (Gains, Register values) per Scale
    Gains = {
                0.88: (1370., 0x00 << 5),
                1.3 : (1090., 0x01 << 5),
                1.9 : ( 820., 0x02 << 5),
                2.5 : ( 660., 0x03 << 5),
                4.0 : ( 440., 0x04 << 5),
                4.7 : ( 390., 0x05 << 5),
                5.6 : ( 330., 0x06 << 5),
                8.1 : ( 230., 0x07 << 5)
                }
    
    # Calibration reference values [Gauss]
    CalibrationXY = 1.16
    CalibrationZ  = 1.08
    
    # (Un)Calibrated Gain factors
    CalibratedPositiveGainX = 1.
    CalibratedPositiveGainY = 1.
    CalibratedPositiveGainZ = 1.
    
    CalibratedNegativeGainX = 1.
    CalibratedNegativeGainY = 1.
    CalibratedNegativeGainZ = 1.
    
    def __init__(self, port, addr=0x1e, gauss=1.3):
        self.bus = i2c.i2c(port, addr)
        
        if gauss not in self.Gains.keys():
            gauss = 2.5
        
        (self.scale, self.scale_reg) = self.Gains[gauss] # set values
        
        self.setScale(gauss) # send to device
        self.calibrate(gauss)
        
    def __str__(self):
        ret_str = ""
        (x, y, z) = self.getAxes()
        ret_str += "Axis X: "+str(x)+" Gauss\n"       
        ret_str += "Axis Y: "+str(y)+" Gauss\n" 
        ret_str += "Axis Z: "+str(z)+" Gauss\n" 
        
        ret_str += "Declination: "+self.getDeclinationString()+"\n" 
        
        ret_str += "Heading: "+self.getHeadingString()+"\n" 
        
        return ret_str
    
    def calibrate(self, calScale=2.5):
        """
            Calibrate gains for given scale
        """
        # Avoid overflow
        if calScale < 2.5 or calScale not in self.Gains.keys():
            calScale = 2.5
        calGain = self.Gains[calScale][0]
        
        # Save original values
        mode = self.readRegister(self.ModeRegister)
        conf = self.readRegister(self.ConfigurationRegisterA)        
        gain = self.readRegister(self.ConfigurationRegisterB)
        scale = self.scale # store old value    
        
        # set gain for testing/calibration
        self.setScale(calScale)
        
        # Set positive bias
        self.addOption(self.ConfigurationRegisterA, self.MeasurementModePositiveBias)
        
        # Set mode single measurement
        self.setOption(self.ModeRegister, self.MeasurementSingleShot)
        
        # Wait a little
        sleep(.01) # [seconds]
        
        # Perform a direct reading of the positive bias signal
        (magno_x, magno_z, magno_y) = self.bus.read_3s16int(self.AxisXDataRegisterMSB)
#        print("Positive bias reading: %.3f, %.3f, %.3f" % (calGain/magno_x, calGain/magno_y, calGain/magno_z))
        self.CalibratedPositiveGainX = magno_x/self.CalibrationXY/calGain
        self.CalibratedPositiveGainY = magno_y/self.CalibrationXY/calGain
        self.CalibratedPositiveGainZ = magno_z/self.CalibrationZ/calGain
#        print("Positive calibrated gains: %.3f, %.3f, %.3f" % (self.CalibratedPositiveGainX, self.CalibratedPositiveGainY, self.CalibratedPositiveGainZ), file=stderr)    
        
        # Set negative bias
        self.removeOption(self.ConfigurationRegisterA, self.MeasurementModePositiveBias)
        self.addOption(self.ConfigurationRegisterA, self.MeasurementModeNegativeBias)
        # Set mode single measurement
        self.setOption(self.ModeRegister, self.MeasurementSingleShot)

        # Wait a little
        sleep(.01) # [seconds]
        
        # Perform a direct reading of the negative bias signal
        (magno_x, magno_z, magno_y) = self.bus.read_3s16int(self.AxisXDataRegisterMSB)
#        print("Negative bias reading: %.3f, %.3f, %.3f" % (calGain/magno_x, calGain/magno_y, calGain/magno_z))
        self.CalibratedNegativeGainX = -magno_x/self.CalibrationXY/calGain
        self.CalibratedNegativeGainY = -magno_y/self.CalibrationXY/calGain
        self.CalibratedNegativeGainZ = -magno_z/self.CalibrationZ/calGain
#        print("Negative calibrated gains: %.3f, %.3f, %.3f" % (self.CalibratedNegativeGainX, self.CalibratedNegativeGainY, self.CalibratedNegativeGainZ), file=stderr)    
                
        # Restore original values
        self.scale = scale
        self.writeRegister(self.ConfigurationRegisterB, gain)
        self.writeRegister(self.ConfigurationRegisterA, conf)
        self.writeRegister(self.ModeRegister, mode)
#        self.desaturate()

    def getGains(self):
        """ Get gains table """
        return {k: v[0] for k, v in self.Gains.items()} 
    
    def getGainFactors(self):
        """ Get calibration factors """
        return ( (self.CalibratedPositiveGainX, self.CalibratedNegativeGainX),
                (self.CalibratedPositiveGainY, self.CalibratedNegativeGainY),
                (self.CalibratedPositiveGainZ, self.CalibratedNegativeGainZ) )

    def desaturate(self):
        n = 10
        for _ in range(n):
            self.bus.read_3s16int(self.AxisXDataRegisterMSB)
            sleep(.01)
        
    def setContinuousMode(self):
        self.setOption(self.ModeRegister, self.MeasurementContinuous)

    def setSingleShotMode(self):
        self.setOption(self.ModeRegister, self.MeasurementSingleShot)
        
    def setScale(self, gauss):
        (self.scale, self.scale_reg) = self.Gains.get(gauss, (self.scale, self.scale_reg)) 
        self.setOption(self.ConfigurationRegisterB, self.scale_reg)
        
    def setDeclination(self, degree, min = 0):
        self.declinationDeg = degree
        self.declinationMin = min
        self.declination = (degree+min/60) * (math.pi/180)

    def readRegister(self, register):
        return self.bus.read_byte(register)

    def writeRegister(self, register, value):
        self.bus.write_byte(register, value)
        
    def setOption(self, register, *function_set):
        options = 0x00
        for function in function_set:
            options = options | function
        self.bus.write_byte(register, options)
        
    # Adds to existing options of register    
    def addOption(self, register, *function_set):
        options = self.bus.read_byte(register)
        for function in function_set:
            options = options | function
        self.bus.write_byte(register, options)
        
    # Removes options of register    
    def removeOption(self, register, *function_set):
        options = self.bus.read_byte(register)
        for function in function_set:
            options = options & (function ^ 0b11111111)
        self.bus.write_byte(register, options)
        
    def getDeclination(self):
        return (self.declinationDeg, self.declinationMin)
    
    def getDeclinationString(self):
        return str(self.declinationDeg)+"\u00b0 "+str(self.declinationMin)+"'"
    
    # Returns heading in degrees and minutes
    def getHeading(self):
        (scaled_x, scaled_y, scaled_z) = self.getAxes()
        
        headingRad = math.atan2(scaled_y, scaled_x)
        headingRad += self.declination

        # Correct for reversed heading
        if(headingRad < 0):
            headingRad += 2*math.pi
            
        # Check for wrap and compensate
        if(headingRad > 2*math.pi):
            headingRad -= 2*math.pi
            
        # Convert to degrees from radians
        headingDeg = headingRad * 180/math.pi
        degrees = math.floor(headingDeg)
        minutes = round(((headingDeg - degrees) * 60))
        return (degrees, minutes)
    
    def getHeadingString(self):
        (degrees, minutes) = self.getHeading()
        return str(degrees)+"\u00b0 "+str(minutes)+"'"
        
    def getAxes(self):
        """
            Return (calibrated or otherwise) values in Gauss
        """
        (magno_x, magno_z, magno_y) = self.bus.read_3s16int(self.AxisXDataRegisterMSB)

        if (magno_x == -4096):
            magno_x = None
        else:
            cal = self.CalibratedPositiveGainX
            if magno_x < 0.:
                cal = self.CalibratedNegativeGainX
            magno_x = round(magno_x / self.scale * cal, 4)
            
        if (magno_y == -4096):
            magno_y = None
        else:
            cal = self.CalibratedPositiveGainY
            if magno_y < 0.:
                cal = self.CalibratedNegativeGainY
            magno_y = round(magno_y / self.scale * cal, 4)
            
        if (magno_z == -4096):
            magno_z = None
        else:
            cal = self.CalibratedPositiveGainZ
            if magno_z < 0.:
                cal = self.CalibratedNegativeGainZ
            magno_z = round(magno_z / self.scale * cal, 4)
        
        return (magno_x, magno_y, magno_z)
