from cs import CanonicalSystem
import numpy as np
import scipy.interpolate

class DMPs(object):
    def __init__(self, n_dmps, n_bfs, dt, runTime, y_0=0, goal=1,
                 w=None, a_y=None, b_y=None, **kwargs):
        """
        n_dmps int: number of dynamic motor primitives
        n_bfs int: number of basis functions per DMP
        dt float: timestep for simulation
        y0 list: initial state of DMPs
        goal list: goal state of DMPs
        w list: tunable parameters, control amplitude of basis functions
        ay int: gain on attractor term y dynamics
        by int: gain on attractor term y dynamics
        """
        
        self.n_dmps = n_dmps
        self.n_bfs = n_bfs
        self.dt = dt
        self.runTime = runTime
        
        if isinstance(y_0, (int, float)):
            y_0 = np.ones(self.n_dmps)*y_0
        self.y_0 = y_0
        
        if isinstance(goal, (int, float)):
            goal = np.ones(self.n_dmps)*goal
        self.goal = goal
        
        if w is None:
            # default is f = 0
            w = np.zeros((self.n_dmps, self.n_bfs))
        self.w = w
        
        # from the paper
        self.a_y = np.ones(n_dmps)*25.0 if a_y is None else a_y
        self.b_y = self.a_y/4.0 if b_y is None else b_y
        
        self.cs = CanonicalSystem(dt=self.dt, runTime=self.runTime, **kwargs)
        self.n_step = self.cs.n_step

        self.reset()
        
    
    def reset(self):
        self.y = self.y_0.copy()
        self.dy = np.zeros(self.n_dmps)
        self.ddy = np.zeros(self.n_dmps)
        self.cs.reset()
        
    def check_offset(self):
        """
        check to see if initial position and goal are the same 
        if they are, offset slightly so that the forcing term is not 0
        """
        for i in range(self.n_dmps):
            if self.y_0[i] == self.goal[i]:
                self.goal[i] += 1e-4
                
    def f_front_term(self, x, dmp_idx):
        raise NotImplementedError()
        
    def f_weight_term(self, f_target):
        raise NotImplementedError()
        
    def gen_psi(self):
        raise NotImplementedError()
        
    def gen_goal(self):
        raise NotImplementedError()
        
    def step(self, tau=1.0, error=0.0, external_force=None):
        """
        generate a single timestep of dmp

        - tau float: scales the timestep
                     increase tau to make the system execute faster
        - error float: optional system feedback
        """
        x = self.cs.step(tau=tau, error=error)
        psi = self.gen_psi(x)

        # print('x', x)
        # print('psi', psi)

        for i in range(self.n_dmps):
            # print('w_i', i, self.w[i])
            f = (self.f_front_term(x, i)*(np.dot(psi, self.w[i]))
                                                     /np.sum(psi))
            self.ddy[i] = (self.a_y[i]*
                              (self.b_y[i]*(self.goal[i] - self.y[i])
                                  - self.dy[i]/tau) + f)*tau**2
                  
            if external_force is not None:
                self.ddy[i] += external_force[i]
            
            error_coupling = 1/(1 + error)
            self.dy[i] += self.ddy[i]*tau*self.dt*error_coupling
            self.y[i] += self.dy[i]*self.dt*error_coupling
            
        return self.y, self.dy, self.ddy
    
    def imitate_path(self, y_des, plot=False):
        # set initiall state and goal
        if y_des.ndim == 1:
            y_des = y_des.reshape(1, len(y_des))
        self.y_0 = y_des[:, 0].copy() 
        self.y_des = y_des.copy()
        self.goal = self.gen_goal(y_des)
        self.check_offset()

        # to make y_des array as [time, value]
        path = np.zeros((self.n_dmps, self.n_step))
        t = np.linspace(0, self.cs.runTime, y_des.shape[1])
        for i in range(self.n_dmps):
            gen_path = scipy.interpolate.interp1d(t, y_des[i])
            for j in range(self.n_step):
                path[i, j] = gen_path(j*self.dt)
        y_des = path
        
        dy_des = np.diff(y_des)/self.dt # velocity
        # add zero to the beginning of every row
        dy_des = np.hstack((np.zeros((self.n_dmps, 1)), dy_des))

        ddy_des = np.diff(dy_des)/self.dt
        ddy_des = np.hstack((np.zeros((self.n_dmps, 1)), ddy_des))

        f_target = np.zeros((y_des.shape[1], self.n_dmps))
        # find the force required to move along the desired trajectory
        for k in range(self.n_dmps):
            f_target[:, k] = (ddy_des[k] - self.a_y[k]*
                              (self.b_y[k]*(self.goal[k] - y_des[k]) - dy_des[k]))
        
        self.f_weight_term(f_target)

        if plot is True:
            import matplotlib.pyplot as plt
            plt.figure()
            plt.subplot(311)
            x_traj = np.zeros(self.cs.n_step)
            for m in range(self.cs.n_step):
                x_traj[m] = self.cs.step()
            psi_traj = self.gen_psi(x_traj)
            plt.plot(psi_traj)
            plt.title('basis functions')

            # plot the desired forcing function vs approx
            plt.subplot(312)
            plt.plot(f_target[:,0])
            plt.plot(np.sum(psi_traj * self.w[0], axis=1) * self.dt)
            # plt.legend(['f_target', 'w*psi'])
            plt.title('DMP forcing function')

            plt.subplot(313)
            plt.plot(self.w[0])
            plt.title('Weight')

            plt.tight_layout()
            plt.show()

        self.reset()

        return y_des



    def rollout(self, timesteps=None, **kwargs):
        """Generate a system trial, no feedback is incorporated."""
        self.reset()

        if timesteps is None:
            if 'tau' in kwargs:
                timesteps = int(self.n_step / kwargs['tau'])
            else:
                timesteps = self.n_step

        # set up tracking vectors
        y_track = np.zeros((timesteps, self.n_dmps))
        dy_track = np.zeros((timesteps, self.n_dmps))
        ddy_track = np.zeros((timesteps, self.n_dmps))

        for t in range(timesteps):

            # run and record timestep
            y_track[t], dy_track[t], ddy_track[t] = self.step(**kwargs)

        return y_track, dy_track, ddy_track