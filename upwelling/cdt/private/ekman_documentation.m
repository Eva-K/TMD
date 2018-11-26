%% |ekman| documentation
% The |ekman| function estimates the classical <https://en.wikipedia.org/wiki/Ekman_transport Ekman transport> and upwelling/downwelling from 10 m winds. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  [UE,VE,wE] = ekman(lat,lon,u10,v10)
%  [UE,VE,wE] = ekman(...,'Cd',Cd)
%  [UE,VE,wE] = ekman(...,'rho',waterDensity)
%  [UE,VE,wE,dE] = ekman(...)
% 
%% Description 
% 
% |[UE,VE,wE] = ekman(lat,lon,u10,v10)| estimates the zonal (|UE|, m^2/s) and meridional (|VE|, m^2/s)  
% Ekman layer transports along with vertical velocities (|wE|, m/s) associated with Ekman pumping. 
% Positive values of |wE| indicate upwelling. Inputs |lat| and |lon| must be 2D grids whose dimensions 
% zonal (|u10|, m/s) and meridional (|v10|, m/s) wind speeds taken 10 m above the surface. Wind speeds
% are automatically converted to wind stress via <windstress_documentation.html |windstress|> before performing the Ekman transport calculations. 
% Inputs |u10| and |v10| can be 2D grids the same size as |lat| and |lon|, or they can be 3D matrices whose
% first two dimensions correspond to |lat| and |lon|, with a third dimension corresponding to time.  
% 
% |[UE,VE,wE] = ekman(...,'Cd',Cd)| specifies a drag coefficient for wind stress calculation. |Cd| can 
% be a scalar or a matrix whose dimensions match |u10| and |v10|. Default |Cd| is |1.25e-3|. 
% 
% |[UE,VE,wE] = ekman(...,'rho',waterDensity)| specifies water density. Default is |1025| kg/m3. 
% 
% |[UE,VE,wE,dE] = ekman(...)| also gives an approximate Ekman layer depth |dE|. 
% 
%% Example
% Here's some wind and sea surface temperature data.  Load and plot the sea surface temperatures and wind.  Below I'm using 
% <https://www.mathworks.com/matlabcentral/fileexchange/61293-imagescn |imagescn|> to make |NaN| values
% transparent, but you can use |imagesc| if you prefer.  The colormap is set by the <https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps/content/cmocean/html/cmocean_documentation.html
% |cmocean|> function (<http://dx.doi.org/10.5670/oceanog.2016.66 Thyng et al., 2016>). 
% 
% The full dataset contains 417x761 grid cells, which would be far too many |quiver| arrows to plot because each arrow would
% need to be about the size of a pixel on your screen.  If you have the Image Processing Toolbox, it's easy
% to resample the wind fields with |imresize|.  A simpler way to resample that does not require any special
% toolboxes is just to plot every 20th data point, but I prefer |imresize| because it's more elegant, and
% more importantly, it anti-aliases before downsizing.  To get the RGB values of dark gray I'm using <https://www.mathworks.com/matlabcentral/fileexchange/46872-intuitive-rgb-color-values-from-xkcd/content/XKCD_RGB/html/rgb_demo.html 
% |rgb|>.

load pacific_wind.mat

figure
imagescn(lon,lat,sst)
axis image    % (trims away extra whitespace and sets aspect ratio to 1:1)
cmocean thermal  
cb = colorbar; 
ylabel(cb,' sea surface temperature ({\circ}C) ')

hold on
sc = 0.06; % scaling factor to use in imresize
quiver(imresize(lon,sc),imresize(lat,sc),imresize(u10,sc),imresize(v10,sc),'color',rgb('dark gray'));

%%
% To prevent any possible mixups of dimensions, the |ekman| function does not accept lats and lons as 
% vectors, so we have to convert |lat| and |lon| to 2D grids with |meshgrid| before calculating 
% Ekman transport. 

[Lon,Lat] = meshgrid(lon,lat); 
[UE,VE,wE] = ekman(Lat,Lon,u10,v10); 

%% 
% Plot vertical velocities |wE| after masking-out land values.  Conveniently, our |sst| dataset is 
% already |NaN| wherever there's land, so we can use |sst| to make a mask: 

% Mask-out land values: 
wE(isnan(sst)) = nan; 

figure
imagescn(lon,lat,wE*1e7); 
axis image 
caxis([-1 1]*40)
cmocean -delta
cb = colorbar; 
ylabel(cb,'Ekman velocity m x 10^{-7}/s')

%% Coastal upwelling off California
% Upwelling near the California coast is an important process for climate and biology. Let's take a 
% closer look: 

axis([-140 -107 22 45])

%%
% The blue areas correspond to upwelling and are the result of divergent transport of surface 
% water.  Let's plot the wind vectors in dark gray as before, but now we'll also plot the Ekman
% transport as red vectors: 

hold on

% Plot wind vectors: 
quiver(imresize(lon,sc),imresize(lat,sc),imresize(u10,sc),imresize(v10,sc),'color',rgb('dark gray'));

% Plot Ekman transport vectors:
quiver(imresize(lon,sc),imresize(lat,sc),imresize(UE,sc),imresize(VE,sc),'color',rgb('bright red'));

%% 
% Just as we expect, the surface layer transport is 90 degrees to the right of wind direction 
% in the northern hemisphere, and that's what drives Ekman upwelling. 

%% Mimicking Kessler
% Similarly, let's take a look at the region analyzed by <https://doi.org/10.1175/1520-0485-32.9.2457 Kessler 2002>. 
% We'll recreate Kessler's Figure 6b, which plots upwelling in units of meters per month.  There are 
% 2629800 seconds in a month, so we have to multiply |wE| by that number before contouring. Also, Kessler's 
% color axis is nonlinear, so we'll use his contour values, but I'm not going to worry about stetching
% and compressing the colorbar to match Kessler.

cvals = [-40 -20 -10 -5 -2.5 -1 - 2.5 5 10 20 40]; 

figure
contourf(lon,lat,wE*2629800,cvals); 
axis xy image 
caxis([-1 1]*40)
cb = colorbar; 
ylabel(cb,'Ekman velocity m/month')

axis([-110 -80 8 23])
set(gca,'color',rgb('gray'))
cmocean -balance

%% References 
% 
% Kessler, William S. "Mean three-dimensional circulation in the northeast tropical Pacific." Journal of Physical Oceanography
% 32.9 (2002): 2457-2471. <https://doi.org/10.1175/1520-0485-32.9.2457  doi:10.1175/1520-0485-32.9.2457>.
% 
% Thyng, K.M., C.A. Greene, R.D. Hetland, H.M. Zimmerle, and S.F. DiMarco. 2016. True colors of oceanography: Guidelines for
% effective and accurate colormap selection. Oceanography 29(3):9-13, <http://dx.doi.org/10.5670/oceanog.2016.66 doi:10.5670/oceanog.2016.66>.
% 
%% Author Info
% The |ekman| function and supporting documentation were written by <http://www.chadagreene Chad A. Greene> of the University
% of Texas at Austin (UTIG), February 2017.  
