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
```python3 ConvertTool/ConvertTool.py onnx --model_file /work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/yolov10n.onnx --input_shapes 1,3,640,640 --input_config /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK_24070310_patch/onnx_yolov8s/input_config.ini --output_file yolov10_float.sim --soc_version mochi```
* soc_version is
  
| soc_version  | Type |
| ------------- | ------------- |
| muffin  |  |
| maruko  |  |
| opera  |  |
| souffle  |  |
| iford  |  |
| ifado |  |
| pcupid |  |


* the input config is as
```
[INPUT_CONFIG]
inputs=images;
training_input_formats=RGB;
input_formats=RGB;
quantizations=TRUE;
mean_red=0;
mean_green=0;
mean_blue=0;
std_value=255;

[OUTPUT_CONFIG]
outputs=output0;
dequantizations=TRUE;
```

5. calibrate
   
```python3  calibrator/calibrator.py -i /work/SGS_V1.7_18.04/home/itemhsu/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/SGS_Models/resource/detection/coco2017_calibration_set32 --input_config /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK_24070310_patch/onnx_yolov8s/input_config.ini   -m yolov10_float.sim -n /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK_24070310_patch/onnx_yolov8s/onnx_yolov8s_preprocess.py   --soc_version mochi```
* the onnx_yolov8s_preprocess.py is as

```
import cv2
import numpy as np

def letterbox(im, new_shape=(640, 640), color=(114, 114, 114), auto=False, scaleFill=False, scaleup=True, stride=32):
    # Resize and pad image while meeting stride-multiple constraints
    shape = im.shape[:2]  # current shape [height, width]
    if isinstance(new_shape, int):
        new_shape = (new_shape, new_shape)

    # Scale ratio (new / old)
    r = min(new_shape[0] / shape[0], new_shape[1] / shape[1])
    if not scaleup:  # only scale down, do not scale up (for better val mAP)
        r = min(r, 1.0)

    # Compute padding
    ratio = r, r  # width, height ratios
    new_unpad = int(round(shape[1] * r)), int(round(shape[0] * r))
    dw, dh = new_shape[1] - new_unpad[0], new_shape[0] - new_unpad[1]  # wh padding
    if auto:  # minimum rectangle
        dw, dh = np.mod(dw, stride), np.mod(dh, stride)  # wh padding
    elif scaleFill:  # stretch
        dw, dh = 0.0, 0.0
        new_unpad = (new_shape[1], new_shape[0])
        ratio = new_shape[1] / shape[1], new_shape[0] / shape[0]  # width, height ratios

    dw /= 2  # divide padding into 2 sides
    dh /= 2

    if shape[::-1] != new_unpad:  # resize
        im = cv2.resize(im, new_unpad, interpolation=cv2.INTER_LINEAR)
    top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
    left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
    im = cv2.copyMakeBorder(im, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)  # add border
    return im, ratio, (dw, dh)


def image_preprocess(image_file, norm=True):
    im = cv2.imread(image_file)

    im, ratio, (dw, dh) = letterbox(im)

    im = im[:, :, ::-1]  # BGR to RGB
    im = np.expand_dims(im, 0)
    im = np.ascontiguousarray(im)
    if norm:
        return im.astype(np.float32) / 255
    else:
        return im

```
6 compiler
```
python3 calibrator/compiler.py -m yolov10_fixed.sim
```
output is as 
```
Start to run convert offline network...
Run Offline OK. Cost time: 00:00:04.
Run Offline OK.
Start to run pack tool...
Offline model at: /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK/Scripts/yolov10_fixed.sim_sgsimg.img
Run Pack Tool OK.
```

7. simulate:float

```python3 calibrator/simulator.py -i /work/SGS_V1.7_18.04/home/itemhsu/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/SGS_Models/resource/detection/coco2017_calibration_set32 -m yolov10_float.sim -l ~/SGS_Models/resource/detection/coco2017_val_set100.json -c Unknown -t Float -n   /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK_24070310_patch/onnx_yolov8s/onnx_yolov8s_preprocess.py --num_process 10    --soc_version mochi```

```
Start to evaluate on coco2017_calibration_set32...
Net:
model (
Input(0):
    name:	input
    index:	0
    dtype:	<class 'numpy.float32'>
    layouts:	NHWC
    shape:	[1, 640, 640, 3]
Output(0):
    name:	output
    index:	0
    dtype:	<class 'numpy.float32'>
    shape:	[1, 84, 8400]
)

[==================================================]100.00% | ETA: 00:00:00
Total time elapsed: 00:00:05
Run evaluation OK.
```

* output files are located at log/output/*txt

8. simulate:fixed
   
* command

```python3 calibrator/simulator.py -i /work/SGS_V1.7_18.04/home/itemhsu/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/SGS_Models/resource/detection/coco2017_calibration_set32 -m yolov10_fixed.sim -l ~/SGS_Models/resource/detection/coco2017_val_set100.json -c Unknown -t Fixed -n ../preposs.py --num_process 10```

* output
```
Start to evaluate on coco2017_calibration_set32...
Net:
model (
Input(0):
    name:	input
    index:	0
    dtype:	<class 'numpy.uint8'>
    layouts:	NHWC
    shape:	[1, 640, 640, 3]
    training_input_formats:	BGR
    input_formats:	BGR
    input_width_alignment:	1
    input_height_alignment:	1
Output(0):
    name:	output
    index:	0
    dtype:	<class 'numpy.float32'>
    shape:	[1, 84, 8400]
)

[==================================================]100.00% | ETA: 00:00:00
Total time elapsed: 00:21:40
Run evaluation OK.
```
