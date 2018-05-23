#  sample to convert images using gdal and docker road noise

## start gdal docker container
```
docker-compose  -p gdal -f docker-compose.yml up -d
```

run script to convert road noise on docker container - script with convert the road_noise
```
docker exec gdal /usr/local/scripts/convert_imagery.sh
```

Note the exported resampled road noise image will be in the data directory.

## Alternatively you can run each gdal command line by line

get a clip extent of an existing dataset you want to base projection and grid on (suburban image)
```
docker exec gdal gdaltindex /usr/local/data/clipper.shp /usr/local/data/Suburban200m_270m.tif
```

Get the projection file for the suburban image
```
docker exec gdal sh -c 'gdalsrsinfo -o wkt  /usr/local/data/Suburban200m_270m.tif > /usr/local/data/wkt.txt'
```

In following change in the source and output to match you image

gdal warp the image to the new projection, clip it., resample it using an average of the pixels to a 270m grid (this may take awhile)
example: gdalwarp -tr 270 270  -cutline clipper.shp -crop_to_cutline -r average -srcnodata 255 -dstnodata 255 -overwrite source.tif output_270_gdal.tif  -t_srs wkt.txt

with road_noise image
```
docker exec gdal gdalwarp -tr 270 270  -cutline /usr/local/data/clipper.shp -crop_to_cutline -r average -srcnodata 0 -dstnodata 0 -overwrite /usr/local/data/road_noise.tif /usr/local/data/road_noise_270_gdal.tif  -t_srs /usr/local/data/wkt.txt
```

then generate statistics
example: gdalinfo -mm -stats -hist -checksum  output_gdal.tif
```
docker exec gdal gdalinfo -mm -stats -hist -checksum  /usr/local/data/road_noise_270_gdal.tif
```

**NOTE: this step is NOT necessary if the upper left and right line up**

For some datasets due to the pixel size we may have to do another warp to get the data to line to the clip box. This “might” cause the data to shift.  This happens when the clip shape and the raster pixels intersect each other.  The first warp uses the full pixel that intersects the clip shape.   The second warp moves the output to the corner - “shifting” the data.  I want to make sure the data is not truly shifted and instead is calculating values based on average. We may have to make more pixels and do in multiples of 270 maybe try 90 first and see if the shift is less.

do this after all process to get the raster to align to the grid
example: gdalwarp  -cutline clipper.shp -crop_to_cutline -overwrite  input_270_gdal.tif output_270_gdal_cut.tif

**NOTE: this step is NOT necessary if the upper left and right line up**
  ```
  docker exec gdal gdalwarp  -cutline /usr/local/data/clipper.shp -crop_to_cutline -overwrite  /usr/local/data/road_noise_270_gdal.tif /usr/local/data/road_noise_270_gdal_cut.tif
  ```

## Shut docker container down
```
docker-compose  -p gdal -f docker-compose.yml down
```
