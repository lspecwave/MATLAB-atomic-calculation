

clear all
close all

% Cat state Ramsey fringes
% Coherent state Ramsey fringes

main_dir='\\Artemis-pc\e\Data\2022-12-09\Abs-2200';

% load([main_dir,'\average.mat'],'f_pop_decay');
% 
% load([main_dir,'\average.mat'],'f_amp_decay');

f_pop_decay=openfig([main_dir,'\PopulationDecay.fig'],'Visible');
f_amp_decay=openfig([main_dir,'\AmpDecay.fig'],'Visible');


ax_1=get(f_pop_decay,'CurrentAxes');
ax_2=get(f_amp_decay,'CurrentAxes');



figure
t = tiledlayout(2,2,'TileSpacing','tight','Padding','tight');

ax1=nexttile;

ax_1_C=get(ax_1,'Children');
handle_1=copyobj(ax_1_C, ax1);

ax2=nexttile;

ax_2_C=get(ax_2,'Children');
handle_2=copyobj(ax_2_C, ax2);

ax3=nexttile;
plot(1:10,sin(1:10))


