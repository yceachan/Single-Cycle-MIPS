Read on yeeachan`s doc Web: [https://yceachan.github.io/微体系结构/](https://yceachan.github.io/%E5%BE%AE%E4%BD%93%E7%B3%BB%E7%BB%93%E6%9E%84/)
单周期处理器的数据路径易于构建，而时序需要考虑。

Ref：[实验十一 RV32I单周期CPU — 南京大学 计算机科学与技术系 数字逻辑与计算机组成 课程实验 documentation (nju-projectn.github.io)](https://nju-projectn.github.io/dlco-lecture-note/exp/11.html#cpu)

# quickstart

~~~
#项目依赖 ：modelsim环境变量
cd [your path]
git clone git@github.com:yceachan/Single-Cycle-MIPS.git
cd ./Sigle-Cycle-MIPS
#启动仿真
./sim.bat
~~~

# 工程结构

~~~
./rtl/ : rtl设计文件
./tb/  : testbench
./sim.bat :启动modelsim，运行仿真脚本
./sim.do  :modelsim仿真脚本
~~~

# 设计分析

> 在单周期CPU中，所有操作均需要在一个周期内完成。其中单周期存储部件的读写是时序设计的关键。
>
> 以下为nju数组实验推荐的单周期cpu时序

![image-20231201193152975](https://s2.loli.net/2023/12/02/kzXaPLe51UVsOSq.png)

> 以下为《数字设计与计算机体系结构》（黑皮书)给出的MIPS数据路径。
>
> 图中，Imem的地址输入宜改为pc' ，改为同步时序器件。

![image-20231201193404784](https://s2.loli.net/2023/12/02/LJNZKuhOeRFmiPq.png)"# Single-Cycle-MIPS" 
