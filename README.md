# ss539
usage guild

# install
1. install pretrained model 
```
tar -xvJf SGS_Models.tar.xz
```
2. install docker
``` 
cd dockerfile_v1.7/
docker build -t sgs_docker:v1.7 .
dos2unix ./run_docker.sh 
```
3. run docker
```
cd ~/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/dockerfile_v1.7
./run_docker.sh 
```

4. test convert
```
#in docker
cd /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK/
source cfg_env.sh
cd Scripts/
python3 ConvertTool/ConvertTool.py -h
```
```
#in docker
python3 ConvertTool/ConvertTool.py onnx --model_file /work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/yolov10n.onnx --input_shapes 1,3,640,640 --input_config /work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/input.cfg --output_file yolov10_float.sim
```
the input config is as 
```
[INPUT_CONFIG]
inputs='input';
training_input_formats=BGR;
input_formats=BGR;
quantizations=TRUE;
mean=127.5:127.5:127.5;
std_value=1.0;

[OUTPUT_CONFIG]
outputs='output';
dequantizations=TRUE;

[CONV_CONFIG]
tensor_arrays='conv1-1,conv2-1';
```
