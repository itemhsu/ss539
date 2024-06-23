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
```python3 ConvertTool/ConvertTool.py onnx --model_file /work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/yolov10n.onnx --input_shapes 1,3,640,640 --input_config /work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/input.cfg --output_file yolov10_float.sim```
* the input config is as
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

5. calibrate
```python3  calibrator/calibrator.py -i /work/SGS_V1.7_18.04/home/itemhsu/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/SGS_Models/resource/detection/coco2017_calibration_set32  --input_config /work/SGS_V1.7_18.04/home/itemhsu/yolo10/yolov10/input.cfg  -m yolov10_float.sim -n /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK/preposs.py --num_process 20```
* the prepose.py is as
```
import cv2
import numpy as np

def get_image(img_path, resizeH=640, resizeW=640, resizeC=3, norm=True, meanB=104.0, meanG=117.0, meanR=123.0, std=1.0, rgb=False, nchw=False):
    img = cv2.imread(img_path, flags=-1)
    if img is None:
        raise FileNotFoundError('No such image: {}'.format(img_path))

    try:
        img_dim = img.shape[2]
    except IndexError:
        img_dim = 1
    if img_dim == 4:
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
    elif img_dim == 1:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    img_float = img.astype('float32')
    img_norm = cv2.resize(img_float, (resizeW, resizeH), interpolation=cv2.INTER_LINEAR)

    if norm and (resizeC == 3):
        img_norm = (img_norm - [meanB, meanG, meanR]) / std
        img_norm = img_norm.astype('float32')
    elif norm and (resizeC == 1):
        img_norm = (img_norm - meanB) / std
        img_norm = img_norm.astype('float32')
    else:
        img_norm = np.round(img_norm).astype('uint8')

    if rgb:
        img_norm = cv2.cvtColor(img_norm, cv2.COLOR_BGR2RGB)

    if nchw:
        # NCHW
        img_norm = np.transpose(img_norm, axes=(2, 0, 1))

    return np.expand_dims(img_norm, 0)

def image_preprocess(img_path, norm=True):
    return get_image(img_path, norm=norm)
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
   
```python3 calibrator/simulator.py -i /work/SGS_V1.7_18.04/home/itemhsu/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/SGS_Models/resource/detection/coco2017_calibration_set32 -m yolov10_float.sim -l ~/SGS_Models/resource/detection/coco2017_val_set100.json -c Unknown -t Float -n ../preposs.py --num_process 10```
* output
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
*command

```python3 calibrator/simulator.py -i /work/SGS_V1.7_18.04/home/itemhsu/amtk/sdk/C539/MMD00V0.0.6_Release/ipu_sdk/SGS_Models/resource/detection/coco2017_calibration_set32 -m yolov10_fixed.sim -l ~/SGS_Models/resource/detection/coco2017_val_set100.json -c Unknown -t Fixed -n ../preposs.py --num_process 10```
     
