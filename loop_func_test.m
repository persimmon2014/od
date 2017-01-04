%# This script is the main interface for testing loop reading functions.

clear all; close all; clc;
addpath(genpath('./func'));
load('sf_extra.mat', 'sf_loop_1216');


filepath = '../data/new_data/loop/'; % speicfy where the loop data are


for i = 1:size(sf_loop_1216,1)
    result = readLoopData(sf_loop_1216(i,1),'speed',filepath); % flow, occupancy, speed
    figure('name',num2str(sf_loop_1216(i,1)));
    stem(result);
end



