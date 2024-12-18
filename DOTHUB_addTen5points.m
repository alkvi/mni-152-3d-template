function [allMeshes,allMeshesFileName] = DOTHUB_addTen5points(allMeshes, allMeshesFileName)

% Creates volumetric and surface meshes from tissue mask and creates the associated struct.
%
% #########################################################################
% INPUTS ##################################################################
% allMeshes               :  Input mesh to add 10-5 points to
%
% allMeshesFileName       :  The desired path &/ filename for the .mshs file.
%                            This can be anything, but we recommend this variable be defined with the
%                            following code snippet, where: origMaskFullFileName = full path and name
%                            of mask being used; landmarkFullFileName = full path and name of 
%                            landmarks file; This snippet also provides recommended input variable 'logData'. 
%        
%
% OUTPUTS #################################################################
%
% allMeshes               :  A structure containing all fields for allMeshes
%
% allMeshesFileName       :  The full path of the resulting .mshs file
%
% .mshs                   :  A file containing a structure of:
%
%                           % headVolumeMesh     :   The multi-layer volume mesh structure. 
%                                                    Contains fields: node, face, elem, labels
%
%                           % gmSurfaceMesh      :   The gm surface mesh structure. 
%                                                    Contains fields: node, face.
%
%                           % scalpSurfaceMesh   :   The scalp surface mesh structure.
%                                                    Contains fields: node, face.
%
%                           % vol2gm             :   The sparse matrix mapping from head volume mesh
%                                                    space to GM surface mesh space
%
%                           % landmarks          :   A matrix containing the
%                                                    landmarks coordinate
%
%                           % tenFive            :   ten-five locations for
%                                                    the mesh (.positions
%                                                    (nx3) and .labels {n})
%
%                           % logData            :   As defined above
%
%                           % fileName           :   The path of the saved mshs file
%
%
%
% ####################### Dependencies ####################################
% #########################################################################
%
% iso2mesh, interparc
%
% ############################# Updates ###################################
% #########################################################################
%
% Sabrina Brigadoi, 21/05/2020
%
% #########################################################################

%%%%% Checking all inputs are correct %%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    error('Not enough input arguments, please check the function help');
end

refpts = allMeshes.landmarks;

%%%%%%%%%%%%%%% Get 10-5 positions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Esctract the node of the external surface of the scalp
face_idx_ext_surf = faceneighbors(allMeshes.headVolumeMesh.elem(:,1:4),'surface');
node_idx_ext_surf = unique(face_idx_ext_surf(:));
surf = allMeshes.headVolumeMesh.node(node_idx_ext_surf,1:3); % creates the surface
    
% Bring landmarks' coordinates to the surface mesh
pts = bringPtsToSurf(surf,allMeshes.landmarks);

% Compute the 10-5 position
[refpts_10_5,refpts_10_5_label] = DOTHUB_getTen5points(surf,refpts);

allMeshes.tenFive.positions = refpts_10_5;
allMeshes.tenFive.labels = refpts_10_5_label;
    
%%%%%%%%%%%%%%% Create filename %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[pathstr,name,ext] = fileparts(allMeshesFileName);
if isempty(ext) || ~strcmpi(ext,'.mshs')
    ext = '.mshs';
end
if isempty(pathstr)
    pathstr = pwd;
end

allMeshesFileName = fullfile(pathstr,[name ext]);
allMeshes.fileName = allMeshesFileName; % including the fileName within the structure is very useful 
%for tracking and naming things derived further downstream.

if exist(allMeshesFileName,'file')
    warning([name ext ' will be overwritten...']);
end

%%%%%%%%%%%%%% Save .mshs file $%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(allMeshesFileName,'-struct','allMeshes');
fprintf('###################### Writing .mshs file ########################\n');
fprintf(['.mshs data file saved as ' allMeshesFileName '\n']);
fprintf('\n');

end

%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%

function pts = bringPtsToSurf(surf,pts)

n = size(pts, 1);
for i=1:n
    pts(i,:) = nearestPoint(surf,pts(i,:));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p2_closest,ip2_closest] = nearestPoint(p2,p1)

% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)

m=size(p1,1);

if(~isempty(p2) && ~isempty(p1))
    p2_closest=zeros(m,3);
    ip2_closest=zeros(m,1);
    dmin=zeros(m,1);
    for k=1:m
        d=sqrt((p2(:,1)-p1(k,1)).^2+(p2(:,2)-p1(k,2)).^2+(p2(:,3)-p1(k,3)).^2);
        [dmin(k),ip2_closest(k)]=min(d);
        p2_closest(k,:)=p2(ip2_closest(k),:);
    end
else
    p2_closest=[];
    ip2_closest = 0;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
