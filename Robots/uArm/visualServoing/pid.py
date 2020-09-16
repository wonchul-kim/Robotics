import time

class PID:
    def __init__(self, Kp=0.2, Ki=0.0, Kd=0.0, sample_time=0.01):
        self.Kp = Kp
        self.Ki = Ki
        self.Kd = Kd
        
        self.sample_time = sample_time
        self.curr_t = time.time()
        self.prev_t = self.curr_t
        
        self.reset()
    
    def reset(self):
        self.desiredValue = 0.0
        
        self.pTerm = 0.0
        self.iTerm = 0.0
        self.dTerm = 0.0
        self.prev_err = 0.0
        
        self.windup_guard = 2.0
        
        self.output = 0.0
        
    def update(self, feedback_val, windup=True):
        """
        u(t) = K_p*e(t) + K_i/int_{0}^{t} e(t)dt + K_d*{de}/{dt}
        """
        err = self.desiredValue - feedback_val
        self.curr_t = time.time()
        delta_t = self.curr_t - self.prev_t
        delta_err = err - self.prev_err
        
        if delta_t >= self.sample_time:
            self.pTerm = self.Kp*err
            self.iTerm += err*delta_t
            self.iTerm *= self.Ki
            
            if windup:
                if self.iTerm < -self.windup_guard:
                    self.iTerm = -self.windup_guard
                elif self.iTerm > self.windup_guard:
                    self.iTerm = self.windup_guard
                
            self.dTerm = 0.0
            if delta_t > 0:
                self.dTerm = delta_err/delta_t
            self.dTerm *= self.Kd
                
            self.prev_t = self.curr_t
            self.prev_err = err
            self.output = self.pTerm + self.iTerm + self.dTerm
            
    def setKp(self, proportional_gain):
        self.Kp = proportional_gain

    def setKi(self, integral_gain):
        self.Ki = integral_gain

    def setKd(self, derivative_gain):
        self.Kd = derivative_gain

    def setWindup(self, windup):
        """Integral windup, also known as integrator windup or reset windup,
        refers to the situation in a PID feedback controller where
        a large change in setpoint occurs (say a positive change)
        and the integral terms accumulates a significant error
        during the rise (windup), thus overshooting and continuing
        to increase as this accumulated error is unwound
        (offset by errors in the other direction).
        The specific problem is the excess overshooting.
        """
        self.windup_guard = windup