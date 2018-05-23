#!/bin/bash
scripts_location='/usr/local/scripts'
data_location='/usr/local/data'



#######################
#convert
#######################

#get a clip extent of an existing dataset you want to base projection and grid on (suburban image)
gdaltindex $data_location/clipper.shp $data_location/Suburban200m_270m.tif

#Get the projection file for the suburban image
gdalsrsinfo -o wkt  $data_location/Suburban200m_270m.tif > $data_location/wkt.txt

# In following change in the source and output to match you image

# gdal warp the image to the new projection, clip it., resample it using an average of the pixels to a 270m grid (this may take awhile)
#gdalwarp -tr 270 270  -cutline clipper.shp -crop_to_cutline -r average -srcnodata 255 -dstnodata 255 -overwrite source.tif output_270_gdal.tif  -t_srs wkt.txt

#example road_noise
gdalwarp -tr 270 270  -cutline $data_location/clipper.shp -crop_to_cutline -r average -srcnodata 0 -dstnodata 0 -overwrite $data_location/road_noise.tif $data_location/road_noise_270_gdal.tif  -t_srs $data_location/wkt.txt

# then generate statistics
#gdalinfo -mm -stats -hist -checksum  output_gdal.tif
gdalinfo -mm -stats -hist -checksum  $data_location/road_noise_270_gdal.tif

# For some datasets due to the pixel size we may have to do another warp to get the data to line to the clip box. This “might” cause the data to shift.  This happens when the clip shape and the rast pixels intersect each other.  The first warp uses the full pixel that intersects the clip shape.   The second warp moves the output to the corner - “shifting” the data.  I want to make sure the data is not truly shifted and instead is rea calculating values based on average. We may have to make more pixels and do in multiples of 270 maybe try 90 first and see if the shift is less.
#
# do this after all process to get the raster to align to the  grid
# gdalwarp  -cutline clipper.shp -crop_to_cutline -overwrite  input_270_gdal.tif output_270_gdal_cut.tif

#gdalwarp  -cutline $data_location/clipper.shp -crop_to_cutline -overwrite  $data_location/road_noise_270_gdal.tif $data_location/road_noise_270_gdal_cut.tif
