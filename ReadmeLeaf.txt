...........................................................................
NPP leaf calculations
contact: nataliacoupe@gmail.com
...........................................................................

The NPPleaf calculations for the observations are similar to a bucket (LAI) model in which we add the flush and substract the leaf fall.
For the model outputs, we are doing something different, we assume that the changes in leaf carbon are the NPPleaf.  Because there is no litterfall output from the models we rely on the apparent separation in time between leaf flush (in the early to mid growing season, when all dLAI/dt is due to leaf production), and litterfall (in the end of the growing season, when all dLAI/dt is due to abcission), when NPPleaf is negative  and remove those values as we are only interested in the leaf production. 

...........................................................................
Models output:

ORCHIDEE >> file: TRUNK.txt >> column: leaf_M >> dates: 1-Jan-1900>1-Dec-1999 
         >> period: subsampled to 1991-1999
         >> time step: 1-day
         >> units: gC/m2
CLM      >> file: US-Ha1_I20TRCLM45CBCN.clm2.h0.1991-2013.daily.nc >> variable: cleaf >> 
         >> dates: 28-Nov-1990>28-Nov-201 (subsampled to 1990-2013) >> units:KgC m-2
         >> period: subsampled to 1991-2013
         >> time step: 1-day
...........................................................................
Observations:

NPPleaf = (dLAI/dt.*SLA) + litter;
LAI: leaf area index [unitless]
dLAI/dt: change in LAI per unit time [/day]
SLA: specific leaf area [g m-2]
litter: litter fall [g m-2 d-1]

Biomass Inventories at Harvard Forest EMS Tower since 1993
Literfall 'hf069-05-litter.txt'
January to March set to zero > interpolated to monthly values

LAI: 'hf069-02-LAI-site.txt'
Dates: 1998-2000 and 2006-2018

Observations are not at a fixed frequency and LAI and litter-fall can be measured at different times, as well. Therefore, I linearly interpolated the observations to daily values and then calculated NPPleaf.

SLA [mg cm-2] >>> g/1000 10000/m2  >>> g*10/m2
https://escholarship.org/content/qt7ht7565c/qt7ht7565c.pdf
Scaling gross ecosystem production at Harvard Forest with remote sensing: a 
comparison of estimates from a constrained quantum‐use efficiency model and eddy correlation
Waring, Law, Goulden et al. 1995
% August mg cm-2  5.46 + 8.22 + 5.05 + 9.76 + 5.67 + 8.65 + 4.10 + 9.83
% September mg cm-2 4.92 + 8.96 + 5.79 + 8.72 + 6.94 + 8.76 + 3.55 + 5.61

Biomass Inventories at Harvard Forest EMS Tower since 1993
http://harvardforest.fas.harvard.edu:8080/exist/apps/datasets/showData.html?id=hf069
    Lead: William Munger, Steven Wofsy
    Investigators: Carol Barford, David Bryant, Victoria Chow, Daniel Curran, Evan Goldman, Elizabeth Hammond-Pyle, Lucy Hutyra, Christine Jones, Kathryn McKain, Leland Werden, Timothy Whitby
    Contact: Timothy Whitby
    Start date: 1993
    End date: 2017
    Status: ongoing
    Location: Prospect Hill Tract (Harvard Forest)
    Latitude: +42.54
    Longitude: -72.17
    Elevation: 340 meter
    Taxa: Acer rubrum (red maple), Acer pensylvanicum (striped maple), Betula alleghaniensis (yellow birch), Betula lenta (black birch), Betula papyrifera (paper birch), Betula populifolia (grey birch), Fagus grandifolia (american beech), Fraxinus americana (white ash), Hamamelis virginiana (witch hazel), Picea glauca (white spruce), Pinus resinosa (red pine), Pinus strobus (white pine), Prunus serotina (black cherry), Quercus alba (white oak), Quercus rubra (northern red oak), Quercus velutina (black oak), Tsuga canadensis (eastern hemlock)
    Release date: 2018
    Revisions:
    EML file: knb-lter-hfr.69.30
    DOI: digital object identifier
    Related links:
        Project Website
        Canopy-Atmosphere Exchange of Carbon, Water and Energy at Harvard Forest EMS Tower since 1991
    Study type: long-term measurement
    Research topic: large experiments and permanent plot studies
    LTER core area: primary production
    Keywords: biomass, carbon dioxide, coarse woody debris, litter, soil moisture, soil respiration
    Abstract:

    In 1993, we installed 40 circular, 10 m radius biometric plots in the footprint of the EMS tower on Prospect Hill. We randomly placed the plots within 100 m increments along ten 500 m transects that extend from the tower in the northwest and southwest directions. In 2001, we removed three plots (G3, H3, H4) from the datasets and ceased measurements there due to their inundation by a beaver pond. In 1999, we installed 6 additional circular, 10 m radius biometric plots on the Simes Lot, adjacent to Prospect Hill to study the effects of a selective harvest that occurred there in the winter of 2000-01. In the summer of 2001, we expanded the harvested plots in size to 15 m radius and ceased measurements at one plot (X4) because it was unaffected by the harvest. The harvest also affected three of the original tower plots (A4, A5, B5), which were expanded in size as a part of the harvest plot group. Consequently, there are 34 tower plots and 8 harvest plots. We have taken the following ecological measurements at each site: tree growth, woody debris, litter, leaf area increment (LAI), leaf chemistry, and soil respiration and moisture.
    
    



