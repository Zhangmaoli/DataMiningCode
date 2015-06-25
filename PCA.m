classdef PCA<handle
% @Classname: PCA
% @Author: KellyHwong
% @Update: 2015.6.23
% @Description:
% @Initialize:
% @Codestyle: Matlab(variables use camel, methods use lower case)
% TODO 除数不能为零的异常，还没有处理
  properties
    data;
    cov;
    U;
    S;
    V;
    z;
  end
  methods(Static)
    function z = dimreduce(dataIn,k)
      %% obj.data preprocess
      obj.data = dataIn; % Not change original obj.data
      minVector = min(obj.data);maxVector = max(obj.data);
      for j=1:size(obj.data,1)
        obj.data(j,:) = (obj.data(j,:)-minVector)./(maxVector-minVector); % feature scaling
      end
      % obj.data m-by-n
      mu = mean(obj.data); % 平均值 1-by-n
      sigma = std(obj.data); % 标准差无偏估计 1-by-n
      for j=1:size(obj.data,1)
        obj.data(j,:) = (obj.data(j,:)-mu)./sigma;
      end
      %% SVD
      obj.cov = obj.data' * obj.data; % (n-by-m multiplied by m-by-n)
      % cov n-by-n covariance matrix
      [obj.U,obj.S,obj.V] = svd(obj.cov);

      u_reduce = obj.U(:,1:k); % Choose k most importance feature
      % u_reduce n-by-k
      z = obj.data * u_reduce;
      % m-by-n multiplied by n-by-k is m-by-k
      obj.z = z;
    end
  end
end
