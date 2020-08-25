micro-computer-experiment-report
=================================

A backup of my homework.

## 实验报告要求

- 要求画出程序流程图，不允许相同；
- 要求总结实验过程中遇到问题及如何解决；
- 要求给出调试过程中任意五条指令执行后的寄存器值；
- 要求给出自我评定成绩，自我评定为优秀者需经过面试，若面试成绩较差直接降为及格。
- 要求提交实验报告电子档，电子档命名法则，若命名出错由此带来最终成绩评定等级降低由自己负责。

### 三位登分号_姓名_实验号_自评等级 

 例如：1号同学应该为：001_张XX_1_A；11号同学应该为 011_王XX_1_A；111号同学应该为 111_李XX_1_A；

### 命名说明

- 登分号就是学校教务处登记分数时同学们的先后顺序，从1号开始，三位号码右前面补0形成；
- 自评等级A：优秀 B:良好； C：中等 D：及格 E：不及格
- 实验号 共四次

Dependent
---------

1.  A LaTex distribution. Such as [texlive].

Install
-------

``` {.zsh}
git clone git@github.com:Freed-Wu/micro-computer-experiment-report
cd micro-computer-experiment-report
latexmk -pvc main.tex
```

Q & A
-----

More question see [Issues].

If you don't wanna compile, you can download the complied paper from
[Release]

  [texlive]: https://github.com/TeX-Live/texlive-source
  [Issues]: https://github.com/Freed-Wu/micro-computer-experiment-report/issues
  [Release]: https://github.com/Freed-Wu/micro-computer-experiment-report/releases/

