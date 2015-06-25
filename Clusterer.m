classdef Clusterer<handle
% @Classname: Clusterer
% @Author: KellyHwong
% @Update: 2015.6.22
% @Description: A Clusterer class that implements the KMeans,
%    KNN, Centroid clustering function
% @Initialize: Inputting the data matrix
% @Methods:
% @Codestyle: Java(properties begin with upper case, methods use camel)
properties
  Data; % Data Matrix
  nLabel;
  TrueLabels;
  TrueClusters;
  % kMeans parameterss
  Clusterlabels;
  ClusteredData; % Cell, K clustered data matrices
  KMeans;
  KMeansError;
  K; % Num of clusters
  M; % Num of samples
  N; % Num of features
  % NotChangeThreshold = 0.00001; % Not used

  % kNN parameters
  kN; % Num of nearest neighbors
  kNNDataTrain;
  kNNLabelTrain;
  kNNDataTest;
  kNNLabelTest; % Test set true labels
  kNNLabelTestPredict;
  nTrain = 50;
  nTest;
end % properties

methods
  function obj = Clusterer(data,labels,k,kN)
    if isnumeric(data)
      obj.Data = data;
      obj.M = size(data,1);
      obj.N = size(data,2);
      obj.nLabel = length(unique(labels));
      obj.nTest = obj.M - obj.nTrain;
    else
      error('Value must be numeric')
    end
    obj.K = 2; % set default num of clusters
    if nargin > 1
      obj.TrueLabels = labels;
      % Push the data into diffrent matrix
      obj.TrueClusters = Clusterer.clusterdata(data, labels, k);
    end
    if nargin > 2
      obj.K = k;
    end
    if nargin > 3
      obj.kN = kN;
    end
    [obj.kNNDataTrain,obj.kNNLabelTrain,obj.kNNDataTest,obj.kNNLabelTest] = ...
      Clusterer.splitdataintotrainandtest(obj.Data,obj.TrueLabels,obj.nTrain);
  end % function Constructer

  function labels = kMeans(obj)
    k = obj.K; m = obj.M; n = obj.N;
    labels = zeros([obj.M],1);
    % Randomly choose k data points from Data
    kPtr = randperm(m,n);
    kPtr = sort(kPtr);
    kmeans = zeros(k,n);
    for i = 1:obj.K
      kmeans(i,:) = obj.Data(kPtr(i),:);
      labels(i) = i; % Number the clusters
    end
    while 1
      % Reassign points in Data to closet cluster mean
      dists = zeros(1,k);
      for j = 1:m
        for i = 1:k
          % dists(i) = Clusterer.euclideanDistance(obj.Data(j,:),kmeans(i,:));
          dists(i) = Clusterer.minkowskiDistance(obj.Data(j,:),kmeans(i,:));
        end
        labels(j) = find(dists==min(dists),1); % Debug: if there are two or
          % or more same dist, choose the first cluster as default
      end
      % Computer the new kmeans
      % Push the data into diffrent matrix
      clusteredData = Clusterer.clusterdata(obj.Data, labels, k);
      % Compare the new kmeans with the old ones
      kmeansNew = zeros(k,n);
      for i = 1:k
        kmeansNew(i,:) = mean(clusteredData{i}); % mean func calc the mean of
          % each colomn of the matrix, and form a row vector
      end
      % if kmeansNew == kmeans, stop
      %if sum(kmeansNew - kmeans) < obj.NotChangeThreshold
      if abs(sum(kmeansNew - kmeans)) <eps(sum(kmeansNew))
        break
      else
        kmeans = kmeansNew;
      end
    end
    obj.KMeans = kmeans;
    obj.ClusteredData = clusteredData;
    obj.Clusterlabels = labels;
  end % function kMeans

  function kNNLabelTestPredict = kNN(obj)
    % kNNLabelTest % Not used, used to eval error
    kNNLabelTestPredict=zeros(obj.M-obj.nTrain,1);
    for i=1:obj.M-obj.nTrain
      [~,neighborsPtr]=Clusterer.findknearestneighbors(obj.kNNDataTrain,...
          obj.kNNDataTest(i,:),obj.kN);
      kNNLabelTestPredict(i)=Clusterer.choosecluster(obj.kNNLabelTrain(neighborsPtr),...
          max(obj.kNNLabelTrain));
      obj.kNNLabelTestPredict = kNNLabelTestPredict;
    end
  end % function clusterlabels

  function obj = evalError(obj)
    obj.KMeansError = sum([obj.Clusterlabels]~=obj.TrueLabels);
  end

  function Visualize(obj,strIn)
    stylelist = ['y','o';'m','+';'c','*';'r','.';'g','x';
      'b','s';'w','d';'k','^';];
    pca = PCA;
    if strcmp(strIn,'kmeans')
      % Cluster using kMeans
      figure();subplot(1,2,1);
      hold on;grid on;title('Cluster using kMeans');
      z = pca.dimreduce(obj.Data,2);
      for i=1:obj.M
        style = stylelist(obj.Clusterlabels(i),:);
        scatter(z(i,1),z(i,2),style);
      end
      % Cluster by original labels
      subplot(1,2,2);hold on;grid on;title('Cluster by original labels');
      z = pca.dimreduce(obj.Data,2);
      for i=1:obj.M
        style = stylelist(obj.TrueLabels(i),:);
        scatter(z(i,1),z(i,2),style);
      end
    elseif strcmp(strIn,'knn')
      % Cluster using kNN
      z = pca.dimreduce(obj.kNNDataTest,2);
      figure();subplot(1,2,1);
      hold on;grid on;title('Cluster using kNN');
      for i=1:obj.nTest
        style = stylelist(obj.kNNLabelTestPredict(i),:);
        scatter(z(i,1),z(i,2),style);
      end
      subplot(1,2,2);
      hold on;grid on;title('Cluster by original labels');
      for i=1:obj.nTest
        style = stylelist(obj.kNNLabelTest(i),:);
        scatter(z(i,1),z(i,2),style);
      end
    end
  end % function Visualize
