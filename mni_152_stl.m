%% Load DOT-HUB MNI152 template

rmap = load('AdultMNI152.mat');

%% Plot object with scatter

scatter3(rmap.scalpSurfaceMesh.node(:,1), ...
    rmap.scalpSurfaceMesh.node(:,2), ...
    rmap.scalpSurfaceMesh.node(:,3), ...
    '.','MarkerEdgeAlpha',.2);

%% Plot object with DOT-HUB

figure;
DOTHUB_plotRMAP('AdultMNI152.mat');

%% Add 10-5 points (added function)

[new_mesh, path_saved] = DOTHUB_addTen5points(rmap, 'AdultMNI152_10_5.mshs');

%% Plot object

figure;
DOTHUB_plotRMAP('AdultMNI152_10_5.mshs');

%% Convert to triangulation object 

TR = triangulation(new_mesh.scalpSurfaceMesh.face, new_mesh.scalpSurfaceMesh.node);

%% Plot triangulation object 

figure;
trisurf(TR);

%% Make indents

vertices = TR.Points;
faces = TR.ConnectivityList;
targetPoints = new_mesh.tenFive.positions;

% Find the nearest vertices to the target points
nearestVertices = knnsearch(vertices, targetPoints);

% Define the depth of the indent
indentDepth = 3; % 3mm

% Adjust the z-coordinate of the nearest vertices to create the indent
for i = 1:length(nearestVertices)
    vertices(nearestVertices(i), 3) = vertices(nearestVertices(i), 3) - indentDepth;
end

% Update the triangulation object with modified vertices
TR_indent = triangulation(faces, vertices);

%% Plot triangulation object 

figure;
trisurf(TR_indent);

%% Export as STL

stlwrite(TR_indent, 'mesh_dothub.stl');

%%  check result

bmodel = createpde('structural', 'static-solid');
importGeometry(bmodel, 'mesh_dothub.stl');

figure;
pdegplot(bmodel)