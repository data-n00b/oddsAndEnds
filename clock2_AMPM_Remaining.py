
# clock2.py -- allows clocks to be created at a specified time
#           -- adds a repr method to ClockDisplay

# The NumberDisplay class represents a digital number display that can hold
# values from zero to a given limit. The limit can be specified when creating
# the display. The values range from zero (inclusive) to limit-1. If used,
# for example, for the seconds on a digital clock, the limit would be 60, 
# resulting in display values from 0 to 59. When incremented, the display 
# automatically rolls over to zero when reaching the limit.

class NumberDisplay(object):
    #Adding a new variable value to capture the least value of the object.
    #Changed since the minmum value for hours and minutes are not the same.
    def __init__(self, rollover_limit,value):
        self.value = value
        self.limit = rollover_limit

    def get_value(self):
        return self.value

    # Set the value of the display to the new specified value. If the new
    # value is less than zero or over the limit, do nothing.
    def set_minute(self, new):
        if self.value <= new < self.limit:
            self.value = new
                   
    #New method defined to set hours. The hour hand now only has values between 1 and 12 unlike a 24
    #hour clock.     
    def set_hour(self, new):
        if self.value < new < self.limit:
            self.value = new
        elif self.limit < new < 2*self.limit:
            self.value = new-12
        else:
            self.value = 12

    # Increment the display value by one, rolling over to zero if the
    # limit is reached.
    def increment(self):
        self.value = (self.value + 1) % self.limit

    # Return the display value (that is, the current value) as a two-digit
    # string.  Pad values less than ten with a space.
    def get_display(self):
        return '%02d' % self.value


# The ClockDisplay class implements a digital clock display for a
# European-style 24 hour clock. The clock shows hours and minutes. The 
# range of the clock is 00:00 (midnight) to 23:59 (one minute before 
# midnight).
# 
# The clock display receives "ticks" (via the tick method) every minute
# and reacts by incrementing the display. This is done in the usual clock
# fashion: the hour increments when the minutes roll over to zero.

class ClockDisplay(object):

    # Initializer for creating clocks at the specified time.
    #New input flag added to the object. Defaults to AM if not specified.
    def __init__(self, hour=12, minute=0, flag = 'AM'):        
        try:
            self.hours = NumberDisplay(12,1)
            self.minutes = NumberDisplay(60,0)
            self.set_time(hour, minute)
            self.flag = flag
        #Exceptions to catch negative and string inputs. Object defaults to 12.00 AM
        #after catching both exceptions.
            if hour < 0 or minute < 0:
                raise ValueError
            if type(hour) != int or type(minute) != int:
                raise TypeError
            if flag.lower() != 'am' and flag.lower() != 'pm':
                self.flag = 'AM'
                raise ValueError
        except ValueError:
            print("Unable to initialize due to value errors. Defaulting to 12:00AM")
        except TypeError:
            print("Hours and minutes should be of type integer. Defaulting to 12:00AM")

    # Set the time of the display to the specified hour and minute.
    def set_time(self, hour, minute):
        self.hours.set_hour(hour)
        self.minutes.set_minute(minute)

    # This method should get called once every minute - it makes
    # the clock display go one minute forward.
    #Additional conditional statements added to check for rolling hours and the special case
    #of hours being 11.
    def tick(self):
        self.minutes.increment()
        if self.minutes.get_value() == 0:  # it just rolled over!
            if self.hours.get_value() == 11:
                self.hours.set_hour(12)
                if self.flag == 'AM':
                    self.flag = 'PM'
                elif self.flag == 'PM':
                    self.flag = 'AM'
            else:
                self.hours.increment()

    # Return a string that represents the display in the format HH:MM.
    def get_display(self):
        return self.hours.get_display() + ':' + \
            self.minutes.get_display() + ':' + self.flag

    def __repr__(self):
        return 'ClockDisplay(%r, %r, %s)' % \
            (self.hours.get_value(), self.minutes.get_value(), self.flag)

def main():
    #Initializing at a little past midnight and ticking to check output and
    #rollover cases
    #Other type error have been checked.
    x = ClockDisplay(11, 45,'PM')
    print(x.get_display())
    for i in range(8):
        for j in range(420):
            x.tick()
        print(x.get_display())
    print(x)

if __name__ == '__main__':
    main()
