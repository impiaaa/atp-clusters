#!/bin/bash

in_path=$(realpath --relative-to=$(pwd) "$1")

echo "<OGRVRTDataSource>"
echo "  <OGRVRTUnionLayer name=\"merged\">"
zipinfo -1 "$in_path" | grep .geojson | while read json_name; do
    layer_name=$(basename "$json_name" .geojson)
    echo "    <OGRVRTLayer name=\"$layer_name\">"
    echo "      <SrcDataSource shared=\"1\">/vsizip/$in_path/$json_name</SrcDataSource>"
    echo "      <SrcLayer>$layer_name</SrcLayer>"
    echo "    </OGRVRTLayer>"
done
echo "  </OGRVRTUnionLayer>"
echo "</OGRVRTDataSource>"
