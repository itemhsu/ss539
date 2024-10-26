# ss539
usage guild

# install
1. install pretrained model 
```
tar -xvJf SGS_Models.tar.xz
```
2. install docker
```
cd ~/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/
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
* soc_version is
  
| soc_version  | Type |
| ------------- | ------------- |
| muffin  |  |
| maruko  |  |
| opera  |  |
| souffle  | 539 |
| iford  |  |
| ifado |  |
| pcupid |  |

* the input config is as
```
[INPUT_CONFIG]
inputs=images;
input_formats=YUV_NV12;
training_input_formats=RGB;
quantizations=TRUE;
mean_red=0.0;
mean_green=0.0;
mean_blue=0.0;
std_value=255;

[OUTPUT_CONFIG]
outputs=output0;
dequantizations=FALSE;
[CONV_CONFIG]
input_format=ALL_INT16;

```

# Get yolo v10 onnx from pytorch
### Source
```
git clone https://github.com/THU-MIG/yolov10
```
### Pretrained model
```
wget https://github.com/THU-MIG/yolov10/releases/download/v1.1/yolov10n.pt
```
### Config ultralytics
vi cfg/default.yaml:
```
opset: 12 # (int, optional) ONNX: opset version
```
### Gen onnx
python run_bench.py
```
from ultralytics.utils.benchmarks import benchmark
benchmark(model='yolov10n.pt', imgsz=640)
```

# Get SS model from onnx on docker
exe run.sh with the correct parameters
```
# Parameter Variables
MODEL_FILE_PATH="/work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/yolov10n.onnx"
INPUT_IMAGE_PATH="../SGS_Models/resource/detection/009962.bmp"
INPUT_SHAPE="1,3,640,640"
SOC_VERSION="souffle"
CALIBRATION_SCRIPT_PATH="./yolo_v3_640.py"
INPUT_CONFIG_PATH="./input_config_backbone.ini"
INPUT_ARRAYS="images"
OUTPUT_ARRAYS="output0"
NUM_PROCESS=20
```

