#!/bin/bash

python3 ./../SGS_IPU_SDK_24071014/Scripts/ConvertTool/ConvertTool.py onnx \
--model_file ./yolov8n_640x640.onnx \
--output_file ./yolov8n_640x640_i6f.sim \
--input_arrays images \
--output_arrays output0 \
--input_shape 1,3,640,640 \
--input_config ./input_config_backbone.ini \
--soc_version souffle
