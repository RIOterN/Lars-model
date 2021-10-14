% runSimEngine - Script to run the TCDI_EGR_VGT model
%
% Simulates TCDI_EGR_VGT.mdl at two different steps in VGT-position. The first
% step shows a non-minimum phase behavior and that the DC-gain is negative
% in the channel VGT to compressor mass flow W_c. The second step shows an
% overshoot and that the DC-gain is positive in the channel VGT to
% compressor mass flow W_c, i.e. there is a sign reversal in this channel.
% The inputs have the following ranges:
% Engine speed, n_e:       500-2000 rpm
% Fuel injection, u_delta: 1-250    mg/cycle
% EGR-valve, u_egr:        0-100    %
% VGT-position, u_vgt:     20-100   %


%    Copyright 2010, 2011, Johan Wahlström, Lars Eriksson
%
%    This package is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as
%    published by the Free Software Foundation, version 3 of the License.
%
%    This package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%    GNU Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.


clear

load untitled.mat %夹在

%control.u_egract=1;
% 1: with EGR-actuator dynamics
% 0: without EGR-actuator dynamics

%control.u_vgtact=1;
% 1: with VGT-actuator dynamics
% 0: without VGT-actuator dynamics


for step=1:2
    switch step
      case 1
        %set initial values for the inputs
        %First column: time vector
        %Second column: data vector
        simU.n_e=[0 1500]; 
        simU.u_delta=[0 110];
        simU.u_egr=[0 80];        
        simU.u_vgt=[0 75];
        

        %simulate the engine for the initial values
        sim('lars.slx',20)

        %set values for the input step
        %First column: time vector
        %Second column: data vector
        simU.u_vgt=[[0 1]' [75 65]'];
      case 2
        %set initial values for the inputs
        %First column: time vector
        %Second column: data vector
        simU.n_e=[0 1500]; 
        simU.u_delta=[0 110];
        simU.u_egr=[0 80];
        simU.u_vgt=[0 30];        
        
        %simulate the engine for the initial values
        %until it has reach a stationary point
        sim('lars.slx',20)

        %set values for the input step
        %First column: time vector
        %Second column: data vector
        simU.u_vgt=[[0 1]' [30 25]'];
    end

    %use final values from the initial simulation as initial state in the
    %simualtion of the step
    model.x_r_Init=simx_r(end);
    model.T_1_Init=simT_1(end);
    model.uInit_egr=simu_egr(end);
    model.uInit_vgt=simu_vgt(end);
    opt=simset('InitialState',xFinal);
    
    %simulate the step
    sim('lars.slx',8,opt)
      %collect variables from the simulation in a struct-format
    
    %pressure [Pa]
    simEngine.p_im=simp_im;
    simEngine.p_em=simp_em;
    %massflow [kg/s]
    simEngine.W_c=simW_c;
    %control signals
    simEngine.u_vgt=simu_vgt;
    %time [s]
    simEngine.time=simTime;
    %plot some interesting variables
    
    figure(step)
    clf
    subplot(2,2,1)
    plot(simEngine.time,simEngine.u_vgt)
    ylabel('vgt开度 [%]')
    oldaxis=axis;
    axis([0 8 oldaxis(3)-1 oldaxis(4)+1]) 

    subplot(2,2,2)
    plot(simEngine.time,simEngine.W_c)
    ylabel('W_{c} [kg/s]')

    subplot(2,2,3)
    plot(simEngine.time,simEngine.p_im)
    ylabel('进气歧管压强 [Pa]')
    xlabel('时间 [s]')

    subplot(2,2,4)
    plot(simEngine.time,simEngine.p_em)
    ylabel('排气歧管压强 [Pa]')
    xlabel('时间 [s]')
    
end
