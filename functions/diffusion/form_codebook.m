function centers = form_codebook(descriptors, codebook_size, Max_Iterations)
%% function centers = form_codebook(descriptors, codebook_size)
%%
%% This function uses input features to form a codebook by k-means clustering 
%% algorithm. The code is modified from part of R. Fergus's bag of features code.
%% The clustering is performed using VGG code from Oxford written by Mark
%% Everingham. The source is provided, which must be compiled to a MEX file
%% for your given platform.
%% 
%% Function specification:
%% Input
%%      descriptors         :       input features [dim x num]
%%      codebook_size       :       size of codebook
%%      Max_Iterations      :       Max number of k-means iterations
%% Output
%%      centers             :       formed codebook [dim x codebook size]

Verbosity = 0;          %% Verbsoity of Mark's code

%% form options structure for clustering
cluster_options.maxiters = Max_Iterations;
cluster_options.verbose  = Verbosity;

%% call kmeans clustering routine by Mark Everingham
[centers,sse] = vgg_kmeans(double(descriptors), codebook_size, cluster_options);