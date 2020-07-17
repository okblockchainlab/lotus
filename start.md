## filecoin lotus 私链部署

***注意：`start.sh`部署lotus私链目前仅支持Mac与Ubuntu系统，且golang版本必须14+***

```
./start.sh -i
```

* `-i` 初始化系统环境，安装依赖
* `-b` 编译lotus，准备创世块等
* `-c` 启动client node
* `-s` 启动storage miner
