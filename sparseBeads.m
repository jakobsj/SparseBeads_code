% Script to demonstrate loading and reconstructing the SparseBeads Dataset.
%
% Obtained from https://github.com/jakobsj/SparseBeads_code
% 
% Follows the tutorial as outlined in Section 5 in
% SophiaBeads Datasets Project Documentation and Tutorials.
% Available via http://eprints.ma.man.ac.uk/2290/
%
% Script is a modified version of sophiaBeads.m from the SophiaBeads codes.
% Users must download the latest version of the SophiaBeads codes via 
% http://sophilyplum.github.io/sophiabeads-datasets/
%
% Script must be placed within the SophiaBeads code directory to run.
% 
% Use DOI 10.5281/zenodo.16539 to cite the SophiaBeads project codes.
%
% Copyright (c) 2017 Sophia B. Coban & Jakob S. Jorgensen
% University of Manchester & Technical University of Denmark.

addpath XTek/ tools/ mex/

%%%% Manually modify these variables %%%%
beadset = 'B1L1'; % SparseBeads dataset identifier.
toppathname = '/media/somefolder/'; % Parent directory to dataset directory e.g. '/media/somefolder/' if this contains e.g. SparseBeads_B1L1/ directory.
iterations = 12; % Number of CGLS iterations to run

% Derived parameters
filename = ['SparseBeads_',beadset]; % Name of the dataset e.g. 'SparseBeads_B1L1'
pathname = fullfile(toppathname,filename); % Name of path where the dataset is stored e.g. '/media/somefolder/SparseBeads_B1L1/'.
geom_type = '2D'; % Necessary for loading data. Type can only be '2D' for SparseBeads.
experiment_name = 'CGLS_Demo'; % For naming purposes... Change to any relevant experiment name or code.

%%%% ------------------------------- %%%%

% setup;    % Setup the mex files.
            % NOTE: You do not need to run this if the mex files already exist.
            %       For more info, type 'help setup' on the command window.

% Load and apply corrections to data
[data, geom] = load_nikon(pathname, filename, geom_type);
disp('Applying centre of rotation correction...');
geom = centre_geom(data, geom); data=data(:); 
% Update image offset to the centre of image. 
geom.image_offset = -(geom.voxels.*geom.voxel_size)/2; % Data is not cut for the sparsebeads 2D recons so we must update the image_offset here.
disp('Pre-reconstruction stage is complete!');

% Perform CGLS reconstruction
fprintf('\nReconstructing the SparseBeads dataset (%s)...\n',geom_type);
xcgls = cgls_XTek(data, geom, iterations);
xcgls = reshape(xcgls,geom.voxels);
disp('Reconstruction is complete!');

% Display the reconstructed slice.
figure;imagesc(xcgls);axis square;axis off;colormap gray;

% Write the reconstructed slice in the same path. 
volname = write_vol(xcgls, pathname, filename, experiment_name, 'single');

% Load and display the FDK slice 
pathname_recon = fullfile(pathname,[filename,'_RECON2D']); % FDK reconstruction for each dataset is included in a subfolder ending in "_RECON2D"
filename_recon = 'SparseBeads';
experiment_name_recon = beadset;
voxels = [2000 2000 1]; % Dimensions of the reconstructed slice.
FDK_soln = read_vol(pathname_recon, filename_recon, experiment_name_recon, voxels); % Read volume.
figure;imagesc(FDK_soln);axis square;axis off;colormap gray; % Display the reconstructed slice.
