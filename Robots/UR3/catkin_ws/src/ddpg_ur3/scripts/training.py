from __future__ import print_function
import os
import time
from collections import deque
import pickle

from ddpg import DDPG
from util import mpi_mean, mpi_std, mpi_max, mpi_sum
import tf_util as U

# import logger
import numpy as np
import tensorflow as tf
from mpi4py import MPI
import matplotlib.pyplot as plt



def train(env, nb_epochs, nb_epoch_cycles, eval_display_on, #render_eval, 
    reward_scale, display_on, #render,
    param_noise, actor, critic,
    normalize_returns, normalize_observations, critic_l2_reg, actor_lr, critic_lr, action_noise, logdir,
    popart, gamma, clip_norm, nb_train_steps, nb_rollout_steps, nb_eval_steps, batch_size, memory,
    tau=0.01, eval_env=None, param_noise_adaption_interval=50):

    fig = plt.figure()
    ax = fig.add_subplot(111, projection = '3d')
    
    log_path = './Results/'
    if not os.path.exists(log_path):
        os.makedirs(log_path)

    rank = MPI.COMM_WORLD.Get_rank()

    # assert (np.abs(env.action_space.low) == env.action_space.high).all()  # we assume symmetric actions.
    # max_action = env.action_space.high
    max_action = np.array([1, 1, 1])
    # logger.info('scaling actions by {} before executing in env'.format(max_action))
    # agent = DDPG(actor, critic, memory, env.observation_space.shape, env.action_space.shape,
    #     gamma=gamma, tau=tau, normalize_returns=normalize_returns, normalize_observations=normalize_observations,
    #     batch_size=batch_size, action_noise=action_noise, param_noise=param_noise, critic_l2_reg=critic_l2_reg,
    #     actor_lr=actor_lr, critic_lr=critic_lr, enable_popart=popart, clip_norm=clip_norm,
    #     reward_scale=reward_scale)
    agent = DDPG(actor, critic, memory, (3, ), (3, ),
        gamma=gamma, tau=tau, normalize_returns=normalize_returns, normalize_observations=normalize_observations,
        batch_size=batch_size, action_noise=action_noise, param_noise=param_noise, critic_l2_reg=critic_l2_reg,
        actor_lr=actor_lr, critic_lr=critic_lr, enable_popart=popart, clip_norm=clip_norm,
        reward_scale=reward_scale)
    # logger.info('Using agent with the following configuration:')
    # logger.info(str(agent.__dict__.items()))

    # Set up logging stuff only for a single worker.
    if rank == 0:
        saver = tf.train.Saver()
    else:
        saver = None
    
    step = 0
    episode = 0
    eval_episode_rewards_history = deque(maxlen=100)
    episode_rewards_history = deque(maxlen=100)
    with U.single_threaded_session() as sess:
        # Prepare everything.
        agent.initialize(sess)
        sess.graph.finalize()

        agent.reset()
        endP, obs = env.reset(ax, display_on)
        if eval_env is not None:
            eval_endP, eval_obs = eval_env.reset(ax, eval_display_on)
        done = False
        episode_reward = 0.
        episode_step = 0
        episodes = 0
        t = 0

        epoch = 0
        start_time = time.time()

        epoch_episode_rewards = []
        epoch_episode_steps = []
        epoch_episode_eval_rewards = []
        epoch_episode_eval_steps = []
        epoch_start_time = time.time()
        epoch_actions = []
        epoch_qs = []
        epoch_episodes = 0
        for epoch in range(nb_epochs):
            if epoch > 10:
                eval_display_on = True
            for cycle in range(nb_epoch_cycles):
                # Perform rollouts.
                for t_rollout in range(nb_rollout_steps):
                    # Predict next action.
                    action, q = agent.pi(obs, apply_noise=True, compute_Q=True)
                    # assert action.shape == env.action_space.shape
                    assert action.shape == (3, )

                    # Execute next action.
                    # if rank == 0 and render:
                        # env.render()
                    # assert max_action.shape == action.shape
                    assert max_action.shape == (3, )

                    # new_obs, r, done, info = env.step(max_action * action)  # scale for execution in env (as far as DDPG is concerned, every action is in [-1, 1])
                    new_obs = action*max_action + obs
                    r, endP, done = env.step(new_obs, ax, display_on)

                    t += 1
                    # if rank == 0 and render:
                        # env.render()
                    episode_reward += r
                    episode_step += 1

                    # Book-keeping.
                    epoch_actions.append(action)
                    epoch_qs.append(q)
                    agent.store_transition(obs, action, r, new_obs, done)
                    obs = new_obs
                    print("\rRoll {}/{} @ Cycle{}/{} @ Episode {}/{} ||| R: {} ||| {} ".format(t_rollout + 1, 
                        nb_rollout_steps, cycle + 1, nb_epoch_cycles, epoch, nb_epochs, episode_reward, endP), end="")  
                    if done:
                        # Episode done.
                        epoch_episode_rewards.append(episode_reward)
                        episode_rewards_history.append(episode_reward)
                        epoch_episode_steps.append(episode_step)
                        episode_reward = 0.
                        episode_step = 0
                        epoch_episodes += 1
                        episodes += 1

                        agent.reset()
                        endP, obs = env.reset(ax, display_on)
                        print('\n0000000000000000000000000000000000')
                        break
                print('')

                # Train.
                epoch_actor_losses = []
                epoch_critic_losses = []
                epoch_adaptive_distances = []
                for t_train in range(nb_train_steps):
                    # Adapt param noise, if necessary.
                    if memory.nb_entries >= batch_size and t % param_noise_adaption_interval == 0:
                        distance = agent.adapt_param_noise()
                        epoch_adaptive_distances.append(distance)

                    cl, al = agent.train()
                    epoch_critic_losses.append(cl)
                    epoch_actor_losses.append(al)
                    agent.update_target_net()


                ########################################################
                # epoch_episode_rewards.append(episode_reward)
                # episode_rewards_history.append(episode_reward)
                # epoch_episode_steps.append(episode_step)
                agent.reset()
                endP, obs = env.reset(ax, display_on)
                episode_reward = 0
                episode_step = 0
                ########################################################


                # Evaluate.
                eval_episode_rewards = []
                eval_qs = []
                if eval_env is not None:
                    eval_episode_reward = 0.
                    for t_rollout in range(nb_eval_steps):
                        eval_action, eval_q = agent.pi(eval_obs, apply_noise=False, compute_Q=True)
                        new_eval_obs = eval_obs + eval_action*max_action
                        eval_r, eval_endP, eval_done = eval_env.step(new_eval_obs, ax, eval_display_on)  
                        # scale for execution in env (as far as DDPG is concerned, every action is in [-1, 1])
                        # if render_eval:
                        #     eval_env.render()
                        eval_episode_reward += eval_r
                        eval_obs = new_eval_obs

                        eval_qs.append(eval_q)
                        if eval_done:
                            eval_endP, eval_obs = eval_env.reset(ax, eval_display_on)
                            eval_episode_rewards.append(eval_episode_reward)
                            eval_episode_rewards_history.append(eval_episode_reward)
                            eval_episode_reward = 0.
                            break
                            
                    ####################################################################
                    # eval_endP, eval_obs = eval_env.reset(ax, eval_display_on)
                    # eval_episode_rewards.append(eval_episode_reward)
                    # eval_episode_rewards_history.append(eval_episode_reward)
                    # eval_episode_reward = 0.    
                    ###################################################################


            # Log stats.
            epoch_train_duration = time.time() - epoch_start_time
            duration = time.time() - start_time
            stats = agent.get_stats()
            combined_stats = {}
            for key in sorted(stats.keys()):
                combined_stats[key] = mpi_mean(stats[key])


        
            with open(log_path+'results.csv', 'w') as out_file:
                for m in range(len(epoch_episode_rewards)):
                    # out_string = ""
                    out_string = str(epoch_episode_rewards[m]) + '\t' + str(epoch_episode_steps[m])
                    out_string += "\n"
                    out_file.write(out_string) 

            fig = plt.figure(2)
            plt.plot(range(len(epoch_episode_rewards)), epoch_episode_rewards)
            plt.ylabel('reward')
            plt.xlabel('episode')
            plt.savefig(log_path + 'reward.png')
            print('\n saved reward figure')

            # Rollout statistics.
            combined_stats['rollout/return'] = mpi_mean(epoch_episode_rewards)
            combined_stats['rollout/return_history'] = mpi_mean(np.mean(episode_rewards_history))
            combined_stats['rollout/episode_steps'] = mpi_mean(epoch_episode_steps)
            combined_stats['rollout/episodes'] = mpi_sum(epoch_episodes)
            combined_stats['rollout/actions_mean'] = mpi_mean(epoch_actions)
            combined_stats['rollout/actions_std'] = mpi_std(epoch_actions)
            combined_stats['rollout/Q_mean'] = mpi_mean(epoch_qs)
    
            # Train statistics.
            combined_stats['train/loss_actor'] = mpi_mean(epoch_actor_losses)
            combined_stats['train/loss_critic'] = mpi_mean(epoch_critic_losses)
            combined_stats['train/param_noise_distance'] = mpi_mean(epoch_adaptive_distances)

            # Evaluation statistics.
            if eval_env is not None:
                combined_stats['eval/return'] = mpi_mean(eval_episode_rewards)
                combined_stats['eval/return_history'] = mpi_mean(np.mean(eval_episode_rewards_history))
                combined_stats['eval/Q'] = mpi_mean(eval_qs)
                combined_stats['eval/episodes'] = mpi_mean(len(eval_episode_rewards))

            # Total statistics.
            combined_stats['total/duration'] = mpi_mean(duration)
            combined_stats['total/steps_per_second'] = mpi_mean(float(t) / float(duration))
            combined_stats['total/episodes'] = mpi_mean(episodes)
            combined_stats['total/epochs'] = epoch + 1
            combined_stats['total/steps'] = t
            
            # for key in sorted(combined_stats.keys()):
                # logger.record_tabular(key, combined_stats[key])
            # logger.dump_tabular()
            # logger.info('')

            # if rank == 0 and logdir:
            #     if hasattr(env, 'get_state'):
            #         with open(os.path.join(logdir, 'env_state.pkl'), 'wb') as f:
            #             pickle.dump(env.get_state(), f)
            #     if eval_env and hasattr(eval_env, 'get_state'):
            #         with open(os.path.join(logdir, 'eval_env_state.pkl'), 'wb') as f:
            #             pickle.dump(eval_env.get_state(), f)
