class Heater(object):
    def __init__(self,t=15):
        self.temp=t
        
    def warmer(self):
        self.temp=self.temp+5
    
    def cooler(self):
        self.temp=self.temp-5
    
    def value_temp(self):
        return self.temp
    
    def __repr__(self):
        return "Current Temperature: %d" % (self.temp)
#class Error(Exception):
#    pass
#class MinError(Error):
#    pass
#class TempError(Error):
#    pass
    
class Heater2(object):
    def __init__(self,min,max,t=15,i=5):
        #Exceptions raised if minimum > maximum and if temperature is initialized to a value
        #outside the max and min values
        try:
            self.temp=t
            self.increment=i
            self.min=min
            self.max=max
            if min >= max:
                raise ValueError("Minimum temperature has to be greater than the maximum temperature.\n Failed to Initialize Heater2 object.")
            if t < min or t > max:
                raise ValueError("Cannot initialize a temperature outside the range of minimum and maximum.\n Failed to Initialize Heater2 object.")
            if i < 0:
                raise ValueError("Increment should be positive. \nFailed to Initialize Heater2 object.")
        finally:
            pass
    def warmer(self):
        #Exceptions Raised for Exceeding max
        try:
            self.temp=self.temp+self.increment
            if self.temp+self.increment >= self.max:
                raise ValueError
        except ValueError:
            print("Temperature exceeds maximum")
    
    def cooler(self):
        #Exceptions Raised for going lesser than min
        try:
            self.temp=self.temp-self.increment
            if self.temp-self.increment <= self.min:
                raise ValueError
        except ValueError:
            print("Minimum temperature reached")

            
    def set_increment(self,i):
        #Exceptions Raised for negative increment value
        try:
            self.increment=i
            if i < 0:
                raise ValueError("Increment should be positive")
        finally:
            pass
        
    def value_temp(self):
        return self.temp
    
    def __repr__(self):
        return "%d" % (self.temp)
    
def main():
    heater1 = Heater(25)
    heater1.warmer()
    heater1.warmer()
    heater1.cooler()
    
    heater2 = Heater2(0,100,24,10)
    heater2.warmer()
    heater2.set_increment(10)
    
if __name__ == '__main__':
    main()
