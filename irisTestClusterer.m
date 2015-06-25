% @ScriptName: irisTestClusterer.m
%% import data
close all;
data = importdata('iris.data.txt');
tags = importdata('iris.data.tags.txt');

%% implement the kMeans algorithm
clusterer = Clusterer(data,tags,3,10);
clusterer.kNN();
clusterer.Visualize('knn');
% while 1
% clusterer.kMeans();
% clusterer.evalError();
% if clusterer.KMeansError<40
%   break
% end
% end
% % data visualize
% clusterer.Visualize();

