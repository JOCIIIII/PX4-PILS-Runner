> 본 퀵 스타트 가이드는 우분투 22.04 LTS 환경을 고려해 작성했습니다. 페도라와 같은 다른 리눅스 배포판에서는 패키지 설치 등의 일부 명령어가 달라질 수 있습니다.

## 1. 저장소 클론하기

- 컴퓨터에 이 [kestr31/PX4-PILS-RUNNER](https://github.com/kestr31/PX4-PILS-Runner) GitHub 저장소를 클론합니다.
- 컴퓨터에 `git이 설치되어 있지 않다면 git을 먼저 설치해주세요.

```bash
cd ~/
sudo apt update && sudo apt install -y git
git clone https://github.com/jociiiii/PX4-PILS-Runner.git
```

## 2. PX4-Autopilot 소스 클론과 빌드

- 이전 단계에서 클론한 저장소 경로로 이동합니다.
- 그 다음 아래 명령어를 통해 PX4-Autopilot 소스를 클론하고 빌드합니다.
- 기본 설정으로 [PX4-Autopilot `v1.14.3`](https://github.com/PX4/PX4-Autopilot/tree/v1.14.3)이 클론됩니다.

```bash
cd ~/PX4-PILS-Runner
./scripts/run.sh sim px4 clone
./scripts/run.sh sim px4 build
./scripts/run.sh sim px4 stop
```

> 기본 설정에서 PX4-Autoiplot은 `~/Documents/A4VAI-PILS/PX4-Autopilot`에 클론되고 빌드됩니다.

## 3. ROS2 Package 클론, 빌드, 다운로드

### 3.1. ROS2 알고리즘 패키지 클론과 빌드

- ROS2 컨테이너 작업 공간에 [ROS2 작업 공간](https://docs.ros.org/en/galactic/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html)을 만들어줍니다.
- 그 다음, A4VAI 알고리즘들이 구현된 ROS2 패키지 소스를 해당 경로에 클론합니다.

```bash
mkdir -p ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src
git clone https://github.com/JOCIIIII/A4VAI-Algorithms-ROS2.git ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src
git -C ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src submodule update --init --recursive
mkdir -p ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src/pathplanning/pathplanning/model
wget https://github.com/Brightestsama/A4VAI-PathPlanning/releases/download/sac-v2.0.0/weight.onnx \
  -O ~/Documents/A4VAI-PILS/ROS2/ros2_ws/src/pathplanning/pathplanning/model/weight.onnx
```

> ROS2 컨테이너 작업 공간의 기본 경로는 `~/Documents/A4VAI-PILS/ROS2` 입니다.

- 이어서, 아래 명령어로 ROS2 패키지와 메시지들을 빌드합니다:

```bash
cd ~/PX4-PILS-Runner
./scripts/run.sh ros2 build ros2_ws
./scripts/run.sh ros2 stop
```

> [!WARNING] 
> ./scripts/run.sh ros2 build 로 빌드를 하면 안됩니다. airsim 등 다른 ROS2 패키지와 같이 빌드가 되어 이경우엔 Quick Start Guide를 다시 실행하십시오.


### 3.2. 필수 ROS2 패키지 다운로드.

- PX4-Autopilot(uXRCE-DDS Agent)와 AirSim(AirSim ROS2 Bridge)과의 통신을 위해서 준비해야 할 필수 ROS2 패키지들이 있습니다.
- 미리 빌드된 패키지들을 받을 수 있기 때문에 별도의 빌드 과정이 필요하지 않습니다.

```bash
wget https://github.com/kestr31/PX4-PILS-Runner/releases/download/Resources/airsim.tar.gz -O ~/Documents/A4VAI-PILS/ROS2/airsim.tar.gz
wget https://github.com/kestr31/PX4-PILS-Runner/releases/download/Resources/px4_ros.tar.gz -O ~/Documents/A4VAI-PILS/ROS2/px4_ros.tar.gz
tar -zxvf ~/Documents/A4VAI-PILS/ROS2/airsim.tar.gz -C ~/Documents/A4VAI-PILS/ROS2
tar -zxvf ~/Documents/A4VAI-PILS/ROS2/px4_ros.tar.gz -C ~/Documents/A4VAI-PILS/ROS2
git clone https://github.com/dheera/rosboard.git -b v1.3.1 ~/Documents/A4VAI-PILS/ROS2/rosboard
```

## 4. `GazeboDrone` 배치

- Gazebo Classic - AirSim PILS 시뮬레이션은 Gazebo Classic의 state를 AirSim으로 전달해주기 위한 Bridge를 요구합니다.
- 본 저장소에서는 사전 컴파일 된 Bridge 바이너리를 `GazeboDrone` 파일로 제공합니다.
- 해당 파일을 Gazebo Classic 컨테이너 작업 공간에 배치하고, 실행 권한을 부여합니다.

```bash
wget https://github.com/kestr31/PX4-PILS-Runner/releases/download/Resources/GazeboDrone -O ~/Documents/A4VAI-PILS/Gazebo-Classic/GazeboDrone
chmod +x ~/Documents/A4VAI-PILS/Gazebo-Classic/GazeboDrone
```

## 5. AirSim Binary와 `settings.json` 배치

- Gazebo-Classic과는 달리 Airsim의 World 정의("언리얼 바이너리")와 시뮬레이션 정의("Settings")는 별도 다운로드 및 배치가 필요합니다.
- 언리얼 바이너리의 예시는 [microsoft/AirSim release v1.8.1 - Linux](https://github.com/microsoft/AirSim/releases/tag/v1.8.1)에서 참고하실 수 있습니다.
- 먼저 시뮬레이션을 위한 언리얼 바이너리를 다운로드하고, AirSim 컨테이너 작업 공간 내에 `binary`라는 이름의 폴더로 배치합니다.

```bash
# wget과 unzip이 없을 경우 먼저 설치해줍니다.
sudo apt update && sudo apt install wget unzip
# wget을 이용해 언리얼 바이너리를 받습니다. wget 외의 어떤 방법을 사용해도 무방합니다.
wget https://github.com/microsoft/AirSim/releases/download/v1.8.1/AirSimNH.zip -P ~/Documents/A4VAI-PILS/AirSim
# 압축을 해제한 뒤 적절한 경로에 배치합니다.
unzip ~/Documents/A4VAI-PILS/AirSim/AirSimNH.zip -d ~/Documents/A4VAI-PILS/AirSim
mv ~/Documents/A4VAI-PILS/AirSim/AirSimNH/LinuxNoEditor/* ~/Documents/A4VAI-PILS/AirSim/AirSimNH
rm -rf ~/Documents/A4VAI-PILS/AirSim/AirSimNH/LinuxNoEditor
mv ~/Documents/A4VAI-PILS/AirSim/AirSimNH ~/Documents/A4VAI-PILS/AirSim/binary
```

- 이어서 예시 `settings.json` 파일을 받습니다.

```bash
wget https://github.com/kestr31/PX4-PILS-Runner/releases/download/Resources/settings.json -O ~/Documents/A4VAI-PILS/AirSim/settings.json
```
## 6. 시뮬레이션 실행

- 모든 준비가 끝났습니다. 마지막으로 컨테이너가 GUI 프로그램을 표시할 수 있도록 허용해줍니다.
- 그 다음, 아래 명령어를 이용해 시뮬레이션을 시작합니다. 실행에 필요한 docker 이미지들은 자동으로 받아집니다.

```bash
# xhost +는 매 재부팅 시마다 한 번씩만 실행해주시면 됩니다.
xhost +
cd ~/PX4-PILS-Runner
./scripts/run.sh gazebo-classic-airsim-PILS run
```

- 시뮬레이션 종료는 아래 명령어로 가능합니다.

```bash
cd ~/PX4-PILS-Runner
./scripts/run.sh gazebo-classic-airsim-PILS stop
```
> [!NOTE]  
> ~/Documents/A4VAI-PILS/ROS2/logs/rosbag 경로에는 simulation에서 사용된 모든 topic이 rosbag형태로 logging되어 있습니다.
> matlab의 ros toolbox를 사용하면 matlab환경에서 rosbag을 재생하여 topic을 불러올 수 있습니다.
