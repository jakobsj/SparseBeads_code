% Script to run the SparseBeads Dataset sparsity experiments.
% Follows the tutorial as outlined in Section 5 in
% SophiaBeads Datasets Project Documentation and Tutorials.
% Available via http://eprints.ma.man.ac.uk/2290/
%
% Script is a modified version of sophiaBeads.m
% Users must download the latest version of the project codes via 
% http://sophilyplum.github.io/sophiabeads-datasets/
% 
% Use DOI 10.5281/zenodo.16539 to cite the project codes.
%
% Copyright (c) 2017 Sophia Bethany Coban
% University of Manchester.


addpath XTek/ tools/ mex/

filename = 'SparseBeads_B$$_L$'; % Name of the dataset e.g. 'SparseBeads_B1L1'
pathname = ['some_folder/' filename '/']; % Name of path where the dataset is stored e.g. '/media/somefolder/SparseBeads_B1L1/'.
geom_type = '2D'; % Necessary for loading data. Type can be '2D' or '3D' only.
experiment_name = 'CGLS_B1L1'; % For naming purposes... Change to any relevant experiment name or code.
iterations = 12; %    
%%%% ------------------------------- %%%%

% setup;    % Setup the mex files.
            % NOTE: You do not need to run this if the mex files already exist.
            %       For more info, type 'help setup' on the command window.

[data, geom] = load_nikon(pathname, filename, geom_type);
disp('Applying centre of rotation correction...');
geom = centre_geom(data, geom); data=data(:); 
% Update image offset to the centre of image. 
geom.image_offset = -(geom.voxels.*geom.voxel_size)/2; % Data is not cut for the sparsebeads 2D recons so we must update the image_offset here.
disp('Pre-reconstruction stage is complete!');

fprintf('\nReconstructing the SparseBeads dataset (%s)...\n',geom_type);
xcgls = cgls_XTek(data, geom, iterations);
xcgls = reshape(xcgls,geom.voxels);
disp('Reconstruction is complete!');

% Plot the reconstructions
figure;imagesc(xcgls);set(gca,'XTick',[],'YTick',[]);axis square;colormap gray;

% Write the reconstructed volume in the same path. 
volname = write_vol(xcgls, pathname, filename, experiment_name, 'single');
