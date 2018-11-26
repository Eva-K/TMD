%% |recenter| documentation 
% The |recenter| function rewraps a gridded dataset to be centered on a specified longitude. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  [lat,lon] = recenter(lat,lon)
%  [lat,lon,Z1,Z2,...,Zn] = recenter(lat,lon,Z1,Z2,...,Zn)
%  [...] = recenter(...,'center',centerLon)
% 
%% Description 
% 
% |[lat,lon] = recenter(lat,lon)| rewraps a global |lat,lon| grid such that it is centered on the 
% Prime Meridian (zero longitude). A common application is to convert a grid spanning 0 to 360 
% into a grid spanning -180 to 180.  Inputs |lat| and |lon| must be 2D grids as if created by |meshgrid|.
% 
% |[lat,lon,Z1,Z2,...,Zn] = recenter(lat,lon,Z1,Z2,...,Zn)| rewraps input grids |lat,lon| along with 
% any other datasets |Zn| of corresponding dimensions. Any of the |Z| datasets can be 2D of exactly
% the same dimensions as |lat| and |lon|, or can be 3D, whose first two dimensions correspond to the 
% |lat,lon| grids and the third dimension might correspond to time or depth.  
% 
% |[...] = recenter(...,'center',centerLon)| centers gridded data on any specified longitude. Default 
% |centerlon| is |0| degrees. 
% 
%% Example 1: Theoretical data points 
% Here's a 10 degree resolution grid with longitude values that go from 0 to 360:

[lon,lat] = meshgrid(0:10:360,-85:10:85); 

plot(lon,lat,'bx') 
xlabel 'longitude'
ylabel 'latitude' 

%% 
% Recenter the grid such that its midpoint lies at the Prime Meridian: 

[lat2,lon2] = recenter(lat,lon); 

hold on
plot(lon2,lat2,'ro') 

%% Example 2: Application to sea surface temperature data 

load global_sst.mat

% Convert lat,lon arrays to grid format: 
[lon,lat] = meshgrid(lon,lat); 

figure
imagescn(lon,lat,sst) 
axis image
cmocean thermal 

%% 
% The grid is already centered on the Prime Meridian.  But what if your research focuses on Hawaii? Then perhaps
% you'd like to center the map on 156 W: 

[lat,lon,sst] = recenter(lat,lon,sst,'center',-156); 

imagescn(lon,lat,sst) 
axis image 

%% Author Info 
% The |recenter| function and supporting documentation was written by <http://www.chadagreene.com Chad A. Greene> of 
% the University of Texas Institute for Geophysics (UTIG), February 2017.  

