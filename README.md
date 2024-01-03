# Bitcoin-Sim-DockerImage-Bjtu

比特币公链模拟节点镜像构建方法，用于构建比特币模拟节点。如有问题可提交Issue或发送邮件至 **xlchang@bjtu.edu.cn**

**架构**：AARCH 64

## 全节点镜像

### 使用方法一：直接载入镜像

在 **bitcoin:v1.0.tar** 所在目录，执行shell指令` docker load -i bitcoin:v1.0.tar ` 即可成功载入镜像。

### 使用方法二：利用Dockerfile自行制作镜像

**注：** 此方法需宿主机联网，Dockerfile中编译线程数量需根据实际情况自定义。

1. 下载**bitcoin core**源码，代码位置： **src/bitcoin**
2. 将**Dockerfile**与**bitcoin core**源码置于同一目录下，执行shell指令 `docker build -t bitcoin:v1.0 .`，等待制作完成。

## 轻节点镜像

### 使用方法：直接载入镜像

在 **bitcoin-light:v1.0.tar** 所在目录，执行**shell**指令 ' docker load -i bitcoin-light:v1.0.tar' 即可成功载入镜像。

