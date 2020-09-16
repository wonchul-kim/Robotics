from dmp import DMPs
import numpy as np
import matplotlib.pyplot as plt

class DMP_discrete(DMPs):
    def __init__(self, **kwargs):
        super(DMP_discrete, self).__init__(pattern='discrete', **kwargs)
        
        self.bfs_center_term()
        
        self.h = np.ones(self.n_bfs)*self.n_bfs**1.5/self.c/self.cs.a_x
        
        self.check_offset()
        
    def bfs_center_term(self):
        """
        set the center of the Gaussian basis functions 
        to be spaced envely throughout the whole run time
        """
        
        t_des = np.linspace(0, self.cs.runTime, self.n_bfs)
        self.c = np.zeros(len(t_des))
        for i in range(len(t_des)):
            self.c[i] = np.exp(-self.cs.a_x*t_des[i])   # value of the eq. dx = -a_x*x
        
    def f_front_term(self, x, dmp_idx):
        """
        diminishing term for forcing function
        """
        return x*(self.goal[dmp_idx] - self.y_0[dmp_idx])
    
    def f_weight_term(self, f_target):
        """
        generate a set of wegihts over the basis functions s.t.
        the target forcing term trajectory is matched
        
        - f_target np.array: desired forcing term trajectory
        """
        x_traj = np.zeros(self.cs.n_step)
        for i in range(self.cs.n_step):
            x_traj[i] = self.cs.step()
        psi_traj = self.gen_psi(x_traj)

        # calculate BF weights using weighted linear regression
        self.w = np.zeros((self.n_dmps, self.n_bfs))
        for j in range(self.n_dmps):
            scale = self.goal[j] - self.y_0[j] # spatial scaling term
            for k in range(self.n_bfs):
                numer = np.sum(x_traj*psi_traj[:, k]*f_target[:, j])
                denom = np.sum(x_traj**2*psi_traj[:, k])
                self.w[j, k] = numer/(scale*denom)
        self.w = np.nan_to_num(self.w)

    def gen_psi(self, x):
        """Generates the activity of the basis functions for a given
        canonical system rollout.

        x float, array: the canonical system state or path
        """
        if isinstance(x, np.ndarray):
            x = x[:, None]

        return np.exp(-self.h * (x - self.c)**2)
    
    def gen_goal(self, y_des):
        """Generate the goal for path imitation.
        For rhythmic DMPs the goal is the average of the
        desired trajectory.

        y_des np.array: the desired trajectory to follow
        """

        return np.copy(y_des[:, -1])