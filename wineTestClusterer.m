% @ScriptName: wineTestClusterer.m
%% Import Wine data
close all;
data = importdata('wine.data.txt'); % data have 13 attrib
tags = importdata('wine.data.tags.txt');


%% kMeans
% clusterer = Clusterer(data,tags,3,20); % Original data
% clusterer.kMeans();
% clusterer.Visualize('kmeans');

% pca = PCA;
% z = pca.dimreduce(data,5);
% clusterer = Clusterer(z,tags,3,20); % After standardization
% clusterer.kMeans();
% clusterer.Visualize('kmeans');


%% kNN
% clusterer = Clusterer(data,tags,3,20); % After standardization
% clusterer.kNN();
% clusterer.Visualize('knn');

pca = PCA;
z = pca.dimreduce(data,5);
clusterer = Clusterer(z,tags,3,20); % After standardization
clusterer.kNN();
clusterer.Visualize('knn');

