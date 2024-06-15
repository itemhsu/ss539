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
cd /work/SGS_V1.7_18.04/home/itemhsu/amtk/SGS_IPU_SDK/
source cfg_env.sh
cd Scripts/
python3 ConvertTool/ConvertTool.py -h
```