end % General methods

methods(Static)
  function [kNNDataTrain,kNNLabelTrain,kNNDataTest,kNNLabelTest] = ...
    splitdataintotrainandtest(data,labels,nTrain)
    m = size(data,1);n = size(data,2);
    dataTrainPtr = randperm(m,nTrain);
    while 1
      kNNLabelTrain = zeros(nTrain,1);
      for i=1:nTrain
        kNNLabelTrain(i)=labels(dataTrainPtr(i));
      end
      if length(unique(kNNLabelTrain))==length(unique(labels)) 
        % Make sure to cover all kinds of labels
        break;
      end
    end
    dataTestPtr = zeros(m-nTrain,1);j=1;
    kNNLabelTest = zeros(m-nTrain,1);
    for i=1:m
      if isempty(find(dataTrainPtr==i,1))
        dataTestPtr(j)=i;
        kNNLabelTest(j)=labels(dataTestPtr(j));
        j=j+1;
      end
    end
    kNNDataTrain = zeros(nTrain,n);
    kNNDataTest = zeros(m-nTrain,n);
    for i=1:length(dataTrainPtr)
      kNNDataTrain(i,:) = data(dataTrainPtr(i),:);
    end
    for i=1:length(dataTestPtr)
      kNNDataTest(i,:) = data(dataTestPtr(i),:);
    end
  end % function splitdataintotrainandtest

  function [dists,neighborsPtr] = ...
    findknearestneighbors(kNNDataTrain,onedata,kN)
    nT = size(kNNDataTrain,1);
    dists = zeros(nT,1);
    for i=1:nT
      dists(i) = Clusterer.euclideanDistance(kNNDataTrain(i,:),onedata);
    end
    [dists,neighborsPtr] = sortrows(dists);
    dists = dists(1:kN);
    neighborsPtr = neighborsPtr(1:kN);
  end % function findknearestneighbors

  function label = choosecluster(kLabels,nLabel)
    kn = length(kLabels);
    votecounts = zeros(nLabel,1);
    for i=1:kn
      votecounts(kLabels(i))=votecounts(kLabels(i))+1;
    end
    [~,label] = max(votecounts);
  end

  function dist = euclideanDistance(x, y)
  % Assert x and y are row/colomn vector in the same dim
  dist = sqrt(sum((x-y).^2));
  end % function euclideanDistance
  function dist = minkowskiDistance(x, y)
    dist = sum(abs(x-y));
  end % function minkowskiDistance

  function clusteredData = clusterdata(data, labels, k)
    % Push the data into diffrent matrix
    j = ones(1,k);
    m = size(data, 1);
    n = size(data, 2);
    clusteredData = cell(1,k);
    for i = 1:k
      clusteredData{i} = zeros(size(find(labels==i),1),n);
    end
    for i = 1:m
      clusteredData{labels(i)}(j(labels(i)),:) = data(i,:);
      j(labels(i)) = j(labels(i)) + 1;
    end
  end % function clusterdata
end % Static methods

end % Class Clusterer
